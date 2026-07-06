---
name: ship
description: Finalisasi dan ship sebuah fitur yang sudah selesai dikerjakan.
  Menulis walkthrough, update kanban ke Done, dan update CLAUDE.md ADL.
---

# Ship

Jalankan protokol Ship untuk fitur yang baru saja selesai:

1. **Baca** `task.md` untuk summary apa yang sudah dikerjakan
2. **Verifikasi final**: `go test ./... -v -race` → tampilkan output
3. **Tulis/update** `walkthrough.md`:
   ```markdown
   ## Feature: [nama fitur]
   Date: [tanggal hari ini]
   Ticket: [ID dari KANBAN.md]
   
   ### What Was Built
   [Deskripsi singkat]
   
   ### Files Changed
   - [NEW/MODIFY/DELETE] filepath — alasan
   
   ### Test Evidence
   [Paste output dari go test]
   
   ### Architectural Notes
   [Keputusan penting yang dibuat]
   ```
4. **Update** `KANBAN.md`: pindah ticket dari "In Progress" ke "Done"
5. **Append** ke ADL di `CLAUDE.md` jika ada keputusan arsitektur baru
6. **Buat commit message** dengan format:
   `feat(scope): deskripsi singkat`
