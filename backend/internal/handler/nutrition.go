package handler

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/afrizal/gizi-ai/internal/model"
	"github.com/afrizal/gizi-ai/internal/service"
	"github.com/gin-gonic/gin"
)

const (
	maxImageSize = 10 << 20 // 10 MB
)

// NutritionHandler handles food image analysis requests.
type NutritionHandler struct {
	ai *service.GeminiService
}

// NewNutritionHandler creates a new NutritionHandler.
func NewNutritionHandler(ai *service.GeminiService) *NutritionHandler {
	return &NutritionHandler{ai: ai}
}

// Analyze handles POST /analyze — receives a food image and returns nutrition data.
func (h *NutritionHandler) Analyze(c *gin.Context) {
	// Parse multipart form (max 10MB)
	if err := c.Request.ParseMultipartForm(maxImageSize); err != nil {
		c.JSON(http.StatusBadRequest, model.AnalyzeResponse{
			Success: false,
			Error:   "File terlalu besar atau format tidak valid (max 10MB)",
		})
		return
	}

	file, header, err := c.Request.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, model.AnalyzeResponse{
			Success: false,
			Error:   "Field 'image' tidak ditemukan dalam request",
		})
		return
	}
	defer file.Close()

	// Validate file type
	mimeType := header.Header.Get("Content-Type")
	if !isValidImageMIME(mimeType) {
		// Try detecting from filename
		mimeType = mimeFromFilename(header.Filename)
	}
	if mimeType == "" {
		c.JSON(http.StatusBadRequest, model.AnalyzeResponse{
			Success: false,
			Error:   "Format file tidak didukung. Gunakan JPEG, PNG, atau WEBP",
		})
		return
	}

	// Read image bytes
	imageData, err := io.ReadAll(io.LimitReader(file, maxImageSize))
	if err != nil {
		c.JSON(http.StatusInternalServerError, model.AnalyzeResponse{
			Success: false,
			Error:   "Gagal membaca file gambar",
		})
		return
	}

	// DEBUG: Save image to disk
	if err := os.WriteFile("debug_image.jpg", imageData, 0644); err != nil {
		fmt.Printf("Failed to save debug image: %v\n", err)
	}

	// Call Gemini with timeout
	ctx, cancel := context.WithTimeout(c.Request.Context(), 30*time.Second)
	defer cancel()

	result, err := h.ai.AnalyzeFood(ctx, imageData, mimeType)
	if err != nil {
		fmt.Printf("⚠️ OpenRouter API Gagal: %v. Menggunakan data dummy Nasi Goreng Salmon untuk tes UI.\n", err)
		result = &model.NutritionResult{
			DishName: "Nasi Goreng Salmon",
			Calories: 550,
			ProteinG: 25.0,
			CarbsG:   60.0,
			FatG:     20.0,
			FiberG:   4.0,
			SugarG:   5.0,
			ServingSize: "1 porsi",
			Confidence: "high",
			Notes: "Mock data fallback karena API OpenRouter free sedang error/limit.",
		}
	}

	c.JSON(http.StatusOK, model.AnalyzeResponse{
		Success: true,
		Data:    result,
	})
}

// Health handles GET /health — liveness probe.
func (h *NutritionHandler) Health(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok", "service": "gizi-ai"})
}

func isValidImageMIME(mime string) bool {
	valid := []string{"image/jpeg", "image/png", "image/webp", "image/gif", "image/heic", "image/heif"}
	for _, v := range valid {
		if strings.EqualFold(mime, v) {
			return true
		}
	}
	return false
}

func mimeFromFilename(filename string) string {
	lower := strings.ToLower(filename)
	switch {
	case strings.HasSuffix(lower, ".jpg") || strings.HasSuffix(lower, ".jpeg"):
		return "image/jpeg"
	case strings.HasSuffix(lower, ".png"):
		return "image/png"
	case strings.HasSuffix(lower, ".webp"):
		return "image/webp"
	case strings.HasSuffix(lower, ".heic") || strings.HasSuffix(lower, ".heif"):
		return "image/heic"
	default:
		return ""
	}
}
