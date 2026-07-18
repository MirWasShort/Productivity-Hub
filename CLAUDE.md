# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Smart TODO App — a full-stack portfolio project with a **Flutter** frontend (`frontend/`) and **Java/Spring Boot** backend (`backend/`). The full specification lives in `doc/SPEC.md`. Development is documented commit-by-commit in `journal/`.

## Tech Stack

- **Frontend:** Flutter (Clean Architecture, Riverpod 3, Dio, Freezed 3, GoRouter, flutter_secure_storage, shared_preferences, table_calendar, fl_chart)
- **Backend:** Java 21, Spring Boot 4.x, Hexagonal Architecture, Spring Security + JWT (rotating refresh tokens), Spring Data JPA (+ Specifications), PostgreSQL, Flyway
- **DevOps:** Docker Compose (PostgreSQL 16), OpenAPI/Swagger via springdoc 3

## Architecture

- **Backend** follows Hexagonal (Ports & Adapters): `domain/model` (framework-free records), `application/port/{in,out}` + `application/service`, `adapter/{in/web,out/persistence}`, `infrastructure/{security,config}`
- **Frontend** follows Clean Architecture per feature: `lib/features/<feature>/{domain,data,presentation}`, shared `lib/core/{constants,error,network,router,storage}`
- UUID identifiers everywhere; JWT access tokens (15 min) + opaque rotating refresh tokens (7 days, SHA-256-hashed at rest)
- Every task operation is scoped to the authenticated user (404 on other users' tasks, never 403)
- API errors always use the same `ErrorResponse {timestamp,status,error,message,path,fieldErrors?}` shape

## Build & Test Commands

### Infrastructure
- Start database: `docker compose up -d` (PostgreSQL 16 on 5432)

### Backend (from `backend/`)
- **Always** `export JAVA_HOME="$(asdf where java)"` first (asdf shims are not enough for Gradle)
- Test all: `./gradlew test` (needs Docker: Testcontainers)
- Single test: `./gradlew test --tests '*ClassName*'`
- Run: `./gradlew bootRun` — API on **localhost:8081** (override with `SERVER_PORT`)
- Swagger UI: http://localhost:8081/swagger-ui.html

### Frontend (from `frontend/`)
- Get deps: `flutter pub get`
- Code generation (after touching freezed/json models): `dart run build_runner build --delete-conflicting-outputs`
- Analyze: `flutter analyze`
- Test all: `flutter test`
- Single test: `flutter test test/path/to_test.dart`
- Run: `flutter run -d chrome --web-port 5555` (backend CORS allows any `http://localhost:*`)
- Point at another API: `--dart-define=API_BASE_URL=http://host:port`

## Conventions

- TDD: write the failing test first; every commit leaves the suite green and the app runnable
- Each commit has a matching journal entry in `journal/CNN-*.md` (see `journal/README.md`)
- Boot 4 notes: test annotations live in per-module packages (`org.springframework.boot.webmvc.test.autoconfigure`), `@MockitoBean` replaces `@MockBean`, the ObjectMapper bean is Jackson 3 (`tools.jackson`)
- Flyway migrations are immutable once committed; schema changes = new `V<n>__*.sql`
- Generated Dart sources (`*.freezed.dart`, `*.g.dart`) are committed

## Key Documents

- `doc/SPEC.md` — full technical and functional specification
- `doc/ROADMAP.md` — 42-week learning roadmap this project follows
- `journal/README.md` — index of the commit-by-commit development journal

## Current Status

Implemented end-to-end (backend + Flutter UI, tested on both sides):
- Auth: register/login/refresh with rotation
- Per-user task CRUD; filters, text search and sort (JPA Specifications)
- Lists and tags (CRUD, assignment, filtering); migrations V1–V8
- Smart due-date grouping and overdue highlighting
- Calendar view (month/2-weeks/week)
- Analytics dashboard (summary + weekly completions + priority breakdown)
- Material 3 design system with persisted light/dark theme

Not yet implemented (see roadmap): offline-first (Drift), real-time (SSE), notifications, drag-and-drop reorder, CI/CD.

Migrations: V1 users, V2 refresh_tokens, V3 tasks, V4 todo_lists, V5 tags, V6 task_tags, V7 tasks.list_id, V8 tasks.completed_at. Next is V9.
