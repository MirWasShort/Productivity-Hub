# Code Review — Smart TODO App

**Date:** 2026-07-19
**Scope:** full read of `backend/src/main` (~90 files), Flyway migrations, `application.yml`, `build.gradle.kts`, all hand-written `frontend/lib` sources (~65 files), `pubspec.yaml`, `analysis_options.yaml`, `docker-compose.yml`; test suites skimmed for coverage on both sides.
**Overall:** the architecture is in good shape — the hexagonal boundaries on the backend hold (framework-free domain records, JPA entities never escape persistence), and the frontend keeps a clean model/entity split with no presentation→data imports. The findings below are ranked by severity; none require an architectural rewrite.

Severity: **Critical** (security or data-loss bug) · **High** (user-visible bug) · **Medium** (correctness/performance/API-design debt) · **Low** (smells, consistency, hygiene).
Effort: **S** (< 1 h) · **M** (half day) · **L** (a day or more).

---

## Summary

| ID | Severity | Effort | Finding |
|----|----------|--------|---------|
| B-01 | Critical | M | Refresh-token rotation race — no atomic revoke, no reuse detection |
| B-02 | Critical | S | Known-default JWT secret can boot in production |
| B-03 | Critical | S | DB credentials hard-coded and not overridable |
| B-04 | High | S | Pagination: negative `page`/`size` → 500; `size` uncapped |
| B-05 | High | M | Account enumeration (register 409 + login timing side-channel) |
| B-06 | High | M | No optimistic locking; assigned-UUID saves always merge |
| B-07 | High | M | Refresh tokens never revoked on new login, never purged |
| F-01 | Critical | M | Edit route silently degrades to "create" → duplicate tasks |
| F-02 | High | M | Detail screen never fetches by id — false "Task non trovato" |
| F-03 | High | M | Calendar shows stale data after any mutation |
| F-04 | High | S | Date-only tasks due today always render as overdue |
| F-05 | High | M | 401 replay has no retry marker — refresh/replay loop possible |
| F-06 | High | M | Fire-and-forget mutations: failures invisible to the user |
| F-07 | High | S | Enum parsing throws unmapped `StateError` on unknown values |
| B-08 | Medium | M | Analytics hard-coded to UTC — "due today" wrong off-UTC |
| B-09 | Medium | S | N+1 query resolving tags on task create/update |
| B-10 | Medium | M | Analytics summary issues ~6 separate queries |
| B-11 | Medium | S | Missing composite indexes for filter/sort/analytics paths |
| B-12 | Medium | S | Email never normalized; uniqueness is case-sensitive |
| B-13 | Medium | S | `IllegalArgumentException` / integrity violations → opaque 500 |
| B-14 | Medium | S | API contract drift: priority optional-vs-required, `completedAt` dropped, `fieldErrors: null` |
| B-15 | Medium | S | Enum FQNs embedded in JPQL strings |
| B-16 | Medium | S | CORS/Swagger permanently dev-shaped; no profiles |
| F-08 | Medium | M | Auth notifier hand-invalidates six other features' providers |
| F-09 | Medium | S | Router (core) reads a feature presentation provider |
| F-10 | Medium | M | No `autoDispose` anywhere; state lives forever |
| F-11 | Medium | M | Full refetch per filter change; `createTask` prepends ignoring sort/filter |
| F-12 | Medium | M | Raw `'$error'` dumps; three inconsistent error-display patterns |
| F-13 | Medium | S | `Task.copyWith` cannot clear `dueDate` |
| F-14 | Medium | S | `sessionExpiredProvider` bool-flag+reset as one-shot signal |
| F-15 | Medium | S | Non-Dio decode errors bypass `Failure` mapping |
| B-17 | Low | S–M | Backend smells: dead `TaskQuery` builder, triplicated `requireOwnX`, DTO/mapper duplication, magic values |
| F-16 | Low | S–M | Frontend smells: quadruplicated `_guard`, duplicated label maps, magic numbers vs `Dimens`, inline borders |
| F-17 | Low | M | Hardcoded Italian strings, no l10n; accessibility gaps |
| X-01 | Low | S | Tooling: pre-release freezed pin, default-only lints, placeholder pubspec |
| T-01 | — | M | Test gaps (backend) |
| T-02 | — | M | Test gaps (frontend) |

