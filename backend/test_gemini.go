package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"google.golang.org/genai"
)

func main() {
	if err := godotenv.Load(".env"); err != nil {
		log.Println("No .env file found")
	}
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		log.Fatal("GEMINI_API_KEY is required")
	}

	ctx := context.Background()
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		APIKey:  apiKey,
		Backend: genai.BackendGeminiAPI,
	})
	if err != nil {
		log.Fatal(err)
	}

	contents := []*genai.Content{
		{
			Parts: []*genai.Part{
				{Text: "What is this?"},
			},
			Role: "user",
		},
	}

	resp, err := client.Models.GenerateContent(ctx, "gemini-2.0-flash", contents, nil)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Resp: %+v\n", resp)
	if len(resp.Candidates) > 0 && len(resp.Candidates[0].Content.Parts) > 0 {
		fmt.Printf("Text: %v\n", resp.Candidates[0].Content.Parts[0].Text)
	}
}
