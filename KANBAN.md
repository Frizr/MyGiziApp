# KANBAN — Project Golang

> Task board untuk AI agent dan developer. Update status saat mulai/selesai task.

---

## 🔴 To Do

| ID | Task | Priority | Notes |
|----|------|----------|-------|
| T-001 | Inisialisasi struktur project Go | High | Buat folder cmd/, internal/, pkg/ |
| T-002 | Setup Go module (`go mod init`) | High | Tentukan module path |
| T-003 | Buat REST API endpoint pertama | Medium | Tergantung kebutuhan project |

---

## 🟡 In Progress

*(kosong — tidak ada task aktif)*

---

## 🟢 Done

| ID | Task | Completed | Notes |
|----|------|-----------|-------|
| - | Setup CLAUDE.md & KANBAN.md | 2026-07-06 | Project memory initialized |

---

## 📝 Cara Pakai

**Untuk Agent:**
1. Baca `CLAUDE.md` dulu
2. Pick task dari kolom "To Do" → pindah ke "In Progress"
3. Kerjakan task di branch terpisah (`git checkout -b feature/T-001`)
4. Setelah selesai & test pass → pindah ke "Done"
5. Tulis `walkthrough.md` ringkasan apa yang dikerjakan

**Untuk Developer:**
- Tambah task baru di "To Do" dengan format: `T-XXX | Deskripsi | Priority | Notes`
- Review hasil agent di kolom "Done" sebelum merge

---

## 🔧 Optional: Jalankan Vibe Kanban UI

```bash
# Install dan jalankan Vibe Kanban (visual UI di browser)
npx vibe-kanban

# Atau mode desktop
npx vibe-kanban --desktop
```