---

## Critical / High

### B-01 · Refresh-token rotation race (no atomic guard, no reuse detection)
**Location:** `backend/src/main/java/com/smarttodo/application/service/AuthService.java:74-88`
**Problem:** `refresh()` does read (`findByTokenHash`) → check (`isUsable()`) → write (`save(stored.revoke())`) with no atomic guard. Under the default `READ_COMMITTED` isolation, two concurrent requests presenting the same refresh token both pass `isUsable()` and both mint new token pairs. Worse, presenting an already-revoked token is treated as a plain invalid token — there is no reuse detection, so a stolen-then-replayed token does not invalidate the token family, which defeats the stated purpose of rotation (`RefreshTokenUseCase.java:3-6`).
**Fix:** make revocation conditional and atomic — e.g. a modifying query `UPDATE refresh_tokens SET revoked = true WHERE token_hash = ? AND revoked = false` and only issue new tokens when it reports 1 row updated (or add `@Version` to `RefreshTokenJpaEntity`). On detecting reuse (token found but already revoked), revoke all of the user's refresh tokens. Add a concurrent test (two threads, one token, exactly one winner).

### B-02 · Known-default JWT secret can boot in production
**Location:** `backend/src/main/resources/application.yml:27`
**Problem:** `secret: ${APP_JWT_SECRET:dev-only-secret-change-me-0123456789abcdef}`. If the env var is unset, the app signs tokens with a key that is committed to the repo. There are no Spring profiles at all, so nothing distinguishes dev from prod or forces an override.
**Fix:** move the fallback into a `dev`-only profile (`application-dev.yml`) and leave `app.jwt.secret: ${APP_JWT_SECRET}` unset by default so a missing secret fails startup; alternatively add a startup check that refuses the known default outside dev.

### B-03 · DB credentials hard-coded and not overridable
**Location:** `backend/src/main/resources/application.yml:10-12`
**Problem:** `url`/`username`/`password` are plain literals (`smarttodo`/`smarttodo`) with no `${...}` indirection — inconsistent with `SERVER_PORT` and `APP_JWT_SECRET` on the same file, and impossible to point at another database without editing sources.
**Fix:** `url: ${SPRING_DATASOURCE_URL:jdbc:postgresql://localhost:5432/smarttodo}` etc. (dev defaults are fine as fallbacks; they must just be overridable). Same values also live in `docker-compose.yml:6-8` — fine for a dev-only compose file, but worth a comment saying so.

### B-04 · Pagination: negative values → 500, size uncapped
**Location:** `backend/src/main/java/com/smarttodo/adapter/in/web/TaskController.java:71-87`
**Problem:** raw `int page`/`int size` flow into `PageRequest.of(page, size)` (`TaskPersistenceAdapter.java:37`). Negative values throw `IllegalArgumentException`, which `GlobalExceptionHandler` doesn't map, so the client gets a 500 for a bad query param. There is also no upper bound on `size` — `?size=1000000` fetches unbounded rows. Contrast with `AnalyticsService.java:37`, which politely clamps `days` to `[1, 365]`: two endpoints, two input-hardening policies.
**Fix:** `@Validated` on the controller with `@Min(0) page`, `@Min(1) @Max(100) size` (named constants), plus a `ConstraintViolationException` handler returning 400 (see B-13).

### B-05 · Account enumeration: register response + login timing
**Location:** `backend/src/main/java/com/smarttodo/application/service/AuthService.java:46-48, 62-67`
**Problem:** two leaks. (1) Register throws `EmailAlreadyExistsException(email)`, rendered as a 409 "Email already registered: …" — a direct membership oracle. (2) Login skips BCrypt entirely when the email is unknown (throws before `passwordHasher.matches`), so unknown emails answer measurably faster than known ones (BCrypt cost ~10). Login's message is correctly generic; the timing isn't. There is also no rate limiting anywhere on `/api/v1/auth/**` (`SecurityConfig.java:39` is `permitAll`), which makes both oracles cheap to exploit at scale.
**Fix:** on unknown email, run `passwordHasher.matches` against a precomputed dummy hash before throwing. For register, either accept the leak consciously (common product trade-off — document it) or switch to the "always 200/202, email-based confirmation" pattern. Add rate limiting (e.g. bucket4j filter) on the auth endpoints.

