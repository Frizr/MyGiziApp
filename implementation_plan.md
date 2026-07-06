# Implementation Plan: Gizi AI — Flutter + Go

## Goal
Aplikasi mobile Flutter yang menganalisis nutrisi makanan dari foto,
menggunakan Go backend + Gemini Vision API.

## Architecture
- Flutter (Dart) — Mobile app Android/iOS
- Go 1.24 + Gin — REST API backend
- Gemini 2.0 Flash Vision — AI analisis nutrisi

## Project Structure
```
Project_Golang/
  backend/                     ← Go REST API
    cmd/server/main.go
    internal/
      model/nutrition.go
      service/gemini.go
      handler/nutrition.go
    .env.example
    go.mod

  mobile/                      ← Flutter App
    lib/
      main.dart
      screens/
        home_screen.dart       ← Upload foto + hasil
        result_screen.dart     ← Detail nutrisi
      services/
        api_service.dart       ← HTTP call ke Go backend
      models/
        nutrition_model.dart   ← Data class
      widgets/
        nutrition_card.dart    ← UI card nutrisi
        macro_bar.dart         ← Progress bar kalori/protein/dll
    pubspec.yaml
```

## Files Changed

### Backend (Go)
- [MODIFY] go.mod — update module path ke backend/
- [KEEP] internal/model/nutrition.go ← sudah dibuat
- [NEW] internal/service/gemini.go — Gemini Vision API client
- [NEW] internal/handler/nutrition.go — POST /analyze endpoint
- [NEW] cmd/server/main.go — Gin server entry point
- [NEW] .env.example — GEMINI_API_KEY template

### Mobile (Flutter)
- [NEW] mobile/ — Flutter project baru
- [NEW] lib/main.dart — App entry point + MaterialApp
- [NEW] lib/models/nutrition_model.dart — Data class
- [NEW] lib/services/api_service.dart — HTTP service ke Go backend
- [NEW] lib/screens/home_screen.dart — Home: pilih foto + upload
- [NEW] lib/screens/result_screen.dart — Hasil nutrisi lengkap
- [NEW] lib/widgets/nutrition_card.dart — Card komponen
- [NEW] lib/widgets/macro_bar.dart — Macro progress bar
- [NEW] pubspec.yaml — image_picker, http, flutter_animate

## Dependency Order
1. Backend: model → service/gemini → handler → main.go
2. Backend: go get dependencies → go build → test manual
3. Flutter: flutter create → update pubspec → models → services → widgets → screens
4. Integration test: Flutter kirim foto → Go backend → Gemini → hasil muncul di app

## Verification
- go build ./... (backend)
- flutter build apk --debug (mobile)
- End-to-end: upload foto → lihat hasil nutrisi

## Status: EXECUTING
