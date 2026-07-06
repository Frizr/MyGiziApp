# Gizi AI

Aplikasi analisis nutrisi makanan dari foto menggunakan **Gemini Vision AI**.

📱 Flutter (Android/iOS) + 🔧 Go Backend

## Fitur

- 📸 Foto makanan dari kamera atau galeri
- 🤖 Analisis nutrisi otomatis dengan Gemini AI
- 📊 Detail: kalori, protein, karbohidrat, lemak, serat, gula
- 🇮🇩 Nama makanan dalam Bahasa Indonesia

## Struktur Project

```
Project_Golang/
├── backend/          # Go API Server
│   ├── cmd/server/   # Entry point
│   ├── internal/
│   │   ├── handler/  # HTTP handlers
│   │   ├── model/    # Data structures
│   │   └── service/  # Gemini AI logic
│   └── .env.example
│
└── mobile/           # Flutter App
    └── lib/
        ├── core/     # Theme, constants
        └── features/
            └── nutrition/
                ├── data/         # API & models
                ├── domain/       # Entities
                └── presentation/ # UI screens
```

## Setup & Jalankan

### 1. Backend (Go)

```bash
cd backend

# Buat .env dari template
cp .env.example .env

# Isi GEMINI_API_KEY di .env
# Dapatkan API key di: https://aistudio.google.com/apikey

# Jalankan server
go run ./cmd/server
# Server berjalan di http://localhost:8080
```

### 2. Flutter App

```bash
cd mobile

# Install dependencies
flutter pub get

# Cek IP komputer kamu (untuk koneksi device fisik)
# Windows: ipconfig → IPv4 Address
# Edit lib/core/constants/api_constants.dart

# Jalankan di emulator/device
flutter run
```

### Konfigurasi IP

Edit `mobile/lib/core/constants/api_constants.dart`:

```dart
// Emulator Android (otomatis connect ke host)
static const String baseUrl = 'http://10.0.2.2:8080';

// Device fisik (ganti dengan IP komputer kamu)
static const String baseUrl = 'http://192.168.1.X:8080';
```

## Tech Stack

| Layer | Tech |
|-------|------|
| Mobile | Flutter 3.x + Dart |
| State Management | Riverpod |
| Backend | Go + Gin Framework |
| AI | Google Gemini 2.0 Flash Vision |
| HTTP Client | http package |