### B-06 · No optimistic locking; assigned-UUID saves always merge
**Location:** all JPA entities, e.g. `backend/src/main/java/com/smarttodo/adapter/out/persistence/TaskJpaEntity.java:24-25`; read-modify-write in `TaskService.java:69-77`
**Problem:** no entity carries `@Version`, so concurrent edits of the same task are last-write-wins with silent data loss. Separately, because IDs are client-assigned UUIDs and there is no version/`Persistable`, Spring Data treats every `save()` as a potential update and calls `merge()` — one extra SELECT before every INSERT, in every adapter.
**Fix:** add a `version` column (new migration) + `@Version` field to mutable entities and surface `OptimisticLockingFailureException` as 409. That same field fixes the merge problem for free (new entities have `version == null` → treated as new, no pre-SELECT).

### B-07 · Refresh tokens accumulate: no revocation on login, no purge
**Location:** `backend/src/main/java/com/smarttodo/application/service/AuthService.java:90-99`; `V2__create_refresh_token_table.sql`
**Problem:** every login/register issues a fresh refresh token without bounding or revoking earlier ones, and revoked/expired rows are never deleted — the table only grows, and a user's number of live sessions is unbounded. There is no index on `expires_at` for any future cleanup either.
**Fix:** add a scheduled purge (`DELETE WHERE expires_at < now() OR revoked = true`), index `expires_at`, and decide a session policy (cap concurrent refresh tokens per user, or revoke-all on password change at minimum).

### F-01 · Edit route silently degrades to "create" → duplicate tasks
**Location:** `frontend/lib/core/router/app_router.dart:84-91`; `frontend/lib/features/task/presentation/screens/task_edit_screen.dart:34`
**Problem:** the `/tasks/:id/edit` builder looks the task up in the in-memory `taskListProvider` and passes whatever it finds to `TaskEditScreen(task: task)`. If the list is still loading, filtered so the task isn't in it, or the route was deep-linked, `task` is `null` — and `TaskEditScreen` interprets `task == null` as *new-task mode*. Saving then **creates a duplicate** instead of updating. This is the most damaging frontend bug because it corrupts data silently.
**Fix:** fetch the task by id. The whole `getById` path already exists and is dead code (`task_repository.dart:8`, `task_repository_impl.dart:31-32`, `task_remote_data_source.dart:51-54`) — add a `FutureProvider.family` on top of it, make the edit (and detail, F-02) screens consume it, and fall back to an explicit error screen when the id doesn't resolve. Never let a missing lookup flip the screen into create mode.

### F-02 · Detail screen never fetches by id
**Location:** `frontend/lib/features/task/presentation/screens/task_detail_screen.dart:54-66`
**Problem:** same root cause as F-01: the detail screen resolves its task only from `taskListProvider`'s current contents, so any valid task that is filtered out (or beyond the loaded page) renders as "Task non trovato".
**Fix:** same `getById`-based provider as F-01.

### F-03 · Calendar shows stale data after any mutation
**Location:** `frontend/lib/features/calendar/presentation/providers/calendar_notifier.dart:10-12`
**Problem:** `calendarTasksProvider` is an independent `FutureProvider` that fetches all tasks once and is only invalidated on logout (`auth_notifier.dart:74`). Toggling a checkbox on a calendar card goes through `taskListProvider.notifier.updateTask` (`task_card.dart:50-52`), which updates the *list* provider only; creating a task from the calendar FAB never refreshes the calendar either. Two parallel sources of truth for the same server data guarantee divergence.
**Fix:** either derive the calendar from `taskListProvider`'s repository layer with shared invalidation, or (simpler) `ref.invalidate(calendarTasksProvider)` inside `TaskListNotifier.createTask/updateTask/deleteTask`. Long-term, a single task-cache provider that both screens project from. Note the provider also uses `ref.read` where a provider body should `ref.watch`.

