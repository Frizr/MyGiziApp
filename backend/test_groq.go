package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
)

func main() {
	apiKey := os.Getenv("GROQ_API_KEY")
	if apiKey == "" {
		apiKey = "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"
	}

	url := "https://api.groq.com/openai/v1/chat/completions"

	payload := map[string]interface{}{
		"model": "llama-3.2-11b-vision-preview",
		"messages": []map[string]interface{}{
			{
				"role": "user",
				"content": []map[string]interface{}{
					{
						"type": "text",
						"text": "test",
					},
				},
			},
		},
	}

	jsonData, _ := json.Marshal(payload)

	req, _ := http.NewRequestWithContext(context.Background(), "POST", url, bytes.NewBuffer(jsonData))
	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer resp.Body.Close()

	bodyBytes, _ := io.ReadAll(resp.Body)
	fmt.Printf("Status: %d\n", resp.StatusCode)
	fmt.Println(string(bodyBytes))
}
