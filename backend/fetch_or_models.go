package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

func main() {
	apiKey := os.Getenv("OPENROUTER_API_KEY")
	if apiKey == "" {
		apiKey = "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"
	}

	req, _ := http.NewRequest("GET", "https://openrouter.ai/api/v1/models", nil)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	
	var data struct {
		Data []struct {
			Id string `json:"id"`
			Architecture struct {
				Modality string `json:"modality"`
			} `json:"architecture"`
		} `json:"data"`
	}
	json.Unmarshal(body, &data)

	for _, v := range data.Data {
		if strings.Contains(v.Id, ":free") {
			fmt.Printf("Model: %s, Modality: %s\n", v.Id, v.Architecture.Modality)
		}
	}
}
