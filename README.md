# Smart TODO App (Productivity Hub)

Full-stack portfolio project: a task manager with a **Flutter** frontend and a
**Java / Spring Boot** backend, built incrementally with TDD.

> 📖 The development of this rewrite is documented commit-by-commit in
> [`journal/`](journal/README.md) — start there if you want to understand
> *how* and *why* everything was built.

## Stack

| Layer    | Tech |
|----------|------|
| Frontend | Flutter, Clean Architecture, Riverpod 3, Dio, Freezed 3, GoRouter |
| Backend  | Java 21, Spring Boot 4, Hexagonal Architecture, Spring Security + JWT (refresh rotation), Spring Data JPA, Flyway |
| Database | PostgreSQL 16 (Docker) |
| Docs     | OpenAPI / Swagger UI |

**Features:** registration & login (JWT access + rotating refresh
tokens), per-user task CRUD, transparent token refresh, route guards,
quick-add and full task editor. **Lists & tags** (custom lists, colored
tags, assignment and filtering). **Filters, search & sort** (status,
priority, text, list, tag; sort by date/priority/title). **Smart due
dates** (overdue highlighting, grouping Today/Tomorrow/This week/…).
**Calendar view** (month/2-weeks/week, tasks by day). **Analytics
dashboard** (stat tiles, weekly completions chart, priority donut).
**Light & dark themes**, persisted.

## Repository layout

```
backend/            # Spring Boot API (Gradle, Kotlin DSL)
frontend/           # Flutter app (smart_todo_app)
doc/                # SPEC.md and ROADMAP.md
journal/            # Commit-by-commit learning journal
docker-compose.yml  # PostgreSQL for local development
```

## Running locally

### 1. Database

```bash
docker compose up -d      # starts PostgreSQL 16 on localhost:5432
```

### 2. Backend

```bash
cd backend
export JAVA_HOME="$(asdf where java)"   # if using asdf; Gradle needs JAVA_HOME
./gradlew test                          # run the test suite (needs Docker for Testcontainers)
./gradlew bootRun                       # starts the API on localhost:8081
```

The API listens on **8081** by default (8080 is often taken by other
local services); override with the `SERVER_PORT` env var.

Swagger UI: <http://localhost:8081/swagger-ui.html>

### 3. Frontend

```bash
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # code generation
flutter test
flutter run -d chrome --web-port 5555
```

The backend allows CORS from any `http://localhost:*` origin in development,
so any web port works. Point the app at a different API with
`--dart-define=API_BASE_URL=http://host:port`.

## Documentation

- [`DEMO.md`](DEMO.md) — how to run a live demo, and which flows to show
- [`doc/SPEC.md`](doc/SPEC.md) — full technical & functional specification
- [`doc/ROADMAP.md`](doc/ROADMAP.md) — 42-week learning roadmap this project follows
- [`journal/`](journal/README.md) — what was built in each commit, and why