### F-04 · Date-only tasks due today always render as overdue
**Location:** `frontend/lib/features/task/domain/services/due_grouping.dart:47` (and `isOverdue`, `:29-32`); picker at `task_edit_screen.dart:109-118`
**Problem:** the date picker produces local midnight (no time component), while classification uses `due.isBefore(now)` with the current wall-clock time. From 00:00 onward, every task due *today* is bucketed as `overdue` and painted with the red warning style (`task_card.dart:82-100`). The unit test bakes this in (`due_grouping_test.dart:34-38`), so it's a design mismatch rather than a typo — but the visible behavior ("everything I planned for today is already late at breakfast") is wrong.
**Fix:** compare calendar days for date-only dues: overdue ⇔ `dueDay.isBefore(today)`. If time-of-day dues are ever wanted, model "has explicit time" separately. Update the test to pin the new rule.

### F-05 · 401 replay has no retry marker — refresh/replay loop possible
**Location:** `frontend/lib/core/network/auth_interceptor.dart:68-71`; wiring at `api_client.dart:38` (`retryClient: dio`)
**Problem:** the replay goes through the same intercepted Dio instance. If the replayed request 401s again (server-side revocation, clock skew, deleted user), it re-enters `onError`, performs *another* refresh (rotating the token each time), and replays again — the cycle only ends when a refresh call itself fails. `QueuedInterceptor` serializes the 401s (good), but there is no "already retried once" marker on the request.
**Fix:** set a flag in `err.requestOptions.extra` (e.g. `retried: true`) before replaying and pass straight through to `handler.next(err)` when it's already set. Also note `RequestOptions` replay does not re-send streamed bodies — irrelevant today (JSON only), worth a comment. Add tests for the replay-401s-again case and for two concurrent 401s sharing one refresh.

### F-06 · Fire-and-forget mutations: failures invisible, state silently stale
**Location:** checkbox `task_card.dart:47-53`; `deleteList` `app_shell.dart:170`; `deleteTag` `tag_management_screen.dart:47-48`; `createList`/`renameList`/`deleteList` `todo_lists_notifier.dart:17-38`; `logout` `app_shell.dart:133`
**Problem:** these async notifier methods are invoked without `await` or any error handling. The mutations are server-first (they only touch state after the call succeeds), so state doesn't corrupt — but on failure the exception is simply unhandled: the checkbox doesn't move, nothing tells the user why, and the tapped UI appears dead. Only two flows handle failure properly: `deleteTask` (optimistic with rollback, `task_list_notifier.dart:55-63`) and the edit form (`task_edit_screen.dart:72-106`).
**Fix:** route every user-triggered mutation through one helper that awaits, catches `Failure`, and surfaces a SnackBar (with retry where it makes sense). Extend the rollback pattern of `deleteTask` to the other optimistic-feeling interactions (checkbox toggle especially).

### F-07 · Enum parsing throws unmapped `StateError` on unknown values
**Location:** `frontend/lib/features/task/data/models/task_model.dart:22-26`
**Problem:** `taskStatusFromJson`/`taskPriorityFromJson` use `firstWhere` with no `orElse`. Any new or unexpected enum string from the backend throws `StateError` — which is not a `DioException`, so it sails past the repository `_guard`/`Failure.fromDio` and reaches the UI as a raw unhandled error. One backend enum addition bricks the task list for old clients.
**Fix:** add `orElse` with a safe default (e.g. `TaskStatus.todo`) or map to a typed parse failure. See also F-15 for the general non-Dio gap.

---

## Medium

### Backend

**B-08 · Analytics hard-coded to UTC.** `AnalyticsService.java:39-40`, `AnalyticsPersistenceAdapter.java:40-49,56-64` compute "today", `dueToday` and daily completion buckets in `ZoneOffset.UTC`; no user timezone exists anywhere. Anyone west of UTC sees tomorrow's numbers in the evening. *Fix:* accept a `zone` (or `X-Timezone` header / user setting) and bucket in that zone; test the boundary. Related: the `from`/`to` window arithmetic in `AnalyticsService.java:38-40` has untested off-by-one edges.

**B-09 · N+1 resolving tags.** `TaskService.resolveOwnedTags` (`TaskService.java:99-105`) runs one `findByIdAndUserId` per tag id on every task create/update. *Fix:* single `findAllByIdInAndUserId(ids, userId)` + set-difference to detect missing/foreign tags.

