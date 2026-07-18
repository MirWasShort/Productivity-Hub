# C09 — Task CRUD scoped per utente

## Cosa è stato fatto

Il cuore funzionale dell'app, costruito con lo stesso schema verticale di
C07 ma per l'entità `Task`:

- **Migrazione `V3__create_task_table.sql`**: `tasks` con status/priority
  come VARCHAR (enum applicativi), `due_date`, FK verso `users` con
  `ON DELETE CASCADE`, indice su `user_id`.
- **Dominio**: record `Task` con factory `createNew` (status TODO,
  priority default MEDIUM) e metodo `update(...)` che restituisce una
  copia con `updatedAt` aggiornato; enum `TaskStatus` e `TaskPriority`.
- **5 port in** (uno per operazione, come da ROADMAP): Create/Get/List/
  Update/Delete, con i loro command; `PageResult<T>` come risultato di
  paginazione *senza dipendenze Spring*.
- **`TaskService`**: implementa i 5 use case. Ogni metodo prende lo
  `userId` autenticato e passa da `findByIdAndUserId` — un task altrui è
  indistinguibile da uno inesistente (404, mai 403).
- **Persistenza**: `TaskJpaEntity` (+`@Enumerated(STRING)`), repository
  Spring Data con `Page<T>`, adapter che traduce in `PageResult`.
- **Web**: `TaskController` con i 5 endpoint su `/api/v1/tasks`,
  paginazione `page`/`size` (sort fisso `createdAt desc`), DTO validati,
  `PageResponse`. Handler globale: `ResourceNotFoundException` → 404.
- Test: 8 unit (`TaskServiceTest`, incluso cross-user), 4 IT
  (`TaskPersistenceAdapterIT`, scoping e paginazione reali), 8 slice web
  (`TaskControllerTest`). Suite totale: 56 verdi.

## Perché

**Perché 404 e non 403 per il task di un altro utente?** Rispondere 403
("esiste ma non è tuo") conferma all'attaccante che quell'UUID esiste.
404 non rivela nulla. Il test
`should_throwNotFoundAndNotDelete_when_deletingAnotherUsersTask` blinda
proprio il requisito della ROADMAP: "User A cannot read User B's tasks".

**Perché lo scoping sta nella query (`findByIdAndUserId`) e non in un
check dopo il fetch?** `fetch(id)` seguito da `if (task.userId != user)`
è il classico bug in agguato: basta dimenticare l'if una volta. Con la
query scoped il caso "non tuo" e il caso "non esiste" collassano nello
stesso `Optional.empty()` — non c'è un ramo da dimenticare.

**Perché `PageResult` invece di usare `Page<T>` di Spring Data nei port?**
`Page` è un tipo Spring: se il port lo esponesse, il layer application
dipenderebbe dal framework di persistenza. Il record `PageResult` costa 10
righe e mantiene pulita la regola delle dipendenze.

**Perché enum come `VARCHAR` e non `@Enumerated(ORDINAL)`?** Con ORDINAL
il DB memorizza 0/1/2: riordinare le costanti dell'enum corromperebbe
silenziosamente i dati. STRING è leggibile nel DB e robusto ai refactor
(rinominare una costante richiede una migrazione esplicita — che è un bene).

## Come funziona

- Lo `userId` arriva al controller con `@AuthenticationPrincipal`: è il
  principal che `JwtAuthenticationFilter` (C06) ha messo nel
  `SecurityContext` estraendolo dal claim `sub` del JWT. Il client non
  invia mai il proprio id — lo *dimostra* col token.
- La paginazione attraversa i layer: `?page=0&size=20` → use case →
  `PageRequest.of(page, size, Sort.by(DESC, "createdAt"))` in adapter →
  `Page<TaskJpaEntity>` → `PageResult<Task>` → `PageResponse<TaskResponse>`.

**Insidia di test incontrata (istruttiva).** Il primo tentativo usava
`addFilters = false` + post-processor `authentication(...)`: i test
andavano in `NullPointerException` perché senza filtri il SecurityContext
non viene propagato e `@AuthenticationPrincipal` risolve `null`. Riattivati
i filtri, POST/PUT/DELETE fallivano con 403: la slice `@WebMvcTest` non
carica le `@Configuration` dell'app, quindi girava la security *di
default* (CSRF attivo!), non la nostra. Fix: `@Import(SecurityConfig.class)`
nella slice — così i test del controller girano contro la stessa filter
chain della produzione. Lezione: quando un test di sicurezza fallisce,
chiediti sempre *quale* configurazione sta davvero girando.

## Il ciclo TDD in questo commit

1. **Rosso** — 20 test scritti prima (service, adapter IT, controller):
   186 errori di compilazione.
2. **Verde** — migrazione, dominio, 5 port, service, persistenza,
   controller, handler 404; più i due fix di configurazione dei test.
3. **Refactor** — il lookup scoped è stato estratto in
   `requireOwnTask(userId, taskId)`, usato da get/update/delete.

## Concetti chiave

- **Authorization by query scoping**: il filtro di proprietà vive nella
  query, non in un if.
- **No existence leak**: 404 per "non esiste" e per "non è tuo".
- **Pagination end-to-end**: il numero di pagina viaggia dal query param
  al `LIMIT/OFFSET` SQL attraverso tipi propri di ogni layer.
- **Slice test ≠ app reale**: le slice caricano solo una parte dei bean;
  ciò che resta fuori (la security config!) va importato consapevolmente.

## Per approfondire

- [Spring Data JPA — Query methods & Pagination](https://docs.spring.io/spring-data/jpa/reference/repositories/query-methods-details.html)
- [OWASP — Broken Object Level Authorization](https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/) (la vulnerabilità #1 delle API, evitata qui by design)
- [Spring Security Testing](https://docs.spring.io/spring-security/reference/servlet/test/mockmvc/index.html) (post-processor, @WithMockUser)
- ROADMAP: Fase 2 (Weeks 9-12, Core Backend CRUD) e Fase 3, Settimana 16 (Securing Task Endpoints), kata 2.3 (Pagination Kata)
