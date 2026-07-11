# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Smart TODO App — a full-stack portfolio project with a **Flutter** mobile frontend and **Java/Spring Boot** backend. The full specification lives in `doc/SPEC.md`.

## Tech Stack

- **Frontend:** Flutter (Clean Architecture, Riverpod, Dio, Freezed, Drift or Hive)
- **Backend:** Java 21, Spring Boot 3.x, Hexagonal Architecture, Spring Security + JWT, Spring Data JPA, PostgreSQL, Flyway
- **DevOps:** Docker + Docker Compose, GitHub Actions, OpenAPI/Swagger

## Architecture

- **Backend** follows Hexagonal (Ports & Adapters) architecture
- **Frontend** follows Clean Architecture with Riverpod for state management
- Both sides use UUID identifiers for all entities
- JWT-based authentication with refresh token flow
- Offline-first frontend with local DB and background sync to backend

## Planned Build & Test Commands

These will apply once the project scaffolding is created:

### Backend (Spring Boot / Gradle or Maven)
- Build: `./gradlew build` (or `./mvnw package`)
- Run: `./gradlew bootRun` (or `./mvnw spring-boot:run`)
- Test all: `./gradlew test`
- Single test: `./gradlew test --tests "com.example.ClassName.methodName"`

### Frontend (Flutter)
- Get deps: `flutter pub get`
- Run code generation: `dart run build_runner build --delete-conflicting-outputs`
- Run: `flutter run`
- Test all: `flutter test`
- Single test: `flutter test test/path/to_test.dart`

### Infrastructure
- Start services: `docker-compose up -d`
- Database: PostgreSQL (via Docker)

## Key Data Entities

User, TodoList, Task, Tag, TaskTag — all with UUID PKs and audit timestamps.

## Key Documents

- `doc/SPEC.md` — Full technical and functional specification. Consult before implementing any feature.
- `doc/ROADMAP.md` — 42-week development roadmap for a junior developer. Covers 11 phases from foundation (Java/Dart basics) through portfolio packaging. Each phase includes learning objectives, side katas, testing strategy, refactoring checkpoints, and definition of done.

## Current Status

Project is in the specification and planning phase. No source code has been implemented yet.
