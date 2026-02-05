# Smart TODO App — Development Roadmap

> **Audience:** Junior developer brand new to Java/Spring Boot and Flutter/Dart
> **Time commitment:** 10–20 hours per week
> **Build tool:** Gradle
> **Mindset:** TDD-first, progressive complexity, deliberate practice

This roadmap breaks the Smart TODO App (see `SPEC.md`) into manageable phases. Each phase builds on the last. You will never be asked to write production code without first understanding *why* it exists and having a test that proves it works.

**How to use this document:**
1. Work through phases in order — they are sequenced intentionally.
2. Complete every "Side Kata" before moving to the main phase work. Katas build muscle memory.
3. At each "Refactoring Checkpoint," stop adding features and clean up what you have.
4. Don't skip the "Definition of Done" — it's your quality gate.
5. If a phase feels too easy, compress it. If it feels overwhelming, slow down and re-read the kata material.

---

## Table of Contents

- [Phase 0 — Foundation (Weeks 1–4)](#phase-0--foundation-weeks-14)
- [Phase 1 — Backend Skeleton (Weeks 5–8)](#phase-1--backend-skeleton-weeks-58)
- [Phase 2 — Core Backend CRUD (Weeks 9–12)](#phase-2--core-backend-crud-weeks-912)
- [Phase 3 — Authentication (Weeks 13–16)](#phase-3--authentication-weeks-1316)
- [Phase 4 — Flutter Foundation (Weeks 17–20)](#phase-4--flutter-foundation-weeks-1720)
- [Phase 5 — Flutter Meets Backend (Weeks 21–25)](#phase-5--flutter-meets-backend-weeks-2125)
- [Phase 6 — Lists, Tags, Filtering & Search (Weeks 26–29)](#phase-6--lists-tags-filtering--search-weeks-2629)
- [Phase 7 — Offline-First (Weeks 30–33)](#phase-7--offline-first-weeks-3033)
- [Phase 8 — Advanced Features (Weeks 34–37)](#phase-8--advanced-features-weeks-3437)
- [Phase 9 — Polish & DevOps (Weeks 38–40)](#phase-9--polish--devops-weeks-3840)
- [Phase 10 — Portfolio Packaging (Weeks 41–42)](#phase-10--portfolio-packaging-weeks-4142)

---

## Phase 0 — Foundation (Weeks 1–4)

**Goal:** Build the foundational skills and tooling knowledge you need before writing any project code. By the end, you should be comfortable writing small programs in both Java and Dart, using Git confidently, and running things from the command line.

### Learning Objectives

- Understand Java syntax, OOP fundamentals, and the JVM ecosystem
- Understand Dart syntax, its type system, and async/await
- Be comfortable with Git (branching, committing, merging, pull requests)
- Know your way around the terminal, your IDE, and Gradle
- Understand what TDD is and why we use it

### Week-by-Week Breakdown

#### Week 1: Java Fundamentals
- Install JDK 21, IntelliJ IDEA (Community Edition), and Git
- Learn: variables, types, control flow, methods, classes, interfaces
- Resources: Oracle Java tutorials, "Head First Java" chapters 1–5
- Write 5+ small programs (calculator, FizzBuzz, simple class hierarchies)

#### Week 2: Java OOP & Collections
- Learn: inheritance, polymorphism, abstract classes, interfaces, generics
- Learn: `List`, `Map`, `Set`, `Optional`, streams basics
- Write a small "contact book" console app using `HashMap` and `ArrayList`
- Learn: exceptions (checked vs unchecked), try-catch-finally

#### Week 3: Dart Fundamentals
- Install Flutter SDK (which includes Dart)
- Learn: variables (`var`, `final`, `const`), types, null safety, functions
- Learn: classes, mixins, extensions, `Future`, `async`/`await`, `Stream` basics
- Write the same 5 small programs you wrote in Java, but in Dart — notice the differences

#### Week 4: Git & Tooling
- Learn: `git init`, `add`, `commit`, `branch`, `merge`, `rebase`, `pull`, `push`
- Learn: GitHub flow (feature branches, pull requests, code review)
- Set up this repository's branch protection rules
- Learn Gradle basics: what `build.gradle` is, tasks, dependencies, plugins
- Write your first JUnit 5 test (just `assertEquals` on a simple function)
- Write your first Dart test using `package:test`

### Side Katas

| # | Kata | Language | Purpose |
|---|------|----------|---------|
| 0.1 | **FizzBuzz with TDD** | Java | Write FizzBuzz test-first. Red → Green → Refactor. |
| 0.2 | **String Calculator** | Java | Parse comma-separated numbers, return sum. TDD. Handle edge cases. |
| 0.3 | **FizzBuzz with TDD** | Dart | Same kata, different language. Notice Dart testing patterns. |
| 0.4 | **Word Frequency Counter** | Dart | Read a string, count word occurrences, return a `Map<String, int>`. |
| 0.5 | **Git Kata** | — | Create a repo, make conflicting branches, resolve a merge conflict manually. |

### Technical Skills Checklist

- [ ] Can create and run a Java program from the command line
- [ ] Can create and run a Dart program from the command line
- [ ] Can write and run a JUnit 5 test
- [ ] Can write and run a Dart test
- [ ] Can create a Git branch, make commits, and open a PR on GitHub
- [ ] Can resolve a merge conflict
- [ ] Can explain what TDD's Red-Green-Refactor cycle means

### Testing Strategy

- Every kata must be done test-first: write the test, watch it fail (red), make it pass (green), then refactor
- Use JUnit 5 assertions (`assertEquals`, `assertThrows`, `assertTrue`)
- Use Dart `expect()` matchers (`equals`, `throwsA`, `isTrue`)

### Common Mistakes to Avoid

- **Skipping tests because "the code is simple"** — the point is to build the TDD habit, not to test complex logic
- **Copying code from tutorials without typing it** — type everything yourself; muscle memory matters
- **Not committing often enough** — commit after every green test
- **Trying to learn everything at once** — focus on the week's topic, ignore what comes later
- **Ignoring compiler warnings** — treat warnings as errors from day one

### Refactoring Checkpoint

At the end of Week 4, review all your kata code:
- Are variable names descriptive?
- Are methods short (under 15 lines)?
- Is there any duplicated code you can extract into a method?
- Do your tests have clear names that describe behavior (not implementation)?

### Definition of Done

- [ ] All 5 katas completed with tests passing
- [ ] Git history shows Red-Green-Refactor commits for each kata
- [ ] Can explain OOP concepts (encapsulation, inheritance, polymorphism) in your own words
- [ ] Can explain the difference between Java and Dart (null safety, async model, type inference)
- [ ] Development environment fully set up (JDK 21, Flutter SDK, IntelliJ/VS Code, Git, Docker Desktop)

---

## Phase 1 — Backend Skeleton (Weeks 5–8)

**Goal:** Create the Spring Boot project, get it running, connect it to PostgreSQL via Docker, write your first Flyway migration, and create the first JPA entity — all test-first.

### Learning Objectives

- Understand what Spring Boot does and how auto-configuration works
- Understand the Hexagonal Architecture pattern and why we use it
- Know how to run PostgreSQL in Docker and connect Spring Boot to it
- Understand database migrations with Flyway
- Write integration tests that use a real database (Testcontainers)

### Week-by-Week Breakdown

#### Week 5: Spring Boot Hello World
- Generate a project at [start.spring.io](https://start.spring.io) with: Spring Web, Spring Data JPA, PostgreSQL Driver, Flyway Migration, Validation, Spring Boot DevTools
- Choose Gradle (Kotlin DSL) as build tool, Java 21, and `com.smarttodo` as group ID
- Understand the generated project structure: `src/main/java`, `src/main/resources`, `src/test`
- Create a simple `GET /health` endpoint that returns `{"status": "UP"}`
- Write a test for it using `@SpringBootTest` and `MockMvc`

#### Week 6: Docker & PostgreSQL
- Install Docker Desktop
- Create a `docker-compose.yml` with PostgreSQL 16
- Configure `application.yml` with datasource properties
- Create `application-test.yml` for test configuration
- Verify Spring Boot connects to PostgreSQL on startup
- Add Testcontainers dependency and write a test that starts a real PostgreSQL container

#### Week 7: Flyway & First Entity
- Create your first Flyway migration: `V1__create_user_table.sql`
- Define the `users` table with: `id` (UUID, PK), `email`, `password_hash`, `display_name`, `created_at`, `updated_at`
- Create the `User` JPA entity class
- Create `UserRepository` extending `JpaRepository<User, UUID>`
- Write a repository integration test: save a user, find it by email

#### Week 8: Hexagonal Architecture Setup
- Create the package structure:
  ```
  com.smarttodo
  ├── domain/           # Entities, value objects, domain services
  │   └── model/
  ├── application/      # Use cases, port interfaces
  │   ├── port/
  │   │   ├── in/       # Driving ports (use case interfaces)
  │   │   └── out/      # Driven ports (repository interfaces)
  │   └── service/      # Use case implementations
  ├── adapter/
  │   ├── in/
  │   │   └── web/      # REST controllers, DTOs
  │   └── out/
  │       └── persistence/  # JPA entities, repository implementations
  └── infrastructure/   # Configuration, security, etc.
  ```
- Refactor the User entity to fit this structure
- Create the first driving port: `CreateUserUseCase` interface
- Create the first driven port: `UserRepositoryPort` interface
- Implement both and wire them together

### Side Katas

| # | Kata | Purpose |
|---|------|---------|
| 1.1 | **REST API with Spring Boot** | Build a tiny "quote of the day" API (no database). Practice `@RestController`, `@GetMapping`, `@PostMapping`, DTOs, and `MockMvc` testing. |
| 1.2 | **Docker Compose Playground** | Create a `docker-compose.yml` that runs PostgreSQL + pgAdmin. Connect, create a table manually, insert data, query it. |
| 1.3 | **Flyway Migration Chain** | In a scratch project, create 5 sequential migrations that build up a schema. Practice rolling forward. Understand why you never edit a migration after it runs. |
| 1.4 | **Hexagonal Architecture Diagram** | Draw (on paper or Excalidraw) the hexagonal architecture for this project. Label: domain, application, adapters, ports. Identify which layers depend on which. |

### Technical Skills Checklist

- [ ] Can generate and run a Spring Boot project with Gradle
- [ ] Can explain what `@SpringBootApplication` does
- [ ] Can write a REST controller with request/response DTOs
- [ ] Can write a `MockMvc` test
- [ ] Can run PostgreSQL in Docker and connect Spring Boot to it
- [ ] Can create and run Flyway migrations
- [ ] Can write a JPA entity with UUID primary key
- [ ] Can write a repository integration test with Testcontainers
- [ ] Can explain Hexagonal Architecture: ports, adapters, domain

### Testing Strategy

- **Unit tests** for domain logic (plain JUnit, no Spring context)
- **Integration tests** for repositories (use `@DataJpaTest` + Testcontainers)
- **Web layer tests** for controllers (use `@WebMvcTest` + `MockMvc`)
- Every new class gets a corresponding test class
- Test naming convention: `should_doExpectedBehavior_when_givenCondition`

### Common Mistakes to Avoid

- **Putting business logic in controllers** — controllers should only translate HTTP to use cases and back
- **Skipping Testcontainers and using H2 instead** — H2 behaves differently from PostgreSQL; always test against the real database engine
- **Editing existing Flyway migrations** — once a migration has run, it's immutable. Create a new migration instead
- **Making the domain layer depend on Spring annotations** — the domain should be framework-agnostic
- **Not using DTOs** — never expose JPA entities directly in REST responses

### Refactoring Checkpoint

Before moving to Phase 2:
- Verify your package structure matches the hexagonal layout
- Ensure no `import` in the `domain` package references Spring or JPA
- Check that all tests pass: `./gradlew test`
- Review your Flyway migration — is the SQL clean and well-formatted?
- Ensure `docker-compose up -d` starts the database and the app connects on boot

### Definition of Done

- [ ] Spring Boot app starts and responds to `GET /health`
- [ ] PostgreSQL runs in Docker via `docker-compose.yml`
- [ ] Flyway migration creates the `users` table on startup
- [ ] `User` JPA entity exists with UUID primary key
- [ ] `UserRepository` integration test passes against Testcontainers PostgreSQL
- [ ] Hexagonal package structure is in place
- [ ] At least one driving port and one driven port exist with implementations
- [ ] All tests pass (`./gradlew test`)
- [ ] Code is committed with clean history on a feature branch

---

## Phase 2 — Core Backend CRUD (Weeks 9–12)

**Goal:** Implement full CRUD for the Task entity using TDD, proper validation, error handling, and API documentation. This is where you build real backend engineering muscle.

### Learning Objectives

- Implement a complete CRUD lifecycle test-first
- Understand request validation with Bean Validation (`@Valid`)
- Build a global exception handler with consistent error responses
- Document APIs with OpenAPI/Swagger
- Understand pagination and sorting

### Week-by-Week Breakdown

#### Week 9: Task Domain & Persistence
- Flyway migration: `V2__create_task_table.sql` with columns: `id` (UUID), `title`, `description`, `status` (enum: TODO, IN_PROGRESS, DONE), `priority` (enum: LOW, MEDIUM, HIGH), `due_date`, `created_at`, `updated_at`, `user_id` (FK)
- Create `Task` domain model (not a JPA entity — a pure domain object)
- Create `TaskJpaEntity` in the persistence adapter
- Create mapping between domain model and JPA entity
- Write repository integration tests

#### Week 10: Task Use Cases
- Define use case ports:
  - `CreateTaskUseCase`
  - `GetTaskUseCase`
  - `UpdateTaskUseCase`
  - `DeleteTaskUseCase`
  - `ListTasksUseCase` (with pagination)
- Implement each use case in `application/service/TaskService`
- Write unit tests for each use case (mock the repository port)
- Test edge cases: creating a task with empty title, updating a non-existent task, etc.

#### Week 11: REST API Layer
- Create `TaskController` with endpoints:
  - `POST /api/v1/tasks` — create
  - `GET /api/v1/tasks/{id}` — get by ID
  - `GET /api/v1/tasks` — list (paginated)
  - `PUT /api/v1/tasks/{id}` — update
  - `DELETE /api/v1/tasks/{id}` — delete
- Create request/response DTOs: `CreateTaskRequest`, `UpdateTaskRequest`, `TaskResponse`
- Add Bean Validation annotations: `@NotBlank`, `@Size`, `@NotNull`
- Write `MockMvc` tests for every endpoint and validation scenario

#### Week 12: Error Handling & Swagger
- Create a global exception handler (`@RestControllerAdvice`):
  - `ResourceNotFoundException` → 404
  - `ValidationException` → 400 (with field-level error details)
  - Generic exceptions → 500
- Create a consistent error response DTO: `{ "timestamp", "status", "error", "message", "path" }`
- Add SpringDoc OpenAPI dependency and configure Swagger UI
- Verify all endpoints appear in Swagger UI at `/swagger-ui.html`
- Write tests that verify error response format

### Side Katas

| # | Kata | Purpose |
|---|------|---------|
| 2.1 | **Mapper Kata** | Write a utility that converts between two object types (e.g., `PersonDTO` ↔ `PersonEntity`). Practice separating layers. |
| 2.2 | **Validation Kata** | Create a `@Valid`-annotated DTO with 5+ fields. Write tests that trigger each validation error. Verify the error messages. |
| 2.3 | **Pagination Kata** | In a scratch project, create a `GET /items?page=0&size=10&sort=name,asc` endpoint. Understand `Page<T>`, `Pageable`, `Sort`. |
| 2.4 | **Exception Handler Kata** | Build a `@RestControllerAdvice` that handles 3 custom exception types with different HTTP status codes. Test each with `MockMvc`. |

### Technical Skills Checklist

- [ ] Can create a complete CRUD REST API test-first
- [ ] Can write domain models that are framework-agnostic
- [ ] Can map between domain models, JPA entities, and DTOs
- [ ] Can add Bean Validation and test validation errors
- [ ] Can build a global exception handler with consistent error format
- [ ] Can add pagination and sorting to list endpoints
- [ ] Can configure and use Swagger/OpenAPI documentation

### Testing Strategy

- **Test pyramid in action:**
  - Unit tests for `TaskService` (mock repos) — fast, many of these
  - Integration tests for `TaskJpaRepository` (Testcontainers) — slower, fewer
  - Web tests for `TaskController` (MockMvc, mock service) — verify HTTP contracts
- **Each endpoint** needs tests for: happy path, validation errors, not found, server error
- **Each use case** needs tests for: valid input, invalid input, edge cases
- Run all tests frequently: `./gradlew test`

### Common Mistakes to Avoid

- **Skipping the domain model and using JPA entities everywhere** — this couples your domain logic to the database framework
- **Not testing validation** — if you add `@NotBlank`, write a test that sends a blank value and asserts 400
- **Returning JPA entities from controllers** — always use DTOs for API responses
- **Hardcoding IDs in tests** — use `UUID.randomUUID()` for test data
- **Writing tests after the code** — always write the test first, even when it feels slower

### Refactoring Checkpoint

Before moving to Phase 3:
- Extract any duplicated mapping code into dedicated mapper classes
- Ensure all error responses follow the same format
- Review test names — do they describe behavior? (`should_return404_when_taskNotFound`)
- Check that the domain package has zero Spring imports
- Run test coverage report: `./gradlew jacocoTestReport` — aim for 80%+ on service and controller layers
- Confirm Swagger UI shows all endpoints with correct request/response schemas

### Definition of Done

- [ ] Task CRUD endpoints all work and are tested (happy path + error cases)
- [ ] Bean Validation is in place with tested error responses
- [ ] Global exception handler returns consistent error format
- [ ] Swagger UI documents all endpoints
- [ ] Pagination and sorting work on the list endpoint
- [ ] Domain model is separate from JPA entity with explicit mappers
- [ ] Test coverage is above 80% for service and controller layers
- [ ] All tests pass (`./gradlew test`)

---

## Phase 3 — Authentication (Weeks 13–16)

**Goal:** Implement JWT-based authentication with Spring Security. Registration, login, token refresh, and protected endpoints. This is the hardest backend phase — take it slow.

### Learning Objectives

- Understand how Spring Security's filter chain works
- Implement JWT token generation, validation, and refresh
- Secure endpoints so only authenticated users can access their own data
- Understand password hashing with BCrypt
- Write security integration tests

### Week-by-Week Breakdown

#### Week 13: Spring Security Fundamentals
- Add Spring Security dependency
- Understand the `SecurityFilterChain` concept
- Create a basic `SecurityConfig` that:
  - Permits `/api/v1/auth/**` without authentication
  - Requires authentication for everything else
  - Disables CSRF (for REST API)
  - Sets session management to STATELESS
- At this point, all your existing Task tests will break — fix them by adding `@WithMockUser` or configuring test security

#### Week 14: JWT Implementation
- Add `jjwt` (Java JWT) dependency
- Create `JwtTokenProvider` with methods:
  - `generateAccessToken(userId, email)` — short-lived (15 min)
  - `generateRefreshToken(userId)` — long-lived (7 days)
  - `validateToken(token)` → boolean
  - `extractUserId(token)` → UUID
- Create `JwtAuthenticationFilter` (extends `OncePerRequestFilter`):
  - Extract token from `Authorization: Bearer <token>` header
  - Validate it
  - Set `SecurityContextHolder` authentication
- Write unit tests for `JwtTokenProvider` (generation, validation, expiry, tampering)

#### Week 15: Auth Endpoints
- Create `AuthController` with:
  - `POST /api/v1/auth/register` — create user, return tokens
  - `POST /api/v1/auth/login` — validate credentials, return tokens
  - `POST /api/v1/auth/refresh` — exchange refresh token for new access token
- Create `AuthService` use case implementation:
  - Registration: validate input, hash password with BCrypt, save user, generate tokens
  - Login: find user by email, verify password, generate tokens
  - Refresh: validate refresh token, generate new access token
- Store refresh tokens in database (new Flyway migration: `V3__create_refresh_token_table.sql`)
- Implement password recovery (mock):
  - `POST /api/v1/auth/forgot-password` — accepts email, returns success (no real email sent)
  - `POST /api/v1/auth/reset-password` — accepts token + new password, resets password
  - For now, log the reset token to console instead of sending an email
- Write integration tests for each auth endpoint

#### Week 16: Securing Task Endpoints
- Modify `TaskService` to always scope operations to the authenticated user
- Add `@AuthenticationPrincipal` to inject current user into controller methods
- A user should only see/modify their own tasks — write tests that verify:
  - User A cannot read User B's tasks (→ 403 or 404)
  - User A cannot update/delete User B's tasks
- Add rate limiting to auth endpoints (simple in-memory approach is fine for now)
- Update Swagger config to include Bearer token authentication

### Side Katas

| # | Kata | Purpose |
|---|------|---------|
| 3.1 | **Password Hashing Kata** | Write a small program that hashes passwords with BCrypt and verifies them. Understand salt, cost factor, and why you never store plaintext. |
| 3.2 | **JWT Playground** | Use [jwt.io](https://jwt.io) to create and decode JWTs manually. Understand header, payload, signature. Modify a token and see validation fail. |
| 3.3 | **Spring Security Filter Kata** | In a scratch project, create a custom filter that logs every request. Add it to the `SecurityFilterChain`. Understand filter ordering. |
| 3.4 | **Authorization Kata** | Create two roles (USER, ADMIN). Write tests that verify: USER can access `/user/**`, ADMIN can access `/admin/**`, neither can access the other's endpoints. |

### Technical Skills Checklist

- [ ] Can explain how Spring Security's filter chain processes a request
- [ ] Can generate and validate JWT tokens
- [ ] Can implement registration with BCrypt password hashing
- [ ] Can implement login with credential verification
- [ ] Can implement refresh token flow
- [ ] Can protect endpoints so users only access their own data
- [ ] Can write security integration tests

### Testing Strategy

- **Unit tests** for `JwtTokenProvider` (token generation, validation, expiry, tampering)
- **Unit tests** for `AuthService` (mock repository, verify BCrypt usage)
- **Integration tests** for auth endpoints (full HTTP roundtrip with Testcontainers)
- **Authorization tests** for task endpoints:
  - Unauthenticated → 401
  - Authenticated but accessing another user's data → 403/404
  - Authenticated and accessing own data → 200
- Use `@SpringBootTest` with `TestRestTemplate` for full integration tests

### Common Mistakes to Avoid

- **Storing JWT secrets in code** — use `application.yml` with environment variable override
- **Not testing token expiry** — write a test that creates an expired token and verifies it's rejected
- **Forgetting to scope tasks to users** — this is a security bug; test it explicitly
- **Making the JWT filter too complex** — it should only extract, validate, and set context. No business logic.
- **Not handling refresh token revocation** — when a user logs out, invalidate their refresh tokens

### Refactoring Checkpoint

Before moving to Phase 4:
- Review your `SecurityConfig` — is it readable? Are the rules clear?
- Verify that no endpoint leaks data across users
- Check that all previous Task tests still pass with security enabled
- Look for hardcoded secrets and move them to configuration
- Ensure your JWT-related code is in the `infrastructure` package, not in `domain`
- Run full test suite: `./gradlew test`

### Definition of Done

- [ ] Registration, login, and refresh endpoints work and are tested
- [ ] Passwords are hashed with BCrypt (never stored in plaintext)
- [ ] JWT access tokens expire after 15 minutes
- [ ] Refresh tokens are stored in database and can be revoked
- [ ] All task endpoints require authentication
- [ ] Users can only access their own tasks (tested)
- [ ] Swagger UI supports Bearer token authentication
- [ ] All tests pass (`./gradlew test`)
- [ ] No hardcoded secrets in source code

---

## Phase 4 — Flutter Foundation (Weeks 17–20)

**Goal:** Build your Dart/Flutter skills, understand widget composition, state management with Riverpod, and set up the Clean Architecture project structure. No backend integration yet — all local.

### Learning Objectives

- Understand Flutter's widget tree, build cycle, and layout system
- Master Riverpod for state management (providers, notifiers, async)
- Set up Clean Architecture folder structure for Flutter
- Understand navigation and routing
- Write widget tests and unit tests in Flutter

### Week-by-Week Breakdown

#### Week 17: Flutter & Dart Deep Dive
- Build a simple counter app (the default Flutter template)
- Rebuild it 3 different ways: with `setState`, with `ChangeNotifier`, with Riverpod
- Learn: `StatelessWidget`, `StatefulWidget`, `BuildContext`, widget lifecycle
- Learn: `Column`, `Row`, `Stack`, `ListView`, `Scaffold`, `AppBar`, `FloatingActionButton`
- Understand the difference between `const` constructors and regular constructors

#### Week 18: Riverpod Mastery
- Add `flutter_riverpod` to your project
- Learn: `Provider`, `StateProvider`, `StateNotifierProvider`, `FutureProvider`, `StreamProvider`
- Learn: `ref.watch`, `ref.read`, `ref.listen`, `ProviderScope`
- Build a simple "notes" app with Riverpod (list of notes, add, delete — all in-memory)
- Write tests using `ProviderContainer` to verify state transitions

#### Week 19: Clean Architecture Setup
- Create the Flutter project: `flutter create --org com.smarttodo smart_todo_app`
- Set up the folder structure:
  ```
  lib/
  ├── core/              # Shared utilities, constants, errors, network
  │   ├── error/
  │   ├── network/
  │   └── util/
  ├── features/
  │   └── task/
  │       ├── domain/        # Entities, repository interfaces, use cases
  │       │   ├── entities/
  │       │   ├── repositories/
  │       │   └── usecases/
  │       ├── data/          # Repository impls, data sources, models
  │       │   ├── datasources/
  │       │   ├── models/
  │       │   └── repositories/
  │       └── presentation/  # Screens, widgets, providers/notifiers
  │           ├── providers/
  │           ├── screens/
  │           └── widgets/
  └── main.dart
  ```
- Add dependencies: `flutter_riverpod`, `freezed`, `freezed_annotation`, `json_annotation`, `json_serializable`, `build_runner`, `dio`
- Configure `build_runner` for code generation

#### Week 20: Navigation & First Screens
- Set up `GoRouter` (or Navigator 2.0) for routing
- Create placeholder screens: `LoginScreen`, `TaskListScreen`, `TaskDetailScreen`, `SettingsScreen`
- Build a bottom navigation bar or drawer for navigation
- Create `Task` entity with Freezed: `id`, `title`, `description`, `status`, `priority`, `dueDate`
- Create `TaskNotifier` with Riverpod that manages a list of fake/hardcoded tasks
- Build `TaskListScreen` that displays tasks from the notifier
- Write widget tests for `TaskListScreen`

### Side Katas

| # | Kata | Purpose |
|---|------|---------|
| 4.1 | **Widget Composition Kata** | Build a reusable `UserCard` widget that takes a name, email, and avatar URL. Use it in a `ListView`. Test it renders correctly. |
| 4.2 | **Riverpod State Kata** | Create a `StateNotifier` for a shopping cart (add item, remove item, calculate total). Write tests for every state transition. |
| 4.3 | **Freezed Model Kata** | Create 3 Freezed data classes with `copyWith`, JSON serialization, and union types. Write tests that serialize/deserialize them. |
| 4.4 | **Form Validation Kata** | Build a registration form with email, password, and confirm password fields. Validate all fields. Show error messages. Test with widget tests. |

### Technical Skills Checklist

- [ ] Can build a multi-screen Flutter app with navigation
- [ ] Can use Riverpod for state management (StateNotifier pattern)
- [ ] Can create Freezed data classes with code generation
- [ ] Can write widget tests using `testWidgets` and `WidgetTester`
- [ ] Can write unit tests for Riverpod notifiers
- [ ] Can explain Clean Architecture layers in the context of Flutter
- [ ] Can use `build_runner` for code generation

### Testing Strategy

- **Unit tests** for domain entities and use cases (pure Dart, no Flutter)
- **Unit tests** for Riverpod notifiers using `ProviderContainer`
- **Widget tests** for screens and reusable widgets
- Test naming: `'should display task list when tasks are loaded'`
- Use `pumpWidget` and `pump` to control the widget lifecycle in tests
- Mock dependencies using `mocktail` or `mockito`

### Common Mistakes to Avoid

- **Putting business logic in widgets** — widgets should only call notifiers and render state
- **Not running `build_runner` after changing Freezed classes** — you'll get confusing compile errors
- **Using `setState` when Riverpod should manage the state** — only use `setState` for truly local widget state (e.g., form field focus)
- **Skipping widget tests** — they're fast and catch UI regressions
- **Deep nesting of widgets** — extract reusable widgets when nesting exceeds 4 levels

### Refactoring Checkpoint

Before moving to Phase 5:
- Ensure your folder structure matches Clean Architecture
- Verify all Freezed code generation runs cleanly: `dart run build_runner build --delete-conflicting-outputs`
- Check that no `presentation` code imports from `data` directly (always go through `domain`)
- Review widget tests — do they test behavior, not implementation?
- Ensure navigation works between all screens

### Definition of Done

- [ ] Flutter project created with Clean Architecture folder structure
- [ ] Riverpod is set up and managing task state
- [ ] Freezed models are created and code generation works
- [ ] At least 4 screens exist with working navigation
- [ ] `TaskListScreen` displays hardcoded tasks from Riverpod
- [ ] Widget tests exist for key screens
- [ ] Unit tests exist for Riverpod notifiers
- [ ] All tests pass: `flutter test`

---

## Phase 5 — Flutter Meets Backend (Weeks 21–25)

**Goal:** Connect the Flutter frontend to the Spring Boot backend. Implement authentication screens, task CRUD screens, and proper API integration with error handling.

### Learning Objectives

- Configure Dio for API communication with interceptors
- Implement the auth flow in Flutter (login, register, token storage, auto-refresh)
- Build complete task CRUD screens connected to the real backend
- Handle loading, error, and empty states in the UI
- Understand the repository pattern as a bridge between data sources and domain

### Week-by-Week Breakdown

#### Week 21: Dio Setup & Auth Data Layer
- Configure `Dio` instance with base URL, timeouts, and logging interceptor
- Create `AuthRemoteDataSource` with methods for register, login, refresh
- Create `AuthRepository` implementation that calls the data source
- Create `TokenStorage` using `flutter_secure_storage` for storing JWT tokens
- Create a Dio interceptor that:
  - Attaches the access token to every request
  - Catches 401 errors, attempts token refresh, and retries the request
  - Redirects to login if refresh fails

#### Week 22: Auth Screens
- Build `LoginScreen`:
  - Email and password fields with validation
  - Login button with loading state
  - Error message display
  - "Don't have an account? Register" link
- Build `RegisterScreen`:
  - Email, password, confirm password, display name fields
  - Validation for all fields
  - Registration button with loading state
- Create `AuthNotifier` (Riverpod) that manages auth state:
  - `loading`, `authenticated`, `unauthenticated`, `error` states
  - On app start, check for stored token and validate it
- Wire up navigation: unauthenticated → login screen, authenticated → task list

#### Week 23: Task CRUD — Data Layer
- Create `TaskRemoteDataSource` with Dio calls for all CRUD endpoints
- Create `TaskModel` (Freezed) with JSON serialization matching the backend API
- Create `TaskRepository` implementation that:
  - Calls the remote data source
  - Maps `TaskModel` ↔ `Task` domain entity
  - Handles API errors and maps them to domain failures
- Create domain failure types: `ServerFailure`, `NetworkFailure`, `NotFoundFailure`

#### Week 24: Task CRUD — Screens
- Build `TaskListScreen` (replace the hardcoded version):
  - Pull-to-refresh
  - Loading state (shimmer/skeleton)
  - Empty state ("No tasks yet — create one!")
  - Error state with retry button
  - FAB to create new task
  - Swipe to delete
- Build `TaskDetailScreen`:
  - Display all task fields
  - Edit button → `TaskEditScreen`
  - Delete button with confirmation dialog
- Build `TaskEditScreen` (used for both create and edit):
  - Form fields: title, description, priority (dropdown), due date (date picker), status
  - Validation
  - Save button with loading state

#### Week 25: Polish & Integration Testing
- Add pull-to-refresh to task list
- Add optimistic updates (update UI immediately, revert on failure)
- Add snackbar notifications for success/error actions
- Write integration tests that verify the full flow: login → create task → see it in list → edit → delete
- Handle edge cases: network timeout, server down, invalid token

### Side Katas

| # | Kata | Purpose |
|---|------|---------|
| 5.1 | **Dio Interceptor Kata** | Build a Dio interceptor that adds a custom header to every request and logs request/response. Write a test using a mock adapter. |
| 5.2 | **Loading/Error State Kata** | Create a generic `AsyncValue` renderer widget that shows loading spinner, error with retry, or content. Reuse it across screens. |
| 5.3 | **Secure Storage Kata** | Write a small app that stores and retrieves a secret key using `flutter_secure_storage`. Verify it persists across app restarts. |
| 5.4 | **Form Kata** | Build a complex form with 6+ fields, validation, and submission. Test the form with widget tests. |

### Technical Skills Checklist

- [ ] Can configure Dio with interceptors for auth token management
- [ ] Can implement login/register screens with proper state management
- [ ] Can handle token refresh automatically and transparently
- [ ] Can build CRUD screens with loading, error, and empty states
- [ ] Can implement optimistic updates in the UI
- [ ] Can map between API models, domain entities, and UI state
- [ ] Can write integration tests for multi-screen flows

### Testing Strategy

- **Unit tests** for `AuthNotifier`, `TaskNotifier` (mock repositories)
- **Unit tests** for repository implementations (mock data sources)
- **Widget tests** for each screen (mock notifiers, verify rendering)
- **Integration tests** for critical flows (login → task CRUD)
- Use `MockDio` or `DioAdapter` to mock API responses in tests
- Test all states: loading, success, error, empty

### Common Mistakes to Avoid

- **Storing tokens in SharedPreferences** — use `flutter_secure_storage` for sensitive data
- **Not handling token expiry** — the Dio interceptor must transparently refresh tokens
- **Showing raw API errors to users** — map server errors to user-friendly messages
- **Not testing the error states** — users will see errors; make sure they look right
- **Forgetting to dispose notifiers** — Riverpod handles this, but verify with `autoDispose` providers

### Refactoring Checkpoint

Before moving to Phase 6:
- Review the data layer: are all API calls going through repositories?
- Verify error handling is consistent (all errors mapped to domain failures)
- Check that no screen directly uses Dio — everything goes through the repository layer
- Run both backend and frontend tests: `./gradlew test` and `flutter test`
- Manual test: start the backend, run the app on an emulator, and go through the full flow
- Look for duplicated UI patterns and extract shared widgets

### Definition of Done

- [ ] Login and registration work end-to-end (frontend ↔ backend)
- [ ] Token refresh works transparently
- [ ] Task CRUD screens are fully functional
- [ ] Loading, error, and empty states are handled on every screen
- [ ] Optimistic updates work for task operations
- [ ] Widget tests exist for all screens
- [ ] Unit tests exist for all notifiers and repositories
- [ ] All tests pass on both frontend and backend

---

## Phase 6 — Lists, Tags, Filtering & Search (Weeks 26–29)

**Goal:** Implement TodoLists and Tags on both backend and frontend, plus filtering and search. This phase exercises your full-stack skills — you'll go through the entire cycle (migration → domain → API → UI) multiple times.

### Learning Objectives

- Implement related entities (TodoList ↔ Task, Tag ↔ Task many-to-many)
- Build filtering and search with Spring Data JPA Specifications
- Implement drag-and-drop reordering
- Build filter/search UI with reactive state management
- Handle complex state with multiple interacting providers

### Week-by-Week Breakdown

#### Week 26: Backend — TodoList & Tags
- Flyway migrations:
  - `V4__create_todo_list_table.sql` — `id`, `name`, `color`, `position`, `user_id`, timestamps
  - `V5__create_tag_table.sql` — `id`, `name`, `color`, `user_id`, timestamps
  - `V6__create_task_tag_table.sql` — `task_id`, `tag_id` (junction table)
  - `V7__add_list_id_to_task.sql` — add `list_id` FK to tasks table
- Create domain models, JPA entities, repositories, use cases for TodoList and Tag
- Create REST endpoints:
  - `POST/GET/PUT/DELETE /api/v1/lists`
  - `POST/GET/PUT/DELETE /api/v1/tags`
  - `POST/DELETE /api/v1/tasks/{id}/tags/{tagId}` — assign/remove tag
- Write tests for all new endpoints

#### Week 27: Backend — Filtering & Search
- Add filtering to `GET /api/v1/tasks`:
  - Query params: `?status=TODO&priority=HIGH&tagId=xxx&listId=xxx&dueBefore=2025-12-31&dueAfter=2025-01-01&search=keyword`
- Implement using Spring Data JPA `Specification<Task>`:
  - Create `TaskSpecification` with static methods for each filter
  - Combine them with `and()` for multiple active filters
- Add full-text search using PostgreSQL `ILIKE` or `tsvector`
- Write tests for each filter individually and in combination
- Add reorder endpoint: `PUT /api/v1/lists/{id}/tasks/reorder` (accepts ordered list of task IDs)

#### Week 28: Frontend — Lists & Tags UI
- Create `TodoList` and `Tag` Freezed models
- Create data sources, repositories, and notifiers for lists and tags
- Build `ListsScreen`:
  - Display all lists with task count
  - Create new list (name + color picker)
  - Rename and delete lists
  - Tap list → navigate to filtered task view
- Build `TagManagementScreen`:
  - Display all tags
  - Create, rename, delete tags
  - Color picker for tags
- Add tag chips to `TaskEditScreen` (multi-select)
- Add list assignment dropdown to `TaskEditScreen`

#### Week 29: Frontend — Filtering & Search
- Build `FilterBar` widget:
  - Status filter chips (TODO, IN_PROGRESS, DONE)
  - Priority filter chips (LOW, MEDIUM, HIGH)
  - Date range picker
  - Tag multi-select dropdown
- Build search functionality:
  - Search bar with debounced input (300ms delay)
  - Search results integrated into the task list
- Add drag-and-drop reordering using `ReorderableListView`
- Write widget tests for filter interactions
- Write integration tests for search

### Side Katas

| # | Kata | Purpose |
|---|------|---------|
| 6.1 | **JPA Specification Kata** | In a scratch project, create a `ProductSpecification` with filters for category, price range, and name search. Combine them dynamically. |
| 6.2 | **Many-to-Many Kata** | Model Student ↔ Course many-to-many in JPA. Practice adding/removing relationships and querying from both sides. |
| 6.3 | **Drag & Drop Kata** | Build a simple Flutter list with `ReorderableListView`. Persist the new order to a notifier. |
| 6.4 | **Debounce Kata** | Implement a debounced search field in Flutter. Use a `Timer` or `rxdart` debounce. Write a test that verifies the debounce delay. |

### Technical Skills Checklist

- [ ] Can implement related entities with JPA (one-to-many, many-to-many)
- [ ] Can build dynamic query filters with JPA Specifications
- [ ] Can implement text search in PostgreSQL
- [ ] Can build filter/search UI with reactive state
- [ ] Can implement drag-and-drop reordering
- [ ] Can manage complex state with multiple Riverpod providers

### Testing Strategy

- **Backend:** Test each filter individually, then test combinations
- **Backend:** Test many-to-many relationships (assign tag, remove tag, query by tag)
- **Frontend:** Widget tests for filter bar interactions
- **Frontend:** Unit tests for filter notifier state transitions
- **End-to-end:** Create tasks with tags → filter by tag → verify results

### Common Mistakes to Avoid

- **N+1 queries** — when loading tasks with tags, use `@EntityGraph` or `JOIN FETCH` to avoid N+1
- **Not testing filter combinations** — individual filters may work but break when combined
- **Blocking the UI thread during search** — always debounce and use async
- **Hardcoding colors** — use a color picker or predefined palette for list/tag colors
- **Forgetting to cascade deletes** — when a list is deleted, decide: delete tasks or move to "Inbox"

### Refactoring Checkpoint

Before moving to Phase 7:
- Review your `Specification` code — is it readable and composable?
- Check for N+1 queries by enabling SQL logging: `spring.jpa.show-sql=true`
- Verify consistent error handling across all new endpoints
- Review the Flutter state management — are there any providers doing too much?
- Run full test suite on both sides
- Manual test: create lists, assign tags, filter, search, reorder

### Definition of Done

- [ ] TodoList CRUD works end-to-end (backend + frontend)
- [ ] Tag CRUD works end-to-end (backend + frontend)
- [ ] Tasks can be assigned to lists and tagged
- [ ] All filters work individually and in combination
- [ ] Text search works with debounce
- [ ] Drag-and-drop reorder persists to backend
- [ ] All tests pass on both backend and frontend
- [ ] No N+1 query issues

---

## Phase 7 — Offline-First (Weeks 30–33)

**Goal:** Make the Flutter app work without an internet connection. Implement local storage with Drift, a sync strategy, and conflict resolution. This is architecturally the most challenging phase.

### Learning Objectives

- Understand offline-first architecture and why it matters for mobile
- Implement local persistence with Drift (SQLite)
- Design a sync strategy (last-write-wins or timestamp-based)
- Handle conflict resolution when local and remote data diverge
- Implement background sync with connectivity detection

### Week-by-Week Breakdown

#### Week 30: Drift Setup & Local Storage
- Add `drift` and `drift_dev` dependencies
- Create Drift database with tables mirroring backend entities:
  - `tasks` table
  - `todo_lists` table
  - `tags` table
  - `task_tags` table
- Create DAOs (Data Access Objects) for each table
- Write tests for local CRUD operations
- Implement `TaskLocalDataSource` using Drift

#### Week 31: Repository Pattern — Dual Data Sources
- Refactor `TaskRepository` to work with both local and remote data sources:
  ```
  TaskRepository
  ├── TaskRemoteDataSource (Dio → backend)
  └── TaskLocalDataSource (Drift → SQLite)
  ```
- Strategy when online:
  1. Write to local DB immediately (optimistic)
  2. Sync to backend in background
  3. If backend rejects, revert local change
- Strategy when offline:
  1. Write to local DB
  2. Mark change as "pending sync"
  3. When connectivity returns, push pending changes
- Add a `sync_status` column to local tables: `synced`, `pending_create`, `pending_update`, `pending_delete`

#### Week 32: Sync Engine
- Create `SyncManager` that:
  - Listens to connectivity changes (`connectivity_plus` package)
  - On reconnect: push all pending changes to backend
  - On app start: pull latest data from backend, merge with local
  - Handles ordering: create before update, update before delete
- Implement timestamp-based conflict resolution:
  - Each entity has `updated_at`
  - If remote `updated_at` > local `updated_at`, remote wins
  - If local `updated_at` > remote `updated_at`, local wins
  - Log conflicts for debugging
- Create `SyncNotifier` (Riverpod) that exposes sync state to UI:
  - `syncing`, `synced`, `offline`, `error`

#### Week 33: UI Integration & Testing
- Add a sync status indicator to the app bar (icon showing sync state)
- Show "offline" banner when no connectivity
- Show pending sync count badge
- When offline, all CRUD still works (local only)
- When back online, sync happens automatically
- Write comprehensive tests:
  - Unit tests for `SyncManager` logic
  - Integration tests for the dual-source repository
  - Widget tests for offline indicator UI
- Manual testing scenario: turn off Wi-Fi → create tasks → turn on Wi-Fi → verify sync

### Side Katas

| # | Kata | Purpose |
|---|------|---------|
| 7.1 | **Drift CRUD Kata** | Build a standalone Drift database with one table. Implement create, read, update, delete, and watch (reactive queries). Test each operation. |
| 7.2 | **Connectivity Kata** | Build a simple app that displays "Online" / "Offline" based on `connectivity_plus`. Change network state and watch it update. |
| 7.3 | **Conflict Resolution Kata** | Simulate two "clients" modifying the same object. Implement last-write-wins. Write tests that verify the correct version survives. |
| 7.4 | **Queue Kata** | Implement a simple operation queue in Dart (FIFO). Add items while "offline", process them when "online". Handle failures with retry. |

### Technical Skills Checklist

- [ ] Can set up Drift with typed tables, DAOs, and reactive queries
- [ ] Can implement the repository pattern with dual data sources
- [ ] Can detect connectivity changes and trigger sync
- [ ] Can implement timestamp-based conflict resolution
- [ ] Can build a sync queue that processes pending operations
- [ ] Can show sync state in the UI

### Testing Strategy

- **Unit tests** for `SyncManager` (mock both data sources, simulate conflicts)
- **Unit tests** for conflict resolution logic
- **Integration tests** for Drift DAOs (in-memory SQLite)
- **Widget tests** for offline indicator and sync status
- **Manual testing checklist:**
  - [ ] Create task offline → goes to pending
  - [ ] Reconnect → task syncs to backend
  - [ ] Edit task on backend → pull updates locally
  - [ ] Edit same task on both sides → correct version wins

### Common Mistakes to Avoid

- **Not tracking sync status per entity** — you need to know which specific items need syncing
- **Syncing everything on every reconnect** — only sync pending changes, not the entire database
- **Ignoring conflict resolution** — "last write wins" is simple but you need to implement it deliberately
- **Not testing offline scenarios** — this is the core feature; test it thoroughly
- **Blocking the UI during sync** — sync must happen in background; UI stays responsive

### Refactoring Checkpoint

Before moving to Phase 8:
- Review the sync engine — is it robust? Does it handle failures and retries?
- Verify all previous CRUD operations still work identically in both online and offline modes
- Check that the local database schema matches the backend schema
- Ensure no data is lost during sync (write integration tests for this)
- Profile the sync — does it cause UI jank? Consider isolating it with `compute()`

### Definition of Done

- [ ] Drift database is set up with all entity tables
- [ ] All CRUD operations work offline
- [ ] Pending changes are tracked and synced on reconnect
- [ ] Conflict resolution works (last-write-wins based on timestamp)
- [ ] Sync status is visible in the UI
- [ ] Comprehensive tests cover sync scenarios
- [ ] All tests pass: `flutter test`
- [ ] Manual testing confirms the full offline → online cycle works

---

## Phase 8 — Advanced Features (Weeks 34–37)

**Goal:** Add real-time updates, local notifications, and an analytics dashboard. These features round out the app and demonstrate advanced technical skills.

### Learning Objectives

- Implement server-sent events (SSE) or WebSocket for real-time updates
- Schedule and display local notifications
- Build a data visualization dashboard
- Handle background tasks in Flutter

### Week-by-Week Breakdown

#### Week 34: Backend — Real-Time Updates
- Choose between WebSocket and SSE (SSE recommended for this use case — simpler, one-directional)
- Implement SSE endpoint: `GET /api/v1/events/tasks`
  - Stream task change events (created, updated, deleted) to connected clients
  - Include the changed task data in each event
- Use Spring's `SseEmitter` or WebFlux `Flux<ServerSentEvent>`
- Add authentication to the SSE endpoint (Bearer token as query param or header)
- Write tests that verify events are emitted on task changes

#### Week 35: Frontend — Real-Time Updates
- Connect to the SSE endpoint using Dio streaming or `EventSource`
- When a task event arrives:
  - Update the local Drift database
  - Notify the UI via Riverpod
  - Show a subtle animation for new/updated items
- Handle reconnection: if the SSE connection drops, reconnect with exponential backoff
- Only connect when the app is in the foreground (disconnect on background)
- Write tests for the event handling logic

#### Week 36: Notifications
- Backend: Add `reminder_at` field to tasks (Flyway migration)
- Frontend: Add `flutter_local_notifications` dependency
- Implement notification scheduling:
  - When a task has a `reminder_at`, schedule a local notification
  - When a task is updated/deleted, cancel/reschedule the notification
  - When the user taps a notification, navigate to the task detail screen
- Create a `NotificationService` that manages scheduling/canceling
- Add a "Set Reminder" option to the task edit screen (date + time picker)
- Write tests for notification scheduling logic

#### Week 37: Analytics Dashboard
- Backend: Create analytics endpoints:
  - `GET /api/v1/analytics/summary` — total tasks, completed, overdue, by priority
  - `GET /api/v1/analytics/completion-rate` — tasks completed per day/week/month
  - `GET /api/v1/analytics/by-tag` — task count per tag
- Frontend: Build `AnalyticsScreen`:
  - Summary cards (total, completed, overdue, completion rate)
  - Bar chart: tasks completed per week (use `fl_chart` package)
  - Pie chart: tasks by priority
  - Tag breakdown list
- Wire up to real data via the analytics API
- Write widget tests for the analytics screen

### Side Katas

| # | Kata | Purpose |
|---|------|---------|
| 8.1 | **SSE Kata** | Build a simple Spring Boot SSE endpoint that emits a counter every second. Build a Flutter client that displays the counter in real-time. |
| 8.2 | **Notification Kata** | Build a Flutter app that schedules a notification for 10 seconds from now. Tap the notification and navigate to a specific screen. |
| 8.3 | **Chart Kata** | Using `fl_chart`, create a bar chart and a pie chart with hardcoded data. Customize colors, labels, and animations. |
| 8.4 | **Exponential Backoff Kata** | Implement a retry function with exponential backoff (1s, 2s, 4s, 8s, max 30s). Write tests that verify the delay sequence. |

### Technical Skills Checklist

- [ ] Can implement SSE on the backend and consume it in Flutter
- [ ] Can handle real-time UI updates via streaming
- [ ] Can schedule and manage local notifications
- [ ] Can build data visualizations with `fl_chart`
- [ ] Can implement exponential backoff for reconnection
- [ ] Can create analytics API endpoints with aggregate queries

### Testing Strategy

- **Backend:** Integration tests for SSE endpoints (verify events emit on task changes)
- **Backend:** Tests for analytics queries (seed data, verify aggregations)
- **Frontend:** Unit tests for event handling and notification scheduling
- **Frontend:** Widget tests for analytics charts (verify they render with given data)
- Manual testing for notifications (scheduling, tap-to-navigate, cancellation)

### Common Mistakes to Avoid

- **Not handling SSE disconnection** — mobile networks are unreliable; always implement reconnection
- **Scheduling duplicate notifications** — always cancel before rescheduling
- **Blocking the UI with analytics queries** — aggregate queries can be slow; use loading states
- **Not scoping real-time events to the current user** — verify the SSE connection is authenticated
- **Over-engineering the analytics** — simple aggregate queries are fine; no need for a data warehouse

### Refactoring Checkpoint

Before moving to Phase 9:
- Review SSE reconnection logic — is it robust?
- Verify notifications work on both Android and iOS
- Check analytics queries for performance (add database indexes if needed)
- Ensure real-time updates don't conflict with the offline sync engine
- Run full test suite on both sides

### Definition of Done

- [ ] Real-time task updates work via SSE
- [ ] SSE reconnects automatically on disconnection
- [ ] Local notifications fire at scheduled times
- [ ] Tapping a notification navigates to the correct task
- [ ] Analytics dashboard shows summary, charts, and tag breakdown
- [ ] All tests pass on both backend and frontend

---

## Phase 9 — Polish & DevOps (Weeks 38–40)

**Goal:** Set up CI/CD, add dark mode and animations, and prepare the app for production. This phase is about quality, automation, and the finishing touches.

### Learning Objectives

- Set up GitHub Actions for automated testing and building
- Configure Docker for production-like deployment
- Implement dark mode with proper theming
- Add meaningful animations and transitions
- Understand production readiness: logging, monitoring, health checks

### Week-by-Week Breakdown

#### Week 38: CI/CD with GitHub Actions
- Create `.github/workflows/backend.yml`:
  - Trigger on push and PR to `main`
  - Steps: checkout, set up JDK 21, run `./gradlew test`, run `./gradlew build`
  - Cache Gradle dependencies
  - Report test results
- Create `.github/workflows/frontend.yml`:
  - Trigger on push and PR to `main`
  - Steps: checkout, set up Flutter, run `flutter pub get`, run `flutter test`, run `flutter build apk`
  - Cache Flutter/pub dependencies
- Create `.github/workflows/docker.yml`:
  - Build and push Docker image on merge to `main`
- Add status badges to the project README
- Ensure all current tests pass in CI

#### Week 39: Docker & Production Config
- Create `Dockerfile` for the Spring Boot backend:
  - Multi-stage build: Gradle build → JRE runtime image
  - Non-root user, health check
- Update `docker-compose.yml` for production-like setup:
  - Backend service (from Dockerfile)
  - PostgreSQL with persistent volume
  - Environment variables for configuration (no hardcoded secrets)
- Add production `application-prod.yml`:
  - Connection pool tuning (HikariCP)
  - Proper logging configuration (JSON format for log aggregation)
  - Actuator endpoints for health and metrics
- Create a `docker-compose.prod.yml` override for production settings
- Add Spring Boot Actuator with `/actuator/health` endpoint
- Write a smoke test script that starts Docker Compose and verifies the health endpoint

#### Week 40: Dark Mode & Animations
- Implement a theme system:
  - `AppTheme` class with `lightTheme` and `darkTheme`
  - Use `ThemeData` with Material 3 design
  - Custom color schemes for both themes
  - Create a `ThemeNotifier` (Riverpod) that persists the user's choice
- Add meaningful animations:
  - Task list item enter/exit animations (`AnimatedList`)
  - Page transition animations (`GoRouter` custom transitions)
  - Task completion celebration (confetti or checkmark animation)
  - Shimmer loading effect for skeleton screens
  - Hero animations for task detail transitions
- Add haptic feedback for important actions (complete task, delete task)

### Side Katas

| # | Kata | Purpose |
|---|------|---------|
| 9.1 | **GitHub Actions Kata** | Create a workflow that runs a simple test suite. Add a badge to the README. Trigger it manually and on push. |
| 9.2 | **Multi-stage Docker Kata** | Build a multi-stage Dockerfile for a Spring Boot app. Compare the image size with and without multi-stage. |
| 9.3 | **Animation Kata** | Build 3 Flutter animations: a fade-in, a slide transition, and an animated counter. Use both implicit and explicit animations. |
| 9.4 | **Theming Kata** | Create a Flutter app with full light/dark mode support. Use `ThemeExtension` for custom colors. Persist the setting with shared preferences. |

### Technical Skills Checklist

- [ ] Can set up GitHub Actions for automated testing and building
- [ ] Can create a multi-stage Dockerfile for a Spring Boot app
- [ ] Can configure Docker Compose for production-like deployment
- [ ] Can implement light/dark theme with persistence
- [ ] Can add meaningful animations (implicit and explicit)
- [ ] Can configure Spring Boot Actuator for health checks
- [ ] Can set up proper production logging

### Testing Strategy

- **CI testing:** All existing tests must pass in GitHub Actions
- **Docker testing:** Smoke test script verifies the app starts and responds
- **Theme testing:** Widget tests verify both light and dark theme render correctly
- **Animation testing:** Widget tests verify animations complete without errors
- **Production readiness:** Actuator health check returns UP

### Common Mistakes to Avoid

- **Not caching dependencies in CI** — builds will be painfully slow without caching
- **Running Docker as root** — always use a non-root user in production Dockerfiles
- **Hardcoding themes** — use `Theme.of(context)` everywhere, not hardcoded colors
- **Overdoing animations** — animations should enhance UX, not distract. Keep them under 300ms
- **Forgetting to test in CI** — if tests don't run in CI, they'll be broken without anyone noticing

### Refactoring Checkpoint

Before moving to Phase 10:
- Verify CI pipelines are green
- Run the Docker Compose production setup and verify everything works
- Review all hardcoded colors and replace with theme-aware references
- Ensure animations feel snappy, not sluggish
- Run a final full test suite locally: `./gradlew test` and `flutter test`
- Check logging output — is it useful for debugging?

### Definition of Done

- [ ] GitHub Actions CI/CD runs on every push and PR
- [ ] Backend Docker image builds successfully with multi-stage Dockerfile
- [ ] `docker-compose up` starts the full stack (backend + PostgreSQL)
- [ ] Dark mode works with persistent theme preference
- [ ] Animations are smooth and enhance the UX
- [ ] Spring Boot Actuator health endpoint responds
- [ ] All tests pass in CI
- [ ] No hardcoded secrets in the codebase

---

## Phase 10 — Portfolio Packaging (Weeks 41–42)

**Goal:** Package the entire project as a portfolio piece. Write a stellar README, record a demo, and make the project easy for recruiters and developers to understand and run.

### Learning Objectives

- Write clear, professional technical documentation
- Create an effective demo presentation
- Understand what makes a strong portfolio project
- Clean up and finalize the codebase

### Week-by-Week Breakdown

#### Week 41: Documentation & Cleanup
- Write a comprehensive `README.md`:
  - Project overview with screenshots
  - Tech stack with version numbers
  - Architecture diagram (create with Excalidraw or draw.io)
  - Features list with checkmarks
  - Prerequisites and setup instructions (step-by-step)
  - How to run locally (backend + frontend)
  - How to run tests
  - API documentation link (Swagger)
  - Folder structure explanation
  - Design decisions and trade-offs
  - License
- Clean up the codebase:
  - Remove unused code, commented-out code, TODOs
  - Ensure consistent code formatting (use `spotless` for Java, `dart format` for Dart)
  - Add missing Javadoc/dartdoc to public APIs
  - Verify all tests still pass after cleanup
- Update `SPEC.md` with any deviations from the original plan

#### Week 42: Demo & Deployment
- Record a 3–5 minute demo video showing:
  - Registration and login
  - Creating, editing, completing, and deleting tasks
  - Lists and tags
  - Filtering and search
  - Offline mode (turn off connectivity, show it still works)
  - Real-time updates (show changes appearing from another source)
  - Dark mode toggle
  - Analytics dashboard
- Add the demo video to the README (as a GIF or YouTube link)
- Optional: Deploy to a cloud provider:
  - Backend: Railway, Render, or Fly.io (free tier)
  - Database: Supabase or Railway PostgreSQL
  - Create a live demo link
- Final review:
  - Go through every screen as a user
  - Check for any UI/UX issues
  - Verify the setup instructions work from scratch (clone → run)

### Deliverables Checklist

- [ ] Professional `README.md` with screenshots and architecture diagram
- [ ] 3–5 minute demo video
- [ ] All tests passing in CI (green badges)
- [ ] Docker setup works with single `docker-compose up`
- [ ] Codebase is clean, formatted, and documented
- [ ] Git history is clean and meaningful (no "fix typo" commits in main)
- [ ] Swagger documentation is accessible
- [ ] (Optional) Live deployment URL

### What Makes This Portfolio-Grade

By completing this roadmap, your project demonstrates:

| Skill | Evidence |
|-------|----------|
| **Backend engineering** | Spring Boot, Hexagonal Architecture, JWT auth, pagination, filtering |
| **Frontend development** | Flutter, Clean Architecture, Riverpod, offline-first, animations |
| **Database design** | PostgreSQL, Flyway migrations, JPA relationships, Drift local DB |
| **Testing discipline** | TDD throughout, unit/integration/widget/e2e tests, Testcontainers |
| **DevOps** | Docker, Docker Compose, GitHub Actions CI/CD, production config |
| **API design** | RESTful API, OpenAPI/Swagger docs, versioned endpoints, consistent errors |
| **Security** | JWT, BCrypt, token refresh, rate limiting, user data isolation |
| **Real-time** | SSE for live updates, reconnection with backoff |
| **Offline-first** | Drift local DB, sync engine, conflict resolution |
| **Code quality** | Clean Architecture on both ends, domain-driven design, no framework leakage |

---

## Appendix A: Weekly Time Allocation Template

For a 15-hour week (adjust proportionally):

| Activity | Hours | Notes |
|----------|-------|-------|
| Learning (reading/videos) | 3 | Frontload at the beginning of the week |
| Side kata | 2 | One kata per week minimum |
| Main implementation | 7 | TDD: test first, then implement |
| Refactoring & review | 2 | End of week: clean up, review tests |
| Git housekeeping | 1 | Clean commits, PR descriptions |

---

## Appendix B: Recommended Resources

### Java & Spring Boot
- [Baeldung](https://www.baeldung.com/) — comprehensive Spring Boot tutorials
- [Spring Boot Reference Docs](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [Testcontainers Docs](https://www.testcontainers.org/)
- "Clean Architecture" by Robert C. Martin (book)

### Flutter & Dart
- [Flutter Official Docs](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/language)
- [Riverpod Docs](https://riverpod.dev/)
- [Drift Docs](https://drift.simonbinder.eu/)
- [Andrea Bizzotto's tutorials](https://codewithandrea.com/) — excellent Flutter architecture content

### Testing
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- "Test Driven Development: By Example" by Kent Beck (book)

### Architecture
- [Hexagonal Architecture Explained](https://alistair.cockburn.us/hexagonal-architecture/) — the original article
- [Clean Architecture for Flutter](https://resocoder.com/flutter-clean-architecture-tdd/) — ResoCoder tutorial series

### DevOps
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Getting Started](https://docs.docker.com/get-started/)
- [Flyway Documentation](https://flywaydb.org/documentation/)

---

## Appendix C: Progress Tracking

Use this checklist to track your overall progress:

- [ ] **Phase 0** — Foundation (Weeks 1–4)
- [ ] **Phase 1** — Backend Skeleton (Weeks 5–8)
- [ ] **Phase 2** — Core Backend CRUD (Weeks 9–12)
- [ ] **Phase 3** — Authentication (Weeks 13–16)
- [ ] **Phase 4** — Flutter Foundation (Weeks 17–20)
- [ ] **Phase 5** — Flutter Meets Backend (Weeks 21–25)
- [ ] **Phase 6** — Lists, Tags, Filtering & Search (Weeks 26–29)
- [ ] **Phase 7** — Offline-First (Weeks 30–33)
- [ ] **Phase 8** — Advanced Features (Weeks 34–37)
- [ ] **Phase 9** — Polish & DevOps (Weeks 38–40)
- [ ] **Phase 10** — Portfolio Packaging (Weeks 41–42)

**Estimated total time:** 42 weeks at 10–20 hours/week

> Remember: the timeline is a guide, not a deadline. Some phases will go faster, some slower. The important thing is to never skip testing and never skip the refactoring checkpoints. Quality over speed, always.
