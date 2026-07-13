package service

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/afrizal/gizi-ai/internal/model"
)

const openRouterPrompt = `You are a professional nutritionist. Analyze this image of food and provide the nutritional breakdown in JSON format.
Your response MUST be a valid JSON object matching the following structure exactly:
{
	"dish_name": "Name of the food",
	"calories": 0.0,
	"protein_g": 0.0,
	"carbs_g": 0.0,
	"fat_g": 0.0,
	"fiber_g": 0.0,
	"sugar_g": 0.0,
	"serving_size": "Description of the portion (e.g., 1 plate, 1 bowl)",
	"confidence": "high/medium/low",
	"notes": "Any additional dietary notes or observations"
}
Only output the JSON object, with no markdown formatting, no code blocks, and no extra text.`

type OpenRouterService struct {
	apiKey string
}

func NewOpenRouterService() *OpenRouterService {
	apiKey := os.Getenv("OPENROUTER_API_KEY")
	return &OpenRouterService{
		apiKey: apiKey,
	}
}

func (s *OpenRouterService) AnalyzeFood(ctx context.Context, imageData []byte, mimeType string) (*model.NutritionResult, error) {
	if s.apiKey == "" {
		return nil, fmt.Errorf("OPENROUTER_API_KEY is not set in environment variables")
	}

	url := "https://openrouter.ai/api/v1/chat/completions"

	base64Data := base64.StdEncoding.EncodeToString(imageData)
	dataURI := fmt.Sprintf("data:%s;base64,%s", mimeType, base64Data)

	payload := map[string]interface{}{
		"model": "meta-llama/llama-3.2-11b-vision-instruct:free",
		"messages": []map[string]interface{}{
			{
				"role": "user",
				"content": []map[string]interface{}{
					{
						"type": "text",
						"text": openRouterPrompt,
					},
					{
						"type": "image_url",
						"image_url": map[string]string{
							"url": dataURI,
						},
					},
				},
			},
		},
	}

	payloadBytes, _ := json.Marshal(payload)

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewReader(payloadBytes))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %v", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+s.apiKey)
	req.Header.Set("HTTP-Referer", "http://localhost:8080") // Required by OpenRouter
	req.Header.Set("X-Title", "Gizi AI")                    // Required by OpenRouter

	client := &http.Client{Timeout: 60 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %v", err)
	}
	defer resp.Body.Close()

	bodyBytes, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("openrouter api error (status %d): %s", resp.StatusCode, string(bodyBytes))
	}

	var response struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}

	if err := json.Unmarshal(bodyBytes, &response); err != nil {
		return nil, fmt.Errorf("failed to parse openrouter response: %v", err)
	}

	if len(response.Choices) == 0 {
		return nil, fmt.Errorf("openrouter returned no choices")
	}

	rawText := response.Choices[0].Message.Content

	// Membersihkan balasan markdown JSON jika ada
	rawText = strings.TrimSpace(rawText)
	if strings.HasPrefix(rawText, "```json") {
		rawText = strings.TrimPrefix(rawText, "```json")
		rawText = strings.TrimSuffix(rawText, "```")
	} else if strings.HasPrefix(rawText, "```") {
		rawText = strings.TrimPrefix(rawText, "```")
		rawText = strings.TrimSuffix(rawText, "```")
	}
	rawText = strings.TrimSpace(rawText)

	var result model.NutritionResult
	if err := json.Unmarshal([]byte(rawText), &result); err != nil {
		return nil, fmt.Errorf("failed to decode json result: %v, raw text: %s", err, rawText)
	}

	return &result, nil
}
