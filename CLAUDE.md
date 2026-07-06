# Project Memory: Project Golang

> **Setiap agent yang masuk ke project ini HARUS membaca file ini terlebih dahulu.**

## 1. Project Identity
- **Language / Runtime**: Go 1.23
- **Project Type**: REST API (bisa diubah sesuai kebutuhan)
- **Framework**: `net/http` (stdlib) untuk simple, `gin` jika butuh middleware berat
- **Database**: PostgreSQL via `pgx/v5` (default jika butuh DB)
- **OS Target**: Windows (developer), Linux (production)

## 2. Coding Standards
- Error handling: `fmt.Errorf("context: %w", err)` — selalu wrap errors
- Logging: `slog` (bukan `fmt.Println`)
- HTTP input validation: `go-playground/validator`
- Secrets: `os.Getenv()` — JANGAN hardcode, dokumentasikan di `.env.example`
- Testing: Table-driven tests, jalankan `go test ./... -v -race` sebelum klaim selesai

## 3. Directory Structure
```
Project_Golang/
  cmd/            # Main entrypoints (main.go per binary)
  internal/       # Private packages (business logic)
    domain/       # Entities, interfaces
    handler/      # HTTP handlers
    repository/   # DB access layer (repository pattern)
    service/      # Business logic layer
  pkg/            # Public reusable packages
  migrations/     # Database migrations
  .env.example    # Template environment variables
  CLAUDE.md       # File ini
  KANBAN.md       # Task tracking
```

## 4. Agent Directives
- ALWAYS run `go build ./...` after any code change
- ALWAYS run `go test ./...` before claiming any feature complete
- NEVER commit secrets — use `.env.example` for documentation
- CREATE `implementation_plan.md` before touching code for non-trivial changes
- UPDATE `KANBAN.md` when starting and completing tasks
- APPEND to ADL below when a significant architectural decision is made

## 5. Architecture Decision Log (ADL)
- [2026-07-06]: Project initialized. Using stdlib `net/http` as default — switch to gin if middleware complexity grows.
- [2026-07-06]: Repository pattern adopted for all DB access. No direct DB calls in handlers.

## 6. Active Tasks
See `KANBAN.md` for current task board.
