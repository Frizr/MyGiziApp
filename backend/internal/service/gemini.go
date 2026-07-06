package service

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/afrizal/gizi-ai/internal/model"
	"google.golang.org/genai"
)

const nutritionPrompt = `You are a professional nutritionist AI. Analyze the food in this image and provide detailed nutritional information.

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
- If you cannot identify food in the image, set dish_name to "Tidak terdeteksi" and all numbers to 0
- Estimate for a typical single serving portion`

// GeminiService handles communication with the Gemini Vision API.
type GeminiService struct {
	client *genai.Client
	model  string
}

// NewGeminiService creates a new GeminiService instance.
func NewGeminiService(apiKey string) (*GeminiService, error) {
	ctx := context.Background()
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		APIKey:  apiKey,
		Backend: genai.BackendGeminiAPI,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create Gemini client: %w", err)
	}

	return &GeminiService{
		client: client,
		model:  "gemini-2.0-flash",
	}, nil
}

// AnalyzeFood sends an image to Gemini Vision and returns parsed nutrition data.
func (g *GeminiService) AnalyzeFood(ctx context.Context, imageData []byte, mimeType string) (*model.NutritionResult, error) {
	contents := []*genai.Content{
		{
			Parts: []*genai.Part{
				{Text: nutritionPrompt},
				{
					InlineData: &genai.Blob{
						MIMEType: mimeType,
						Data:     imageData,
					},
				},
			},
			Role: "user",
		},
	}

	resp, err := g.client.Models.GenerateContent(ctx, g.model, contents, nil)
	if err != nil {
		return nil, fmt.Errorf("gemini generate content failed: %w", err)
	}

	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("gemini returned empty response")
	}

	rawText := resp.Candidates[0].Content.Parts[0].Text
	rawText = cleanJSON(rawText)

	var result model.NutritionResult
	if err := json.NewDecoder(bytes.NewBufferString(rawText)).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to parse gemini response as JSON: %w\nraw: %s", err, rawText)
	}

	return &result, nil
}

// Close is a no-op kept for API compatibility — genai.Client manages its own lifecycle.
func (g *GeminiService) Close() {}

// cleanJSON removes markdown code fences if Gemini wraps JSON in them.
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
