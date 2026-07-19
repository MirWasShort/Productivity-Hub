# 📓 Journal di sviluppo

Questa directory racconta la riscrittura del progetto **commit per commit**.
Ogni file corrisponde a un commit e spiega *cosa* è stato fatto, *perché*,
*come funziona*, e dove approfondire. È pensato per essere letto in ordine,
affiancando il diff del commit corrispondente:

```bash
git log --oneline               # trova l'hash del commit
git show <hash>                 # guarda il diff mentre leggi la entry
```

## Come è organizzata ogni entry

- **Cosa è stato fatto** — i file toccati e il comportamento introdotto
- **Perché** — le decisioni, le alternative scartate, i trade-off
- **Come funziona** — il meccanismo spiegato da zero
- **Il ciclo TDD** — quale test è nato prima (rosso), cosa lo ha fatto passare (verde)
- **Concetti chiave** — da portare a casa
- **Per approfondire** — documentazione ufficiale e riferimenti alla ROADMAP

## Indice

| # | Entry | Tema |
|---|-------|------|
| C01 | [Ristrutturazione monorepo](C01-monorepo-restructure.md) | Git, layout del repo |
| C02 | [Bootstrap backend](C02-backend-bootstrap.md) | Spring Boot, Gradle, Docker, Testcontainers |
| C03 | [Health endpoint](C03-health-endpoint.md) | TDD, @WebMvcTest, adapter esagonali |
| C04 | [Persistenza User](C04-user-persistence.md) | Flyway, port & adapter, @DataJpaTest |
| C05 | [JwtTokenProvider](C05-jwt-token-provider.md) | JWT, jjwt, unit test puri |
| C06 | [Security config](C06-security-config.md) | Filter chain, stateless, BCrypt |
| C07 | [Registrazione](C07-registration.md) | Use case, command, test pyramid |
| C08 | [Login e refresh rotation](C08-login-refresh-rotation.md) | Token pair, rotazione, hash dei segreti |
| C09 | [Task CRUD](C09-task-crud.md) | Scoping per utente, paginazione, slice test |
| C10 | [Exception handler globale](C10-global-exception-handler.md) | Error contract, information disclosure |
| C11 | [Swagger e CORS](C11-swagger-cors.md) | Preflight, same-origin, doc generata |
| C12 | [Integration test end-to-end](C12-auth-flow-integration-test.md) | E2E, piramide dei test, cablaggio |
| C13 | [Scaffold Flutter](C13-frontend-scaffold.md) | pubspec, Riverpod/Dio/Freezed, codegen |
| C14 | [Core failures e token storage](C14-core-failures-storage.md) | Sealed class, error translation, secure storage |
| C15 | [Dio e auth interceptor](C15-dio-auth-interceptor.md) | QueuedInterceptor, refresh trasparente, ricorsione |
| C16 | [Auth data layer](C16-auth-data-layer.md) | Model vs entity, repository, codegen |
| C17 | [Auth UI e router](C17-auth-ui-router.md) | Notifier, route guard, widget test |
| C18 | [Task data layer](C18-task-data-layer.md) | Enum wire mapping, guard generico, UTC |
| C19 | [Lista task](C19-task-list-screen.md) | AsyncNotifier, optimistic delete, lifecycle |
| C20 | [Edit e dettaglio](C20-task-edit-detail.md) | Form riusabile, rotte annidate, mounted |
| C21 | [Docs e verifica finale](C21-docs-and-final-verification.md) | Verifica end-to-end, stato onesto, prossimi passi |
| C22 | [Design system e dark mode](C22-design-system-dark-mode.md) | Seed theming, ThemeExtension, persistenza |
| C23 | [App shell](C23-app-shell.md) | StatefulShellRoute, tab con stack, guard by default |
| C24 | [Task card e empty state](C24-task-card-empty-state.md) | Restyle sotto test, degradare con grazia |
| C25 | [Filtri backend](C25-backend-filters-specification.md) | Specification, sort semantico, escape LIKE |
| C26 | [Filter bar frontend](C26-frontend-filter-bar.md) | Debounce, stato derivato, skipLoadingOnReload |
| C27 | [Scadenze intelligenti](C27-due-grouping.md) | Funzione pura, tempo iniettato, confini locali |
| C28 | [CRUD liste](C28-lists-crud.md) | Vertical slice ripetibile, pattern con giudizio |
| C29 | [CRUD tag](C29-tags-crud.md) | Indice funzionale, 409, self-collision |
| C30 | [Task, liste e tag](C30-task-lists-tags-integration.md) | ManyToMany, N+1, IDOR, ON DELETE |
| C31 | [Drawer liste frontend](C31-frontend-lists-drawer.md) | Drawer, filtro-lista, cascata dei contratti |
| C32 | [Tag frontend](C32-frontend-tags.md) | Multi-select, filtro tag, viewport nei test |
| C33 | [Vista calendario](C33-calendar-view.md) | table_calendar, grouping puro, prefill via URL |
| C34 | [Analytics backend](C34-backend-analytics.md) | completedAt, query aggregate, overdue unico |
| C35 | [Dashboard grafici](C35-dashboard-charts.md) | dataviz, forma prima del colore, aggregazione |
| C36 | [Docs e verifica finale](C36-docs-and-final-verification.md) | Verifica su DB pulito, demo per impatto |
| C37 | [Pulsante formato calendario](C37-calendar-format-button.md) | Default di libreria, etichetta = stato |
| C38 | [Calendario auto-aggiornante](C38-calendar-invalidation.md) | Invalidazione mirata, cache = obbligo di sync |
| C39 | [Scaffold webapp](C39-webapp-scaffold.md) | Vite, TS strict, Vitest, monorepo multi-client |
| C40 | [Design token webapp](C40-webapp-design-tokens.md) | Token M3 in CSS, @theme inline, tema persistito |
| C41 | [Router e shell webapp](C41-webapp-router-shell.md) | Layout route, Outlet, navigazione desktop |
| C42 | [Tipi da OpenAPI](C42-webapp-openapi-types.md) | Codegen, asserzioni di tipo, nullabilità |
| C43 | [Client HTTP webapp](C43-webapp-fetch-client.md) | fetch, errori tipizzati, sessione su localStorage |
| C44 | [Refresh trasparente webapp](C44-webapp-refresh-interceptor.md) | Promessa condivisa, rotazione token, replay unico |
| C45 | [Auth store e guard webapp](C45-webapp-auth-store-guards.md) | Stato fuori da React, cache svuotata, guard reattivo |
| C46 | [Login e registrazione webapp](C46-webapp-auth-ui.md) | react-hook-form, zod, corsa fra redirect |
| C47 | [Data layer task webapp](C47-webapp-task-data-layer.md) | Filtro come chiave, ottimismo, invalidazione per prefisso |
| C48 | [Scadenze intelligenti webapp](C48-webapp-due-grouping.md) | Funzione pura portata, giorni di calendario, confini |
| C49 | [Lista task webapp](C49-webapp-task-list.md) | Swipe→hover, stati vuoti distinti, un solo orologio |
| C50 | [Barra filtri webapp](C50-webapp-filter-bar.md) | Debounce con ref, chiusure stantie, mock realistici |
| C51 | [Dettaglio ed editor webapp](C51-webapp-task-editor.md) | Scrivere per prefisso, onMutate che annulla, select nativo |
