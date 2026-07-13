package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
)

func main() {
	apiKey := os.Getenv("OPENROUTER_API_KEY")
	if apiKey == "" {
		apiKey = "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"
	}

	url := "https://openrouter.ai/api/v1/chat/completions"

	payload := map[string]interface{}{
		"model": "google/gemini-2.0-flash-lite-preview-02-05:free",
		"messages": []map[string]interface{}{
			{
				"role": "user",
				"content": "Hello! What model are you?",
			},
		},
	}

	payloadBytes, _ := json.Marshal(payload)

	req, _ := http.NewRequest("POST", url, bytes.NewReader(payloadBytes))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("HTTP-Referer", "http://localhost:8080")
	req.Header.Set("X-Title", "Test")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	fmt.Println("Status:", resp.StatusCode)
	fmt.Println("Response:", string(body))
}
