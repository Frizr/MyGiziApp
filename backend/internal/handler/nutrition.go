package handler

import (
	"context"
	"io"
	"net/http"
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
	gemini *service.GeminiService
}

// NewNutritionHandler creates a new NutritionHandler.
func NewNutritionHandler(gemini *service.GeminiService) *NutritionHandler {
	return &NutritionHandler{gemini: gemini}
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

	// Call Gemini with timeout
	ctx, cancel := context.WithTimeout(c.Request.Context(), 30*time.Second)
	defer cancel()

	result, err := h.gemini.AnalyzeFood(ctx, imageData, mimeType)
	if err != nil {
		c.JSON(http.StatusInternalServerError, model.AnalyzeResponse{
			Success: false,
			Error:   "Gagal menganalisis gambar: " + err.Error(),
		})
		return
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