**B-10 · Analytics summary = ~6 round trips.** `AnalyticsPersistenceAdapter.summary` (`AnalyticsPersistenceAdapter.java:27-53`) fires separate queries for total, completed, overdue, dueToday, by-status, by-priority. *Fix:* one grouped query for the status/priority maps + one conditional-aggregate query (`COUNT(*) FILTER (WHERE …)`) for the scalars.

**B-11 · Missing composite indexes.** Only `idx_tasks_user_id` exists (`V3__create_task_table.sql:13`), while queries filter/sort by `(user_id, status)`, `(user_id, due_date)`, `(user_id, completed_at)` (filters + analytics). Harmless today, a scan-per-request at scale. *Fix:* migration `V9__add_task_indexes.sql`.

**B-12 · Email case-sensitivity.** `AuthService.register` stores email verbatim; `users.email UNIQUE` (V1) is case-sensitive, so `Alice@x.com` and `alice@x.com` are distinct accounts and login requires the original casing — inconsistent with tags, which are deliberately case-folded via `lower(name)` (V5). *Fix:* normalize (`trim().toLowerCase()`) at the service boundary + a `lower(email)` unique index migration; decide a backfill story for existing rows.

**B-13 · Unhandled exception classes → opaque 500s.** `GlobalExceptionHandler` covers validation, unreadable body, type mismatch and the domain exceptions, but generic `IllegalArgumentException` (B-04) and `DataIntegrityViolationException` (unique-constraint races on email/tag) fall through to `handleUnexpected`. *Fix:* add handlers returning 400 and 409 respectively, keeping the standard `ErrorResponse` shape.

**B-14 · API contract drift.** Three small ones: `CreateTaskRequest.priority` is optional (defaults to `MEDIUM` in `Task.createNew`) while `UpdateTaskRequest.priority` is `@NotNull` — same field, two contracts; `TaskResponse` omits `completedAt` even though the domain tracks and stores it (clients can never show completion time, yet the dashboard is built on it); `ErrorResponse` serializes `"fieldErrors": null` on every non-validation error (no `@JsonInclude(NON_NULL)`). *Fix:* align priority handling, add `completedAt` to the response (+ contract test), annotate `ErrorResponse`.

**B-15 · Enum FQNs inside JPQL strings.** `AnalyticsPersistenceAdapter.java:31,36,46` embed `com.smarttodo.domain.model.TaskStatus.DONE` as text — a package rename breaks queries with zero compile-time signal. *Fix:* pass the enum as a bound parameter (`:status`).

**B-16 · CORS/Swagger permanently dev-shaped.** `CorsConfig.java:22` allows `http://localhost:*` with `allowedHeaders("*")` unconditionally; `/swagger-ui/**` and `/v3/api-docs/**` are `permitAll` (`SecurityConfig.java:42-44`). Fine for dev; there is simply no prod story because there are no profiles (see B-02). *Fix:* profile-gate both when introducing profiles. Also note (accepted trade-off, document it): a valid 15-min access token keeps working after user deletion (`JwtAuthenticationFilter.java:37-44`), and `/health` (`HealthController.java:11`) duplicates actuator's `/actuator/health`.

### Frontend

**F-08 · Logout invalidation god-method.** `auth_notifier.dart:5-10,69-76` imports and invalidates six providers from six features (`taskList`, `taskFilter`, `todoLists`, `tags`, `calendarTasks`, `dashboard`). Every new user-scoped provider must remember to enroll here; the auth feature compile-depends on the entire app. *Fix:* invert the dependency — have user-scoped providers watch the auth state (or a `currentUserIdProvider`) so they reset themselves; `autoDispose` (F-10) removes most of the need.

**F-09 · Router (core) reads a feature presentation provider.** `app_router.dart:10,86-91` imports `task_list_notifier` for the edit-route lookup — core coupled to feature state, and the mechanism behind F-01. Fixing F-01 with a `getById` provider also removes this import.

**F-10 · No `autoDispose` anywhere.** All providers are keep-alive: filter state, calendar selection and cached lists survive for the app's lifetime and must be manually cleared on logout (the reason F-08 exists). *Fix:* default to `autoDispose` for per-screen state (calendar UI state, filter), keep-alive only for deliberate caches.

