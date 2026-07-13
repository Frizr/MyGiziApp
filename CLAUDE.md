# MyGiziApp (Target Gizi Challenge)

MyGiziApp adalah aplikasi pencatatan nutrisi bergaya gamifikasi (*Gamified Diet Tracker*). Pengguna dapat mengatur target gizi (kalori, protein, lemak, karbohidrat), mencatat makanan secara manual, dan melihat progres harian mereka dalam bentuk "Health Bar" layaknya game RPG. Pengguna juga dapat bersaing konsistensi makan sehat di *Global Leaderboard* secara *real-time*.

*Catatan: Aplikasi ini telah melakukan pivot dari "Aplikasi Deteksi Gizi AI (Golang)" menjadi "Aplikasi Jurnal Gizi Manual Gamifikasi (Firebase)". Server Go tidak lagi digunakan.*

---

## 🛠️ Stack & Technologies
- **Framework:** Flutter (versi `^3.12.0`)
- **State Management:** Riverpod (`hooks_riverpod`) dipadukan dengan Flutter Hooks (`flutter_hooks`).
- **Backend & Database:** Firebase (Firebase Auth, Cloud Firestore).
- **Animasi & UI:** `flutter_animate` (animasi bar/poin) dan `lottie` (animasi status kosong/sukses), Material 3.

---

## 📁 Struktur Direktori (Clean Architecture)
Struktur di dalam `mobile/lib/` mematuhi paradigma *Feature-First*:
```text
lib/
├── core/                       # Infrastruktur global & Shared Resources
│   ├── constants/              # Konfigurasi app (misal: String constants, keys)
│   ├── services/               # Layanan third-party (misal: ApiService, Firebase instance config)
│   └── theme/                  # Konfigurasi `AppTheme`, warna, typography (gelap/terang)
│
├── features/
│   ├── auth/                   # Modul Firebase Authentication
│   │   ├── data/               # Models dan Repository (Koneksi ke FirebaseAuth)
│   │   └── presentation/       # UI (AuthScreen) dan Controller/StateNotifier (Login/Register)
│   │
│   ├── gamification/           # Modul Papan Peringkat (Leaderboard) & Leveling User
│   │   ├── data/               # Models (ScoreModel) dan Firestore Repository
│   │   └── presentation/       # UI Leaderboard Screen & Riverpod StreamProvider
│   │
│   └── nutrition/              # Modul Jurnal Makro, Health Bar & Input Manual
│       ├── data/               # Models (DailyLog, FoodItem) dan Firestore Repository
│       └── presentation/       # UI Dashboard, Input Makanan, & Widget (MacroBar, NutrientCard)
│
└── main.dart                   # Entry point (Menangani auto-routing berdasarkan AuthState)
```

---

## ⚙️ Aturan Penulisan Kode (Guidelines)

### 1. Metode "Ponytail" (Bottom-Up)
Saat membangun fitur baru, mulailah dari akar ke permukaan:
1. **Core:** Buat constants atau endpoint/key Firestore jika diperlukan.
2. **Data Layer:** Buat `Model` (dengan `fromJson`/`toJson`) dan `Repository` (fungsi interaksi DB).
3. **Domain/State Layer:** Buat *Riverpod Provider* atau `StateNotifier` untuk membungkus logika bisnis.
4. **Presentation Layer:** Terakhir, rakit UI (Widgets) dengan `HookConsumerWidget`.

### 2. State Management (Hooks + Riverpod)
- Wajib menggunakan `HookConsumerWidget` pada setiap Stateless UI yang butuh interaksi.
- Untuk state reaktif lokal UI (seperti teks di kolom form, toggle password, flag animasi), gunakan Flutter Hooks: `useState`, `useTextEditingController`, `useAnimationController`.
- Untuk state global / pemanggilan API / manipulasi Firebase, gunakan **StateNotifierProvider** (untuk *write/update* data) dan **StreamProvider** (untuk me-*listen* *real-time updates* Firestore).

### 3. Design System & Konsistensi UI
Aplikasi ini memakai **Dark Theme** futuristik. Setia pada sistem warna yang ada di `AppTheme`:
- **Background:** Gelap kebiruan (`Color(0xFF0F172A)`).
- **Primary:** Aksen hijau-kuning terang (`Color(0xFFC4F135)`).
- **Macro Colors:** Selalu gunakan konstanta makro saat mendesain UI asupan: `proteinColor`, `carbsColor`, `fatColor`.
- Pakai ulang komponen yang sudah jadi seperti `MacroBar` dan `NutrientCard` untuk menjaga keaslian desain.

---

## 🗄️ Skema Database (Cloud Firestore)
Database dirancang dengan pola *NoSQL document-oriented*.

**1. Collection: `users`**
Menyimpan profil gamifikasi pengguna.
- `uid` (String, Primary Key)
- `name` (String)
- `email` (String)
- `score` (Int) — *Exp/Skor konsistensi akumulatif pengguna.*
- `level` (Int)
- `createdAt` (Timestamp)

**2. Collection: `daily_logs`**
Log kalori dan asupan makanan pengguna setiap hari.
- Document ID: `<uid>_<YYYY-MM-DD>` (Contoh: `axb12_2026-07-09`)
- `uid` (String)
- `date` (String) — Format `YYYY-MM-DD`
- `targetCalories` (Int)
- `currentCalories` (Int)
- `currentProtein` (Double), `currentCarbs` (Double), `currentFat` (Double)
- `meals` (Array of Objects):
  - `time` (Timestamp)
  - `foodName` (String)
  - `calories` (Int)

---

## 🚀 Rencana Pengembangan Terdekat (Roadmap)
1. ✅ **Setup Autentikasi:** Implementasi Firebase Auth, Login/Register UI, dan simpan *User Profile* (skor awal = 0) ke Firestore.
2. 🔄 **Rombak UI HomeScreen:** 
   - Ubah layout menjadi *Bottom Navigation* (Tab: Dashboard, Input Makanan, Leaderboard).
   - Tampilkan *Daily Health Bar* (menggunakan logic makro Riverpod) yang *real-time* mengambil data `daily_logs` hari ini.
3. ⏳ **Halaman Input Makanan Manual:** 
   - Formulir sederhana untuk memasukkan nama makanan dan estimasi kalori/makro.
   - Saat disubmit, meng-update array `meals` pada `daily_logs` di Firestore dan mengevaluasi penambahan `score`.
4. ⏳ **Sistem Leaderboard:**
   - Gunakan `StreamProvider` di Riverpod untuk me- *listen* *top 50 users* dari collection `users` yang diurutkan berdasarkan `score` tertinggi. Tampilkan secara *real-time*.