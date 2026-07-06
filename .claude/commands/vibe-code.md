---
name: vibe-code
description: Jalankan Vibe Coding workflow lengkap untuk sebuah fitur.
  Membaca CLAUDE.md, cek KANBAN, buat implementation plan, eksekusi dengan TDD,
  verifikasi via terminal, dan ship dengan walkthrough.
argument-hint: [deskripsi-fitur]
---

# Vibe Code

Kamu sekarang dalam mode **Vibe Coding**. Ikuti protokol 5 langkah ini PERSIS:

## Step 1: Research
1. Baca `CLAUDE.md` untuk memuat memory dan constraint project
2. Baca `KANBAN.md` untuk identifikasi ticket aktif
3. Jalankan `list_dir` pada direktori yang relevan untuk mapping codebase
4. Gunakan `grep_search` untuk menemukan pola yang sudah ada

## Step 2: Plan
1. Tulis `implementation_plan.md` dengan format:
   - Goal (1 kalimat)
   - Files: [NEW]/[MODIFY]/[DELETE] per file
   - Dependency order
   - Risks & trade-offs
2. Minta approval untuk perubahan besar (>3 file / schema DB / public API)

## Step 3: Execute
1. Kerjakan SATU file dalam satu waktu
2. Ikuti konvensi yang sudah ada di codebase (baca file tetangga dulu)
3. Setiap error handling harus eksplisit (tidak ada error yang di-ignore)

## Step 4: Verify
1. Jalankan: `go build ./...` → fix semua error
2. Jalankan: `go vet ./...` → fix semua warning  
3. Jalankan: `go test ./... -v -race` → semua test harus hijau
4. TAMPILKAN output terminal sebagai bukti. DILARANG klaim "berhasil" tanpa bukti.

## Step 5: Ship
1. Tulis/update `walkthrough.md` dengan summary + bukti test
2. Update `KANBAN.md`: pindah ticket ke Done
3. Append ke ADL di `CLAUDE.md` jika ada keputusan arsitektur baru

---

Sekarang mulai untuk fitur: **$1**