**F-11 · Filter changes refetch everything; create ignores sort/filter.** `task_list_notifier.dart:15-19` re-runs the full network fetch on every chip/sort/keystroke change (search is debounced — chips and sort are not), and `createTask` (`:43`) always prepends the new task even when it doesn't match the active filter or sort order. *Fix:* accept the refetch (it's simple) but make mutations re-run `refresh()` instead of hand-splicing state, or filter/sort-check before splicing.

**F-12 · Error display: three patterns, one of them raw.** Tag management (`tag_management_screen.dart:26`), calendar (`calendar_screen.dart:33`), dashboard (`dashboard_screen.dart:32`) and the drawer (`app_shell.dart:93-96`) render `Text('$error')` — and `Failure` has no `toString` override, so users literally see `Instance of 'ServerFailure'`-class text. The task list has a proper retry UI (`task_list_screen.dart:72-86`); auth/edit use SnackBars. Related polish: `dashboard_notifier.refresh` (`dashboard_notifier.dart:15-18`) sets `AsyncValue.loading()` and blanks the whole dashboard to a spinner, while the task list correctly uses `skipLoadingOnReload` (`task_list_screen.dart:70`); the drawer has no empty-state for zero lists (`app_shell.dart:97-104`) unlike every other collection view. *Fix:* give `Failure` a user-readable `message`/`toString`, extract one shared error widget with retry, use `skipLoadingOnReload` consistently.

**F-13 · `Task.copyWith` cannot clear `dueDate`.** `task.dart:33-55` has `clearListId` but no `clearDueDate`; once set, no code path (or UI affordance in `task_edit_screen.dart`) can remove a due date. *Fix:* add `clearDueDate` + a clear button on the date field.

**F-14 · Session-expiry signalling via mutable bool.** `api_client.dart:12-22` sets `sessionExpiredProvider` to `true`; `auth_notifier.dart:55-61` listens and immediately resets it. A flag used as a one-shot event is order-sensitive if two expiries land close together. *Fix:* model it as an event (listen to a `StreamProvider`, or have the interceptor call an auth-notifier method directly).

**F-15 · Non-Dio errors bypass `Failure` mapping.** Repositories only catch `DioException` (each `_guard`, `analytics_repository.dart:31`); malformed bodies hitting `as`-casts (`task_remote_data_source.dart:45`, `dashboard_data.dart:20-23`) or the enum parse (F-07) escape as raw exceptions. *Fix:* catch-all in the shared guard mapping unknown errors to a generic `Failure` (keep the stack in logs).

---

## Low — code smells & refactors

### B-17 · Backend smells

- **Dead code:** the whole `TaskQuery` fluent builder — `unfiltered()` plus nine `withXxx(...)` copy-methods (`ListTasksUseCase.java:31-74`) — is never called; both `TaskController.list` and the tests use the canonical constructor. Delete (~44 lines).
- **Triplicated ownership guard:** `requireOwnTask` (`TaskService.java:87-90`), `requireOwnTag` (`TagService.java:59-62`), `requireOwnList` (`TodoListService.java:53-56`) are the same `findByIdAndUserId(...).orElseThrow(ResourceNotFoundException)` shape (again inline in `TaskService.requireOwnListIfPresent:92-97`). A tiny shared helper (`Ownership.require(optional, "Task", id)`) collapses them.
- **Mapper boilerplate ×5:** every persistence adapter re-implements field-by-field `toDomain`/`toEntity` and the `save = toDomain(jpa.save(toEntity(x)))` dance. Acceptable hexagonal tax, but consider MapStruct if it grows.
- **DTO duplication:** `ListRequest` vs `TagRequest` differ only in `@Size` and share a copy-pasted hex-color `@Pattern` (same message string) — extract the pattern constant; `PageResponse` duplicates `application/port/PageResult` field-for-field — fine as a web DTO, but the mapping deserves one generic `from`.
- **Magic values:** `@RequestParam(defaultValue = "42") int days` (`AnalyticsController.java:31`) — name it; page defaults `"0"`/`"20"` inline (`TaskController.java:72-73`); size limits (10 000, 200, 100, 50, 7) scattered across DTOs and migrations with no shared constants.
- **Nits:** local `days_` with trailing underscore (`AnalyticsService.java:42`) hints the method should be split (clamp / query / assemble); `TaskSpecifications.java:98` appends a `createdAt DESC` tie-breaker even when the primary sort *is* `CREATED_AT` (duplicate order term); `TaskRepositoryPort.java:7` (an out-port) imports `TaskQuery` from inside an in-port — move `TaskQuery` next to `PageResult` in `application.port`; `TaskMapper.toEntity` (`TaskMapper.java:19-27`) fabricates detached `TagJpaEntity` instances whose copied name/color are ignored — works only because there's no cascade; a comment or an id-only constructor would make that explicit.

