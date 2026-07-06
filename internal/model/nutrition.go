package model

// NutritionResult holds the parsed nutrition data from Gemini Vision analysis.
type NutritionResult struct {
	DishName    string  `json:"dish_name"`
	Calories    float64 `json:"calories"`
	ProteinG    float64 `json:"protein_g"`
	CarbsG      float64 `json:"carbs_g"`
	FatG        float64 `json:"fat_g"`
	FiberG      float64 `json:"fiber_g"`
	SugarG      float64 `json:"sugar_g"`
	ServingSize string  `json:"serving_size"`
	Confidence  string  `json:"confidence"` // "high", "medium", "low"
	Notes       string  `json:"notes"`
}

// AnalyzeResponse is the HTTP response envelope.
type AnalyzeResponse struct {
	Success bool             `json:"success"`
	Data    *NutritionResult `json:"data,omitempty"`
	Error   string           `json:"error,omitempty"`
}
