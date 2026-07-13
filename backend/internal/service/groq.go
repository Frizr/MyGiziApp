package service

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/afrizal/gizi-ai/internal/model"
)

const groqPrompt = `You are a professional nutritionist AI. Analyze the food in this image and provide detailed nutritional information.

Return ONLY a valid JSON object with this exact structure (no markdown, no extra text):
{
  "dish_name": "Name of the dish in Indonesian",
  "calories": 350.0,
  "protein_g": 18.5,
  "carbs_g": 45.2,
  "fat_g": 12.1,
  "fiber_g": 3.2,
  "sugar_g": 5.0,
  "serving_size": "1 porsi (±250g)",
  "confidence": "high",
  "notes": "Estimasi untuk 1 porsi standar. Nilai nutrisi dapat bervariasi tergantung cara masak."
}

Rules:
- dish_name: nama makanan dalam Bahasa Indonesia
- All numeric values must be numbers (not strings)
- confidence: "high" if food is clearly visible, "medium" if partially visible, "low" if unclear
- If you cannot identify food in the image, set dish_name to "Bukan Makanan" and all numbers to 0. Set notes to "Sepertinya ini bukan makanan. Coba foto makanan sungguhan ya!"
- Estimate for a typical single serving portion`

type GroqService struct {
	apiKey string
	client *http.Client
}

func NewGroqService(apiKey string) (*GroqService, error) {
	if apiKey == "" {
		return nil, fmt.Errorf("groq API key cannot be empty")
	}
	return &GroqService{
		apiKey: apiKey,
		client: &http.Client{Timeout: 60 * time.Second},
	}, nil
}

func (g *GroqService) AnalyzeFood(ctx context.Context, imageData []byte, mimeType string) (*model.NutritionResult, error) {
	url := "https://api.groq.com/openai/v1/chat/completions"

	base64Image := base64.StdEncoding.EncodeToString(imageData)
	dataURI := fmt.Sprintf("data:%s;base64,%s", mimeType, base64Image)

	payload := map[string]interface{}{
		"model": "llama-3.2-90b-vision-preview",
		"messages": []map[string]interface{}{
			{
				"role": "user",
				"content": []map[string]interface{}{
					{
						"type": "text",
						"text": groqPrompt,
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
		"temperature": 0.1,
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal payload: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Authorization", "Bearer "+g.apiKey)
	req.Header.Set("Content-Type", "application/json")

	resp, err := g.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("groq api request failed: %w", err)
	}
	defer resp.Body.Close()

	bodyBytes, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("groq api error (status %d): %s", resp.StatusCode, string(bodyBytes))
	}

	var groqResp struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}

	if err := json.Unmarshal(bodyBytes, &groqResp); err != nil {
		return nil, fmt.Errorf("failed to decode groq response: %w", err)
	}

	if len(groqResp.Choices) == 0 {
		return nil, fmt.Errorf("groq returned no choices")
	}

	rawText := groqResp.Choices[0].Message.Content
	rawText = cleanJSON(rawText)

	fmt.Printf("Groq Raw Response: %s\n", rawText)

	var result model.NutritionResult
	if err := json.NewDecoder(bytes.NewBufferString(rawText)).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to parse groq response as JSON: %w\nraw: %s", err, rawText)
	}

	return &result, nil
}

func (g *GroqService) Close() {}

func cleanJSON(s string) string {
	s = strings.TrimSpace(s)
	if strings.HasPrefix(s, "```json") {
		s = strings.TrimPrefix(s, "```json")
		s = strings.TrimSuffix(s, "```")
	} else if strings.HasPrefix(s, "```") {
		s = strings.TrimPrefix(s, "```")
		s = strings.TrimSuffix(s, "```")
	}
	return strings.TrimSpace(s)
}