### F-16 · Frontend smells

- **`_guard` ×4:** byte-identical try/`DioException`/`Failure.fromDio` helpers in `list_repository_impl.dart:40-46`, `tag_repository_impl.dart:36-42`, `task_repository_impl.dart:73-79`, and the same idea as `_authenticate` in `auth_repository_impl.dart:47-58`. Extract one mixin/base — it's also where the F-15 catch-all belongs.
- **Datasource near-duplication:** `list_remote_data_source.dart` and `tag_remote_data_source.dart` are the same CRUD over `/lists` vs `/tags` (lines 16-45 in both) — a generic named-resource datasource would erase one of them.
- **Priority/status label maps ×4, inconsistently:** `task_card.dart:11-15` (`BASSA/MEDIA/ALTA`), `task_detail_screen.dart:13-23`, `task_edit_screen.dart:167-192`, `dashboard_screen.dart:193-199` each hardcode their own enum→Italian mapping, mixing upper/title case. One source of truth (extension on the enums) fixes display drift.
- **AsyncNotifier CRUD splicing ×3:** `tags_notifier.dart:16-25`, `todo_lists_notifier.dart:17-38`, `task_list_notifier.dart:43-51` repeat the add/replace/remove-by-id state surgery — extract list-state helpers, or invalidate instead (F-11).
- **Magic numbers despite `Dimens`:** raw paddings/sizes throughout `login_screen.dart`, `register_screen.dart`, `task_edit_screen.dart`, `task_detail_screen.dart`, `dashboard_screen.dart`; the FAB-clearance `bottom: 88` recurs (`task_list_screen.dart:129`, `calendar_screen.dart:41`). Route them through `dimens.dart`.
- **Theme undermined:** inline `border: OutlineInputBorder()` on fields in login/register/edit screens (`login_screen.dart:70,89`, `register_screen.dart:71-116`, `task_edit_screen.dart:140-238`) overrides the app-wide `inputDecorationTheme` (`app_theme.dart:39-54`); `Colors.white` in `list_editor_dialog.dart:66` violates the "no raw Colors.*" rule the theme file itself declares (`app_theme.dart:8`).
- **Long screens with logic in `build`:** `task_list_screen.dart` (284 lines) embeds the grouping/"default sort" business rule and calls `groupByDue(items, DateTime.now())` in build; `task_edit_screen.dart` has a ~110-line build; `DateTime.now()` inline in cards/dashboard makes widgets time-dependent and hard to test — inject "now" or compute in providers.
- **Boundary nits:** tag screen reuses `ListEditorDialog` from the list feature (`tag_management_screen.dart:7,60`) — promote it to `core/widgets`; two theme-toggle entry points (`task_list_screen.dart:39-47` app bar and `app_shell.dart:122-128` drawer); duplicated snackbar `ref.listen` blocks in login/register; `main.dart:8-19` has no error handling around `SharedPreferencesWithCache.create` (a storage failure crashes before `runApp`).

### F-17 · Localization & accessibility

All UI strings are inline Italian literals with no `flutter_localizations`/`intl`; dates are hand-formatted (`task_card.dart:157-158`, `task_detail_screen.dart:99-102`) rather than locale-aware. Color swatches (`list_editor_dialog.dart:59-69`, `app_shell.dart:164`, `tag_management_screen.dart:41-42`) have no semantic labels; the dashboard bar chart has no accessible description; swipe-delete via `Dismissible` (`task_list_screen.dart:135-159`) has no undo or confirmation while the detail screen confirms — inconsistent destructive-action UX. For a portfolio project, wiring `intl` + ARB files and a SnackBar-undo on swipe-delete are the highest-value slices.

