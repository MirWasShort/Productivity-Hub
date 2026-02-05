# 📋 Smart TODO App -- Technical & Functional Specification

## 1. Overview

### Objective

Develop a modern full-stack TODO application to demonstrate
production-level skills in: - Flutter mobile development - Java backend
engineering - Clean architecture - Modern DevOps practices - Scalable
system design

The project is intended as a portfolio-grade application showcasing
real-world engineering practices.

------------------------------------------------------------------------

## 2. High-Level Architecture

### Frontend

-   Framework: Flutter (latest stable)
-   Architecture: Clean Architecture
-   State Management: Riverpod
-   Networking: Dio
-   Serialization: Freezed + json_serializable
-   Local Storage: Drift or Hive

### Backend

-   Language: Java 21
-   Framework: Spring Boot 3.x
-   Architecture: Hexagonal / Clean Architecture
-   API Style: REST
-   Security: Spring Security + JWT
-   ORM: Spring Data JPA / Hibernate
-   Database: PostgreSQL
-   Migration Tool: Flyway

### DevOps

-   Docker + Docker Compose
-   GitHub Actions (CI/CD)
-   OpenAPI / Swagger Documentation
-   Automated testing pipeline

------------------------------------------------------------------------

## 3. Functional Requirements

### 3.1 Authentication

-   User registration
-   Login / Logout
-   Access token (JWT)
-   Refresh token flow
-   Password recovery (mock implementation initially)

### 3.2 Task Management

-   Create tasks
-   Update tasks
-   Delete tasks
-   Mark tasks as completed
-   Assign priority (LOW, MEDIUM, HIGH)
-   Add due dates
-   Add notes
-   Assign multiple tags

### 3.3 Lists Management

-   Create custom lists
-   Assign tasks to lists
-   Reorder tasks via drag & drop
-   Rename and delete lists

### 3.4 Filtering & Search

-   Filter by status
-   Filter by priority
-   Filter by due date
-   Filter by tags
-   Text search

### 3.5 Notifications

-   Local reminders
-   Scheduled notifications

------------------------------------------------------------------------

## 4. Advanced Features

-   Offline-first support with local DB
-   Background sync
-   Real-time updates (WebSocket/SSE)
-   Analytics dashboard
-   Dark mode & animations

------------------------------------------------------------------------

## 5. Data Model

User, TodoList, Task, Tag, TaskTag entities with UUID identifiers and
timestamps.

------------------------------------------------------------------------

## 6. API Endpoints

Auth, Tasks, Lists, Tags CRUD endpoints using REST.

------------------------------------------------------------------------

## 7. Security Requirements

JWT auth, BCrypt hashing, DTO validation, global exception handling,
rate limiting.

------------------------------------------------------------------------

## 8. Testing Strategy

Backend: JUnit5, Integration tests, Testcontainers Frontend: Unit,
Widget, Golden, Integration tests

------------------------------------------------------------------------

## 9. Non-Functional Requirements

-   Clean architecture
-   Modular design
-   High test coverage
-   Responsive UI
-   Production-like logging

------------------------------------------------------------------------

## 10. Success Criteria

-   Authentication works
-   CRUD stable
-   Offline sync functional
-   CI/CD running
-   Tests implemented
-   Docker deployable
