package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
)

func main() {
	apiKey := os.Getenv("GROQ_API_KEY")
	if apiKey == "" {
		apiKey = "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"
	}

	req, _ := http.NewRequest("GET", "https://api.groq.com/openai/v1/models", nil)
	req.Header.Set("Authorization", "Bearer "+apiKey)
	resp, _ := http.DefaultClient.Do(req)
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	var data struct {
		Data []struct {
			Id string `json:"id"`
		} `json:"data"`
	}
	json.Unmarshal(body, &data)

	for _, v := range data.Data {
		fmt.Println(v.Id)
	}
}