### X-01 · Tooling & config

- `pubspec.yaml:57` pins `freezed: ^3.2.6-dev.1` — a pre-release code generator; move to a stable release.
- `analysis_options.yaml` enables only stock `flutter_lints` with an empty `rules:` block — no `strict-casts`/`strict-raw-types`, no `require_trailing_commas`. Tightening it would have flagged several F-items mechanically.
- `pubspec.yaml:2` description is still "A new Flutter project."
- Generated `*.freezed.dart`/`*.g.dart` are current (no regeneration debt).

---

## Test gaps

### T-01 · Backend
The suite is genuinely strong on happy paths and per-user isolation (service units, JPA `@DataJpaTest` ITs incl. LIKE-escaping and nulls-last sorting, full `AuthFlowIT`). Missing:

1. Concurrent refresh-token rotation (the B-01 race) — currently only single-threaded rotation is tested (`AuthServiceTest.java:129-157`).
2. Pagination boundaries: negative `page`/`size` (pins the current 500 → should become 400 with B-04), oversized `size`.
3. Analytics: `days` clamping, UTC day-boundary edges, `byStatus`/`byPriority` zero-fill.
4. Malformed JSON body → `handleUnreadableBody` (`GlobalExceptionHandler.java:38-45`) has no test.
5. Cross-user isolation over HTTP for PUT/DELETE (`AuthFlowIT` covers GET only, `AuthFlowIT.java:82-87`).
6. Email case-sensitivity — no test pins the current behavior (B-12).
7. `TaskResponse` contract: nothing asserts `completedAt` presence/absence (B-14).
8. CORS: credentials and disallowed-method behavior untested.

### T-02 · Frontend
Domain and repositories are well covered (~2 400 test lines). Missing:

1. `TaskFilterNotifier` toggle/clear/trim logic — no dedicated test.
2. `CalendarNotifier` (`selectDay`/`changeFocus`/`setFormat`) — untested.
3. Interceptor: two concurrent 401s sharing one refresh (the reason `QueuedInterceptor` exists) and the replay-401s-again loop (F-05).
4. Router redirect matrix (`app_router.dart:28-39`) and the edit-route null-task degradation (would have caught F-01).
5. Mutation failure paths: only `deleteTask` rollback is tested (`task_list_notifier_test.dart:87-98`); `createList`/`renameList`/`deleteList`/`createTag`/`deleteTag` have none (F-06).
6. Logout cross-provider invalidation (`_clearUserScopedData`) — a forgotten provider would go unnoticed (F-08).
7. `weeklyBuckets` Monday-boundary and `DateTime.parse` timezone edges; `Failure.fromDio` message-extraction paths; `PriorityColors.lerp/copyWith`; `colorFromHex` invalid input.

---

## Suggested roadmap

**1. Quick wins (one sitting, all S):**
B-03 env-indirect DB creds → B-02 profile-gate the JWT secret → B-04 pagination validation + B-13 handlers → F-07 enum `orElse` → B-14 (`completedAt`, `@JsonInclude`, priority alignment) → B-15 JPQL params → X-01 tooling pins.

**2. Bug fixes (each independently shippable):**
F-01/F-02 `getById` provider (also resolves F-09) → F-04 due-today rule → F-05 retry marker + tests → F-03 calendar invalidation → F-06 mutation error surfacing → B-01 atomic rotation + reuse detection → B-12 email normalization.

**3. Structural refactors:**
B-06 `@Version` migration → B-07 token purge job → B-09/B-10/B-11 query work + `V9` indexes → F-08/F-10 autoDispose + auth-watching providers → F-16 shared `_guard`/datasource/label-map extraction → B-17 dead-code deletion and ownership helper.

**4. Longer arcs:** B-08 timezone model (needs a product decision on where the zone lives), F-17 l10n + accessibility, rate limiting (B-05), and closing T-01/T-02 alongside whichever item touches the same area — each fix above should land with its missing test.
