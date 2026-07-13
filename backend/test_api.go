package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

func main() {
	url := "https://api.iamhc.cn/v1/chat/completions"
	apiKey := "sk-iiU7GwEuBOMrGzPQKJ7h1nGiz2vqLcc42pFXqyGR6d1yS6oc"

	payload := map[string]interface{}{
		"model": "DeepSeek-V4-Flash",
		"messages": []map[string]interface{}{
			{
				"role":    "user",
				"content": "Halo, apakah kamu bisa melihat dan menganalisis foto?",
			},
		},
	}

	jsonData, _ := json.Marshal(payload)

	req, _ := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+apiKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	fmt.Println("Status Code:", resp.StatusCode)
	fmt.Println("Response:", string(body))
}
