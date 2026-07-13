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
	"time"

	"github.com/afrizal/gizi-ai/internal/model"
)

const geminiPrompt = `You are a professional nutritionist. Analyze this image of food and provide the nutritional breakdown in JSON format.
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

type GeminiService struct {
	apiKey string
}

func NewGeminiService() *GeminiService {
	apiKey := os.Getenv("GEMINI_API_KEY")
	return &GeminiService{
		apiKey: apiKey,
	}
}

func (s *GeminiService) AnalyzeFood(ctx context.Context, imageData []byte, mimeType string) (*model.NutritionResult, error) {
	if s.apiKey == "" {
		return nil, fmt.Errorf("GEMINI_API_KEY is not set in environment variables")
	}

	url := "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + s.apiKey

	base64Data := base64.StdEncoding.EncodeToString(imageData)

	payload := map[string]interface{}{
		"contents": []map[string]interface{}{
			{
				"parts": []map[string]interface{}{
					{"text": geminiPrompt},
					{
						"inline_data": map[string]interface{}{
							"mime_type": mimeType,
							"data":      base64Data,
						},
					},
				},
			},
		},
		"generationConfig": map[string]interface{}{
			"responseMimeType": "application/json",
		},
	}

	payloadBytes, _ := json.Marshal(payload)

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewReader(payloadBytes))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %v", err)
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 60 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %v", err)
	}
	defer resp.Body.Close()

	bodyBytes, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("gemini api error (status %d): %s", resp.StatusCode, string(bodyBytes))
	}

	var response struct {
		Candidates []struct {
			Content struct {
				Parts []struct {
					Text string `json:"text"`
				} `json:"parts"`
			} `json:"content"`
		} `json:"candidates"`
	}

	if err := json.Unmarshal(bodyBytes, &response); err != nil {
		return nil, fmt.Errorf("failed to parse gemini response: %v", err)
	}

	if len(response.Candidates) == 0 || len(response.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("gemini returned no content")
	}

	rawText := response.Candidates[0].Content.Parts[0].Text

	var result model.NutritionResult
	if err := json.Unmarshal([]byte(rawText), &result); err != nil {
		return nil, fmt.Errorf("failed to decode json result: %v, raw text: %s", err, rawText)
	}

	return &result, nil
}
