# 🧭 Percorso di apprendimento — da zero a fullstack developer

> **Per chi è questo documento:** hai davanti questo repository, vedi che "funziona",
> ma non capisci *come* è stato costruito né da dove cominciare per saperlo fare tu.
> Questo documento è la scala per arrivarci: un percorso incrementale in cui ogni
> fase produce qualcosa di concreto, verificabile, e propedeutico alla successiva.
>
> **Obiettivo finale:** saper costruire da solo ciò che c'è in questo repo — un
> backend sicuro con API REST, un client mobile Flutter e una webapp React — cioè
> essere un **fullstack developer**.

**Ritmo assunto:** studio intensivo, ~25–40 ore a settimana → **~22 settimane (5–6 mesi)**.
Le settimane indicate sono una bussola, non una gara: la vera unità di avanzamento è
la **Verifica** in fondo a ogni fase. Se non è tutta verde, la fase non è finita.

---

## Come usare questo documento

Questo repo ha una proprietà rara: è documentato **commit per commit** nel
[journal](../journal/README.md) (C01–C61), in italiano, con la spiegazione di cosa
è stato fatto, perché, e quale test è nato prima del codice. Il journal è la tua
"soluzione guidata". Il metodo di lavoro è sempre lo stesso:

1. **Studia** le risorse della fase (poche, in ordine: prima la prima).
2. **Costruisci** il deliverable della fase *nel tuo progetto*, da solo, test-first.
3. **Confronta** il tuo risultato con il repo: leggi le entry del journal indicate,
   guarda i file citati, capisci le differenze. Il journal si legge **dopo** il
   tuo tentativo, non al posto del tentativo.
4. **Verifica** la Definition of Done. Tutto verde → fase successiva.

Due regole non negoziabili, ereditate da come questo repo è stato costruito:

- **TDD sempre**: prima il test che fallisce (rosso), poi il codice che lo fa
  passare (verde), poi la pulizia (refactor). All'inizio sembra lento; è il motivo
  per cui ogni commit di questo repo lascia la suite verde e l'app avviabile.
- **Niente copia-incolla**: scrivi tutto a mano. La memoria muscolare è parte
  dell'apprendimento.

### Legenda delle risorse

| Simbolo | Significato |
|---------|-------------|
| 🆓 | Gratuita |
| ⭐ | Inclusa nella sottoscrizione **Frontend Masters** |
| 🎯 | Inclusa nella sottoscrizione **Code with Andrea** |
| 📕 | Libro / premium a pagamento singolo |

### Mappa del percorso

| Parte | Fasi | Cosa impari | Settimane |
|-------|------|-------------|-----------|
| [0 — Fondamenta](#parte-0--fondamenta) | F0.1–F0.2 | Terminale, Git, HTTP, SQL, Java, TDD | ~3 |
| [1 — Backend Spring Boot](#parte-1--backend-spring-boot) | F1.1–F1.4 | API REST, architettura esagonale, sicurezza JWT, query avanzate | ~6 |
| [2 — Client Flutter](#parte-2--client-flutter) | F2.1–F2.4 | Dart, widget, Riverpod, Clean Architecture, networking | ~5 |
| [3 — Webapp React](#parte-3--webapp-react) | F3.1–F3.4 | TypeScript, React, TanStack Query, form, testing | ~5 |
| [4 — Il mestiere](#parte-4--il-mestiere) | F4.1–F4.2 | Sistemi condivisi, monorepo, e i prossimi passi | ~3 |

---

## Parte 0 — Fondamenta

Prima di scrivere una riga del progetto servono gli attrezzi. Questa parte sembra
"poco codice", ma è quella che separa chi avanza da chi si blocca alla prima
migrazione fallita o al primo merge conflict.

### F0.1 — Strumenti del mestiere (~1,5 settimane)

**Obiettivo:** muoverti con disinvoltura in terminale, Git, HTTP, JSON, SQL e
Docker — il vocabolario minimo di qualunque sviluppatore.

**Costruisci:**
- Un repository Git tuo, con branch, merge, un conflitto risolto a mano e una
  pull request su GitHub.
- Un database PostgreSQL avviato con Docker Compose in cui crei tabelle e fai
  query a mano (`psql` o pgAdmin).
- Una serie di chiamate HTTP fatte con `curl` a un'API pubblica qualsiasi,
  osservando metodi, status code e header.

**Risorse:**
1. 🆓 [MDN — Panoramica di HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Overview) — metodi, status code, header. Leggila due volte.
2. 🆓 [Learn Git Branching](https://learngitbranching.js.org/) — Git interattivo, visuale, eccellente.
3. 🆓 [SQLBolt](https://sqlbolt.com/) — SQL interattivo da zero; poi [PgExercises](https://pgexercises.com/) per praticare su PostgreSQL.
4. 🆓 [Docker — Get Started](https://docs.docker.com/get-started/) — solo le basi: immagini, container, compose.
5. ⭐ [Complete Intro to Web Development, v3 (Brian Holt)](https://frontendmasters.com/courses/web-development-v3/) — se parti proprio da zero sul web: come i pezzi stanno insieme.

**Nel repo:** guarda [`docker-compose.yml`](../docker-compose.yml) — è esattamente
il pattern che userai: un PostgreSQL 16 con healthcheck, niente di più. La entry
[C01](../journal/C01-monorepo-restructure.md) spiega come è organizzato il repo.

**Verifica (Definition of Done):**
- [ ] Sai creare un branch, fare commit, risolvere un conflitto e aprire una PR senza cercare i comandi.
- [ ] `docker compose up -d` avvia un tuo PostgreSQL; sai connetterti e fare una `JOIN` fra due tabelle create da te.
- [ ] Sai spiegare a voce la differenza fra GET/POST/PUT/DELETE e cosa significano 200, 201, 400, 401, 404, 409, 500.

---

### F0.2 — Java moderno + il ciclo TDD (~1,5 settimane)

**Obiettivo:** scrivere piccoli programmi in Java moderno (records, streams,
`Optional`) e aver interiorizzato il ciclo Rosso → Verde → Refactor con JUnit 5.

**Costruisci:**
- I kata classici, tutti test-first: FizzBuzz, String Calculator, un "contact
  book" a console con `Map` e `List`.
- Riscrivi almeno un kata usando un `record` immutabile con un factory method
  statico (è lo stile del dominio di questo repo: vedi sotto).

**Risorse:**
1. 🆓 [MOOC.fi — Java Programming I & II](https://java-programming.mooc.fi/) (University of Helsinki) — il miglior corso Java gratuito esistente, con esercizi corretti automaticamente. Fai almeno le parti 1–9.
2. 🆓 [Exercism — Java track](https://exercism.org/tracks/java) — kata con mentoring gratuito, perfetto per il TDD.
3. 🆓 [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/) — solo i capitoli su assertions e lifecycle.

**Nel repo:** apri
[`Task.java`](../backend/src/main/java/com/smarttodo/domain/model/Task.java):
è un `record` puro, senza framework, con factory `createNew` e aggiornamenti che
restituiscono copie immutabili. Alla fine di questa fase devi *riconoscere* questo
stile, non ancora saperlo inventare.

**Verifica (Definition of Done):**
- [ ] Tutti i kata completati test-first; la cronologia Git mostra commit rosso→verde→refactor.
- [ ] Sai spiegare cosa sono `record`, `Optional`, stream e perché l'immutabilità semplifica i test.
- [ ] Ambiente pronto: JDK 21, IntelliJ IDEA (o VS Code), Git, Docker.

> **💡 Approfondimento — perché il TDD è il filo conduttore.**
> In questo repo ogni entry del journal ha una sezione "Il ciclo TDD" che dice
> quale test è nato prima. Non è pedanteria: il test scritto prima è una
> *specifica eseguibile* — ti obbliga a decidere il comportamento prima
> dell'implementazione, e ti lascia una rete di sicurezza per ogni refactor
> futuro. È il motivo per cui questo progetto ha potuto crescere per 61 commit
> senza mai rompere ciò che già funzionava.

---

## Parte 1 — Backend Spring Boot

Qui costruisci il cuore del sistema: la stessa API che serve entrambi i client.
Replicherai in sequenza i commit C02–C12, poi C25, C28–C30 e C34.

### F1.1 — Spring Boot, PostgreSQL, Flyway, Testcontainers (~1,5 settimane)

**Obiettivo:** avere un'app Spring Boot che parte, parla con un PostgreSQL vero,
ha lo schema versionato con Flyway ed è testata contro un database reale.

**Costruisci:**
- Progetto generato da [start.spring.io](https://start.spring.io) (Gradle, Java 21,
  Spring Web, Data JPA, PostgreSQL, Flyway, Validation).
- `GET /health` che risponde `{"status":"UP"}` — scritto test-first con `@WebMvcTest`.
- Migrazione `V1__create_user_table.sql` e un repository testato con
  `@DataJpaTest` + Testcontainers (un PostgreSQL vero in un container, non H2).

**Risorse:**
1. 🆓 [Spring Academy — Building a REST API with Spring Boot](https://spring.academy/courses/building-a-rest-api-with-spring-boot) — corso ufficiale del team Spring, gratuito, con laboratori. Fallo tutto.
2. ⭐ [Enterprise Java with Spring Boot (Josh Long)](https://frontendmasters.com/courses/spring-boot/) — sì, Frontend Masters ha un corso Spring tenuto dal developer advocate di Spring. Ottimo secondo passaggio.
3. 🆓 [Testcontainers — Getting started](https://testcontainers.com/getting-started/) e le [guide](https://testcontainers.com/guides/).
4. 🆓 [Flyway — Why database migrations?](https://documentation.red-gate.com/fd/why-database-migrations-184127574.html)

**Nel repo:** entry [C02](../journal/C02-backend-bootstrap.md),
[C03](../journal/C03-health-endpoint.md), [C04](../journal/C04-user-persistence.md).
File: [`backend/build.gradle.kts`](../backend/build.gradle.kts), le migrazioni in
`backend/src/main/resources/db/migration/`.

**Verifica (Definition of Done):**
- [ ] `./gradlew test` verde, con Testcontainers che avvia un PostgreSQL reale (serve Docker attivo).
- [ ] `./gradlew bootRun` parte, Flyway applica `V1` e `GET /health` risponde.
- [ ] Sai spiegare perché una migrazione, una volta committata, **non si modifica mai** (se ne crea una nuova).
- [ ] Sai spiegare perché si testa contro PostgreSQL vero e non contro H2.

---

### F1.2 — Architettura esagonale + Task CRUD (~1,5 settimane)

**Obiettivo:** un CRUD completo per i Task costruito con la separazione
ports & adapters: dominio senza framework, use case testabili in isolamento,
controller sottili, errori con un contratto unico.

**Costruisci:**
- La struttura a pacchetti: `domain/model` (record puri), `application/port/{in,out}`
  + `application/service`, `adapter/in/web` (controller + DTO),
  `adapter/out/persistence` (entity JPA + mapper), `infrastructure`.
- CRUD completo `POST/GET/PUT/DELETE /api/v1/tasks` con validazione (`@Valid`),
  paginazione, e un `@RestControllerAdvice` che dà a *ogni* errore la stessa forma:
  `{timestamp, status, error, message, path, fieldErrors?}`.
- Test su tre livelli: unit per i service (mock dei port), `@WebMvcTest` per i
  controller, `@DataJpaTest` per la persistenza.

**Risorse:**
1. 🆓 [Hexagonal Architecture (Alistair Cockburn)](https://alistair.cockburn.us/hexagonal-architecture/) — l'articolo originale, breve.
2. 🆓 [Baeldung — Hexagonal Architecture in Spring](https://www.baeldung.com/hexagonal-architecture-ddd-spring) e [Bean Validation](https://www.baeldung.com/spring-boot-bean-validation).
3. 📕 *Spring Start Here* (Laurențiu Spilcă) — il miglior libro per capire *cosa fa* Spring sotto il cofano (DI, context, proxy), se vuoi fondamenta solide.

**Nel repo:** entry [C09](../journal/C09-task-crud.md) e
[C10](../journal/C10-global-exception-handler.md). File esemplari:
[`GlobalExceptionHandler.java`](../backend/src/main/java/com/smarttodo/adapter/in/web/GlobalExceptionHandler.java)
(nota: il 500 *non* rivela dettagli interni — è anti information-disclosure) e la
struttura dei pacchetti sotto `backend/src/main/java/com/smarttodo/`.

**Verifica (Definition of Done):**
- [ ] Nessun `import` di Spring o JPA dentro `domain/` (controllalo con un grep).
- [ ] Ogni endpoint ha test per: caso felice, validazione fallita (400 con `fieldErrors`), non trovato (404).
- [ ] Le entity JPA non escono mai dallo strato di persistenza; le API rispondono solo DTO.
- [ ] `./gradlew test` verde.

> **💡 Approfondimento — perché l'architettura esagonale.**
> L'idea è una sola: il dominio (le regole del business) non deve sapere che
> esistono HTTP e SQL. I *port* sono interfacce definite dal centro; gli
> *adapter* (controller, repository JPA) le implementano ai bordi. Il beneficio
> pratico lo vedi nei test: `TaskService` si testa con un mock del port di
> persistenza, in millisecondi, senza database. "Clean Architecture" (che
> ritroverai in Flutter) è la stessa idea con nomi diversi: cerchi concentrici,
> dipendenze solo verso l'interno.

---

### F1.3 — Sicurezza: JWT, refresh rotation, scoping per utente (~2 settimane)

**Obiettivo:** autenticazione stateless completa — registrazione, login, refresh —
con le pratiche di sicurezza *vere* usate in questo repo, e ogni risorsa
inaccessibile agli altri utenti.

**Costruisci:**
- `SecurityConfig` stateless: `/api/v1/auth/**` pubblico, tutto il resto protetto,
  401 in JSON coerente col contratto d'errore.
- `JwtTokenProvider` (access token 15 minuti, HMAC-SHA256) + filtro che popola il
  `SecurityContext` — con unit test per generazione, scadenza e manomissione.
- Refresh token **opachi** (random a 256 bit), salvati **hashati SHA-256**, con
  **rotazione**: ogni refresh revoca il token presentato e ne emette uno nuovo.
- Password con BCrypt; errore unico per "email inesistente" e "password errata".
- Ogni operazione sui task scoped all'utente autenticato: chiedere il task di un
  altro utente dà **404, mai 403**.

**Risorse:**
1. 🆓 [jwt.io](https://jwt.io/) — decodifica un JWT a mano: header, payload, firma. Manomettilo e guarda la validazione fallire.
2. 🆓 [Spring Security — Architecture](https://docs.spring.io/spring-security/reference/servlet/architecture.html) — come funziona la filter chain. Lettura obbligatoria.
3. 🆓 [OWASP — Session Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) e [RFC 9700 §refresh token rotation](https://datatracker.ietf.org/doc/html/rfc9700).
4. 🆓 [Dan Vega (YouTube)](https://www.youtube.com/@DanVega) — video pratici su Spring Security + JWT, dal team Spring.

**Nel repo:** entry [C05](../journal/C05-jwt-token-provider.md),
[C06](../journal/C06-security-config.md), [C07](../journal/C07-registration.md),
[C08](../journal/C08-login-refresh-rotation.md) — quest'ultima è la più densa:
spiega ogni singola scelta. File:
[`AuthService.java`](../backend/src/main/java/com/smarttodo/application/service/AuthService.java).
Chiudi con [C12](../journal/C12-auth-flow-integration-test.md): il test di
integrazione end-to-end dell'intero flusso auth.

**Verifica (Definition of Done):**
- [ ] Smoke test con `curl`: register 201 → login 200 → chiamata protetta senza token 401 → refresh 200 → **riuso dello stesso refresh token 401**.
- [ ] Test che dimostra: l'utente A riceve 404 (non 403) chiedendo un task dell'utente B.
- [ ] In DB non esiste nessun segreto in chiaro: password BCrypt, refresh token SHA-256.
- [ ] Nessun secret hardcoded nel codice (config con override da variabile d'ambiente).
- [ ] `./gradlew test` verde, incluso un integration test end-to-end del flusso auth.

> **💡 Approfondimento — anatomia della coppia di token.**
> Perché due token? L'access token viaggia su *ogni* richiesta: se rubato deve
> valere poco (15 minuti). Il refresh token viaggia solo verso `/auth/refresh`:
> può durare 7 giorni. Perché il refresh è opaco e non un JWT? Perché deve poter
> essere **revocato**, e la revoca richiede stato server-side — un JWT di 7
> giorni non revocabile è una chiave persa per una settimana. Perché si salva
> solo l'hash? Come per le password: un DB esfiltrato non deve contenere
> credenziali pronte (ma basta SHA-256 "nudo": il token è già random a 256 bit,
> non serve la lentezza di BCrypt, che difende dai dizionari). Perché la
> rotazione? Un token rubato vale **un solo uso**, e il riuso di un token
> revocato è un allarme visibile nei log. E perché 404 invece di 403 sui task
> altrui? Un 403 conferma che la risorsa *esiste* — è un'informazione regalata
> a chi enumera ID (attacco IDOR). Il 404 non conferma niente.

---

### F1.4 — Query avanzate: filtri, relazioni, analytics (~1 settimana)

**Obiettivo:** saper costruire endpoint di ricerca con filtri dinamici
combinabili, modellare relazioni (uno-a-molti, molti-a-molti) senza cadere nel
problema N+1, e scrivere query di aggregazione.

**Costruisci:**
- Liste (`/api/v1/lists`) e tag (`/api/v1/tags`) con relazione ManyToMany
  task↔tag, migrazioni Flyway nuove, cancellazioni con `ON DELETE` ragionato.
- Filtri su `GET /api/v1/tasks` via **JPA Specifications**: stato, priorità,
  lista, tag, ricerca testuale (con **escape dei caratteri jolly del LIKE**),
  ordinamento semantico della priorità (HIGH>MEDIUM>LOW via CASE, non alfabetico).
- Endpoint analytics con query aggregate (conteggi, completamenti per settimana).

**Risorse:**
1. 🆓 [Spring Data JPA — Specifications](https://docs.spring.io/spring-data/jpa/reference/jpa/specifications.html)
2. 🆓 [Vlad Mihalcea — N+1 query problem](https://vladmihalcea.com/n-plus-1-query-problem/) — il riferimento su JPA e performance.
3. 🆓 [Baeldung — Many-to-Many in JPA](https://www.baeldung.com/jpa-many-to-many)

**Nel repo:** entry [C25](../journal/C25-backend-filters-specification.md),
[C28](../journal/C28-lists-crud.md), [C29](../journal/C29-tags-crud.md),
[C30](../journal/C30-task-lists-tags-integration.md),
[C34](../journal/C34-backend-analytics.md). File:
[`TaskSpecifications.java`](../backend/src/main/java/com/smarttodo/adapter/out/persistence/TaskSpecifications.java)
e `default_batch_fetch_size` in
[`application.yml`](../backend/src/main/resources/application.yml).

**Verifica (Definition of Done):**
- [ ] Ogni filtro testato da solo **e in combinazione** con gli altri.
- [ ] Cercare `%` o `_` nel testo non si comporta da carattere jolly (test esplicito).
- [ ] Con SQL logging attivo, caricare 20 task con i loro tag non genera 20 query (niente N+1).
- [ ] `./gradlew test` verde. Il backend è completo: da qui in poi non lo tocchi più.

> **💡 Approfondimento — il problema N+1.**
> Carichi 20 task (1 query), poi accedi ai tag di ciascuno e Hibernate fa 20
> query in più: 1+N. Questo repo lo risolve con `default_batch_fetch_size: 50`,
> che raccoglie gli ID e carica i tag con una sola `IN (...)` — scelto invece di
> `JOIN FETCH` perché il join moltiplicherebbe le righe e romperebbe la
> paginazione. Non è l'unica soluzione giusta; è una soluzione *argomentata*,
> ed è questo che devi imparare a fare.

---

## Parte 2 — Client Flutter

Il primo client. Replicherai C13–C38: Clean Architecture per feature, Riverpod,
networking con refresh trasparente, e tutte le feature fino alla dashboard.
Qui la sottoscrizione **Code with Andrea** è il tuo pilastro: i corsi di Andrea
Bizzotto usano esattamente lo stack di questo repo (Riverpod + GoRouter).

### F2.1 — Dart e Flutter: fondamenta (~1 settimana)

**Obiettivo:** pensare "a widget": comporre interfacce, gestire stato locale,
capire il build cycle.

**Costruisci:**
- I kata di F0.2 riscritti in Dart (noterai null safety e async/await).
- Il counter app rifatto in 3 modi: `setState`, `ChangeNotifier`, Riverpod —
  per capire *cosa* Riverpod ti risolve.
- Una piccola app "note" in memoria: lista, aggiunta, cancellazione, con widget test.

**Risorse:**
1. 🆓 [Dart — Language tour](https://dart.dev/language) — veloce se vieni da Java: stessa famiglia.
2. 🆓 [Flutter — Codelabs ufficiali](https://docs.flutter.dev/codelabs) — parti da "Your first Flutter app".
3. 🎯 [Flutter Foundations (Code with Andrea)](https://codewithandrea.com/courses/flutter-foundations/) — inizia ora, ti accompagnerà per tutta la Parte 2: costruisce un'app completa con Riverpod e GoRouter.

**Nel repo:** ancora niente — questa fase è palestra pura.

**Verifica (Definition of Done):**
- [ ] Sai spiegare `StatelessWidget` vs `StatefulWidget` e cosa fa `const` in un albero di widget.
- [ ] L'app note ha widget test verdi (`flutter test`).
- [ ] Sai dire a voce quale problema risolve Riverpod rispetto a `setState`.

---

### F2.2 — Clean Architecture, Riverpod, networking (~1,5 settimane)

**Obiettivo:** lo scheletro del client: struttura per feature con
`domain/data/presentation`, modelli Freezed, storage sicuro dei token e —
il pezzo più formativo — l'interceptor Dio che rinnova i token in modo
trasparente.

**Costruisci:**
- Progetto Flutter con `lib/features/<feature>/{domain,data,presentation}` e
  `lib/core/{error,network,storage,router}`.
- Gerarchia di errori con **sealed class** (`Failure`) e traduzione delle
  `DioException` in failure di dominio.
- `TokenStorage` su `flutter_secure_storage`.
- `AuthInterceptor` su Dio (`QueuedInterceptor`): allega l'access token, sui 401
  tenta il refresh e ripete la richiesta, usando un client Dio *separato* per il
  refresh (altrimenti: ricorsione infinita).
- Data layer auth completo: modelli Freezed (json_serializable), repository che
  mappa modelli↔entità.

**Risorse:**
1. 🎯 Flutter Foundations — le sezioni su architettura, repository pattern e Riverpod.
2. 🆓 [Riverpod — documentazione ufficiale](https://riverpod.dev/) (il repo usa Riverpod 3).
3. 🆓 [Code with Andrea — articoli free](https://codewithandrea.com/articles/) — in particolare quelli su app architecture e Riverpod: sono il riferimento della community.
4. 🆓 [Freezed — README](https://pub.dev/packages/freezed) e [Dio — interceptors](https://pub.dev/packages/dio#interceptors).

**Nel repo:** entry [C13](../journal/C13-frontend-scaffold.md)–[C16](../journal/C16-auth-data-layer.md),
in particolare [C15](../journal/C15-dio-auth-interceptor.md). File:
[`auth_interceptor.dart`](../frontend/lib/core/network/auth_interceptor.dart),
[`failures.dart`](../frontend/lib/core/error/failures.dart).

**Verifica (Definition of Done):**
- [ ] `dart run build_runner build` genera i file Freezed/JSON senza errori.
- [ ] Test dell'interceptor: un 401 provoca refresh + replay della richiesta originale; se il refresh fallisce si finisce sloggati.
- [ ] Nessun import da `data/` dentro `presentation/` (le feature parlano via `domain`).
- [ ] `flutter test` verde.

> **💡 Approfondimento — perché model ≠ entity.**
> Il `TaskModel` (in `data/`) conosce il JSON dell'API: nomi dei campi, formati
> delle date, enum "wire". La `Task` entity (in `domain/`) conosce solo il
> business. Sembra duplicazione, finché l'API non cambia un nome di campo: con
> la separazione tocchi un solo file di mapping; senza, il cambiamento si
> propaga in tutta la UI. È la stessa ragione per cui il backend separa
> `TaskJpaEntity` dal record `Task`: i confini si pagano in codice e si
> ripagano in cambiamenti localizzati.

---

### F2.3 — Le feature: auth UI, task, filtri, liste, tag, calendario (~1,5 settimane)

**Obiettivo:** l'app completa e usabile: login/registrazione, CRUD task con
optimistic updates, filtri con debounce, liste, tag e vista calendario.

**Costruisci:**
- Schermate login/registrazione con validazione e `AuthNotifier`; GoRouter con
  **route guard** (non autenticato → login) e `StatefulShellRoute` per i tab
  con stack indipendenti.
- Lista task con stati loading/errore/vuoto distinti, pull-to-refresh,
  cancellazione ottimistica (UI subito, revert se il server fallisce).
- Editor task riusabile per creazione e modifica; filtri per stato/priorità/testo
  con **debounce** sulla ricerca; liste e tag con assegnazione e filtro.
- Vista calendario (`table_calendar`) con il raggruppamento dei task per giorno
  implementato come **funzione pura con il tempo iniettato** (testabile senza orologio).

**Risorse:**
1. 🎯 Flutter Foundations — sezioni su GoRouter, form e testing.
2. 🆓 [Code with Andrea — articoli su GoRouter](https://codewithandrea.com/articles/) (redirect, guard, shell route).
3. 🆓 [Flutter — testing docs](https://docs.flutter.dev/testing/overview) — widget test e mocking con mocktail.

**Nel repo:** entry [C17](../journal/C17-auth-ui-router.md),
[C19](../journal/C19-task-list-screen.md), [C20](../journal/C20-task-edit-detail.md),
[C23](../journal/C23-app-shell.md), [C26](../journal/C26-frontend-filter-bar.md),
[C27](../journal/C27-due-grouping.md), [C31](../journal/C31-frontend-lists-drawer.md)–[C33](../journal/C33-calendar-view.md).
File: [`app_router.dart`](../frontend/lib/core/router/app_router.dart).

**Verifica (Definition of Done):**
- [ ] Flusso completo a mano contro il TUO backend della Parte 1: registrazione → login → crea task → filtra → assegna tag → vedi il task nel calendario.
- [ ] Il raggruppamento per scadenza è una funzione pura con test che coprono i confini (mezzanotte, "oggi" vs "domani").
- [ ] La ricerca non spara una richiesta per ogni tasto premuto (debounce testato).
- [ ] `flutter analyze` pulito e `flutter test` verde.

---

### F2.4 — Design system, dark mode, dashboard (~1 settimana)

**Obiettivo:** dare all'app un'identità visiva coerente (Material 3, tema chiaro
e scuro persistito) e una dashboard con grafici.

**Costruisci:**
- Tema Material 3 da seed color, `ThemeExtension` per i colori custom, toggle
  chiaro/scuro persistito con `shared_preferences`.
- Dashboard: stat tile (totali, completati, overdue), grafico a barre dei
  completamenti settimanali e donut delle priorità con `fl_chart`.

**Risorse:**
1. 🆓 [Material 3](https://m3.material.io/) — capisci seed color e ruoli dei colori.
2. 🆓 [fl_chart — documentazione](https://pub.dev/packages/fl_chart).
3. 🎯 Flutter Foundations — sezione theming.

**Nel repo:** entry [C22](../journal/C22-design-system-dark-mode.md),
[C35](../journal/C35-dashboard-charts.md) (nota il principio "prima la forma,
poi il colore" nei grafici). File: `frontend/lib/core/theme/`.

**Verifica (Definition of Done):**
- [ ] Il tema scelto sopravvive al riavvio dell'app.
- [ ] La dashboard mostra dati veri dal backend e i grafici hanno test che ne verificano l'aggregazione.
- [ ] `flutter test` verde. **Milestone: hai un fullstack mobile completo.**

---

## Parte 3 — Webapp React

Il secondo client, stesso backend. Replicherai C39–C59. Qui il pilastro è la
sottoscrizione **Frontend Masters**. Il valore didattico di questa parte è
doppio: impari React, e impari a **riconoscere gli stessi problemi già risolti
in Flutter** (refresh dei token, cache, raggruppamenti) risolti con altri
strumenti.

### F3.1 — JavaScript moderno + TypeScript strict (~1,5 settimane)

**Obiettivo:** capire davvero closure, promesse ed event loop, e scrivere
TypeScript in modalità strict senza `any`.

**Costruisci:**
- Esercizi dei corsi + i soliti kata riscritti in TypeScript (terza lingua:
  ormai il confronto Java/Dart/TS è un tuo superpotere).
- Una funzione `debounce` scritta a mano con test — la riuserai concettualmente
  in F3.4.

**Risorse:**
1. ⭐ [JavaScript: The Hard Parts, v3 (Will Sentance)](https://frontendmasters.com/courses/javascript-hard-parts-v3/) — closure, event loop, promesse. Il corso che sistema le fondamenta.
2. ⭐ [TypeScript: From First Steps to Professional (Anjana Vakil)](https://frontendmasters.com/courses/typescript-first-steps/) — poi, più avanti, [React and TypeScript, v3 (Steve Kinney)](https://frontendmasters.com/courses/react-typescript-v3/).
3. 🆓 [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html) come riferimento.

**Nel repo:** guarda [`webapp/tsconfig.app.json`](../webapp/tsconfig.app.json):
strict totale. È lo standard a cui punti.

**Verifica (Definition of Done):**
- [ ] Sai spiegare closure ed event loop con un disegno, senza guardare.
- [ ] La tua `debounce` tipizzata compila in strict e ha test verdi.
- [ ] Zero `any` nel codice che scrivi da qui in avanti.

---

### F3.2 — React, Vite, Tailwind, router (~1 settimana)

**Obiettivo:** lo scheletro della webapp: componenti, layout route con shell di
navigazione, design system con Tailwind v4 + shadcn/ui, tema chiaro/scuro.

**Costruisci:**
- Progetto Vite + React + TS strict + Vitest.
- Router (React Router in library mode): pagine auth *fuori* dalla shell,
  tutto il resto dentro un layout con sidebar/topbar (`Outlet`).
- Tailwind v4 con i design token M3 come variabili CSS; componenti base shadcn/ui;
  toggle di tema persistito.

**Risorse:**
1. ⭐ [Complete Intro to React, v9 (Brian Holt)](https://frontendmasters.com/courses/complete-react-v9/) — il corso principale.
2. 🆓 [react.dev — Learn](https://react.dev/learn) — la nuova documentazione ufficiale è eccellente; usala in parallelo.
3. ⭐ [Tailwind CSS 4+ (Steve Kinney)](https://frontendmasters.com/courses/tailwind-css-v2/) e 🆓 [ui.shadcn.com](https://ui.shadcn.com/).

**Nel repo:** entry [C39](../journal/C39-webapp-scaffold.md)–[C41](../journal/C41-webapp-router-shell.md).
File: [`webapp/src/lib/router.tsx`](../webapp/src/lib/router.tsx) — nota come
rispecchia `app_router.dart`: stessa forma, piattaforma diversa.

**Verifica (Definition of Done):**
- [ ] `npm run lint && npm run typecheck && npm test && npm run build` tutto verde (questo è il gate di *ogni* commit da qui in poi, come nel repo).
- [ ] Navigazione fra pagine con shell persistente; il tema sopravvive al reload.

---

### F3.3 — Server state: TanStack Query, auth, cache (~1,5 settimane)

**Obiettivo:** il cuore concettuale della parte web: distinguere client state da
server state, generare i tipi dall'OpenAPI del backend, e replicare il refresh
trasparente dei token — stavolta con una promessa condivisa.

**Costruisci:**
- Tipi API **generati** dallo schema OpenAPI del tuo backend
  (`openapi-typescript`): il contratto non si trascrive a mano.
- Client `fetch` tipizzato con errori strutturati.
- `ensureFreshToken()` con **promessa condivisa** fra chiamate concorrenti,
  margine di scadenza, refresh proattivo (prima della richiesta) e reattivo
  (dopo un 401), **un solo** replay.
- Stato auth in uno store zustand *fuori* dall'albero React + route guard.
- Data layer task con TanStack Query: chiavi di cache gerarchiche
  (`['tasks', filtri]`), invalidazione per prefisso, optimistic updates con
  rollback in `onError`.

**Risorse:**
1. 🆓 [TanStack Query — docs ufficiali](https://tanstack.com/query/latest) — fra le migliori documentazioni esistenti.
2. 🆓 [TkDodo — Practical React Query](https://tkdodo.eu/blog/practical-react-query) — la serie di blog del maintainer: lettura obbligatoria su query keys e invalidazione.
3. ⭐ [Intermediate React, v6 (Brian Holt)](https://frontendmasters.com/courses/intermediate-react-v6/) — per hooks avanzati e performance.
4. 🆓 [openapi-typescript](https://openapi-ts.dev/) — docs del generatore usato nel repo.

**Nel repo:** entry [C42](../journal/C42-webapp-openapi-types.md)–[C47](../journal/C47-webapp-task-data-layer.md),
in particolare [C44](../journal/C44-webapp-refresh-interceptor.md) — una delle
migliori del journal. File:
[`webapp/src/lib/auth/refresh.ts`](../webapp/src/lib/auth/refresh.ts),
[`webapp/src/features/tasks/queries.ts`](../webapp/src/features/tasks/queries.ts).

**Verifica (Definition of Done):**
- [ ] Test (imitando quelli di C44): **due 401 simultanei producono UNA sola chiamata a `/auth/refresh`** ed entrambe le richieste vengono ripetute col token nuovo.
- [ ] Un secondo 401 dopo il replay propaga l'errore (niente loop).
- [ ] Rigenerando i tipi dall'OpenAPI, un campo rinominato nel backend produce un errore di compilazione nella webapp (provalo davvero).
- [ ] Creare/modificare un task aggiorna la UI immediatamente e fa rollback se il server fallisce (test).

> **💡 Approfondimento — la corsa dei 401 simultanei, due soluzioni.**
> Il backend ruota i refresh token: ogni token vale un solo uso. Ma la pagina
> dei task carica task, liste e tag *in parallelo*; se l'access token è appena
> scaduto, arrivano tre 401 quasi insieme. Se ognuno rinnovasse per conto suo,
> il secondo presenterebbe un token già bruciato → 401 → utente buttato fuori
> con una sessione perfettamente valida. Il refresh va **serializzato**.
> Flutter lo fa con `QueuedInterceptor` (una coda che processa gli errori uno
> alla volta — C15). La webapp lo fa con tre righe: una promessa a livello di
> modulo assegnata con `??=` — il primo 401 crea la promessa, gli altri
> *aspettano la stessa promessa* (C44). Stesso problema, due primitive diverse:
> quando sai riconoscere il problema indipendentemente dal linguaggio, sei
> diventato fullstack.

> **💡 Approfondimento — client state vs server state.**
> Il tema scelto dall'utente è *client state*: vive nel browser, sei tu la
> fonte di verità (→ zustand). La lista dei task è *server state*: la fonte di
> verità è il backend, tu ne hai solo una **cache** — che quindi può essere
> stantia, va invalidata, rivalidata, aggiornata ottimisticamente. TanStack
> Query esiste per questo secondo problema. Confondere i due (mettere i task
> "in uno store") è l'errore più comune nelle codebase React.

---

### F3.4 — Feature parity: form, filtri, calendario, dashboard (~1 settimana)

**Obiettivo:** portare la webapp alla parità di funzionalità col client Flutter,
scegliendo però le interazioni giuste per il desktop.

**Costruisci:**
- Form con react-hook-form + zod (login, registrazione, editor task).
- Filtri con **lo stato nell'URL** (condivisibile con un link — cosa che il
  mobile non può fare), ricerca con debounce.
- Liste, tag, vista calendario (griglia costruita a mano), dashboard con Recharts.
- Test Vitest + Testing Library con un mock del backend, riusando le stesse
  logiche pure (due-grouping) già scritte per Flutter — stavolta in TS.

**Risorse:**
1. 🆓 [react-hook-form docs](https://react-hook-form.com/) + [zod docs](https://zod.dev/).
2. ⭐ [Testing Fundamentals (Steve Kinney)](https://frontendmasters.com/courses/testing/) — filosofia e pratica dei test frontend.
3. 🆓 [Testing Library — Guiding principles](https://testing-library.com/docs/guiding-principles/) — testa ciò che l'utente vede, non l'implementazione.

**Nel repo:** entry [C46](../journal/C46-webapp-auth-ui.md),
[C48](../journal/C48-webapp-due-grouping.md)–[C58](../journal/C58-webapp-polish.md).
Nota in [C49](../journal/C49-webapp-task-list.md) e [C52](../journal/C52-webapp-lists.md)
le divergenze *argomentate* dal client mobile: swipe→hover, stato nell'URL.

**Verifica (Definition of Done):**
- [ ] Parità di feature verificata a mano sulle due UI, fianco a fianco, sullo stesso backend.
- [ ] Un URL con filtri incollato in una scheda nuova riproduce esattamente la stessa vista.
- [ ] Gate completo verde: `npm run lint && npm run typecheck && npm test && npm run build`.
- [ ] **Milestone: un backend, due client. Sei operativamente fullstack.**

---

## Parte 4 — Il mestiere

Le ultime due fasi non aggiungono feature: aggiungono *giudizio*. Sono ciò che
distingue chi sa scrivere codice da chi sa mantenere un sistema.

### F4.1 — Sistemi condivisi: monorepo, design token, golden fixtures (~1 settimana)

**Obiettivo:** far convivere tre codebase in un monorepo senza che derivino:
una sola fonte di verità per il design, ed equivalenza *dimostrata* (non
sperata) della logica di dominio duplicata.

**Costruisci:**
- Un file `tokens.json` unico + un generatore Node che emette sia il Dart del
  tema Flutter sia il CSS della webapp, con una modalità `--check` che fallisce
  se i file generati non sono aggiornati.
- Fixture JSON condivise per la logica duplicata nei due client (es. il
  raggruppamento per scadenza): gli stessi input e output attesi caricati sia
  dai test Dart sia dai test Vitest.

**Risorse:**
1. 🆓 [Design tokens — W3C Community Group](https://design-tokens.github.io/community-group/format/) — il concetto, non serve lo standard completo.
2. 🆓 Rileggi [C60](../journal/C60-shared-design-tokens.md) e [C61](../journal/C61-domain-golden-fixtures.md) — qui il journal *è* la risorsa: non esiste un corso su questo, esiste il ragionamento.

**Nel repo:** [`tokens/tokens.json`](../tokens/tokens.json),
[`tokens/generate.mjs`](../tokens/generate.mjs), [`fixtures/`](../fixtures/)
col suo [README](../fixtures/README.md).

**Verifica (Definition of Done):**
- [ ] Cambiare un colore in `tokens.json` + rigenerare aggiorna *entrambi* i client; il `--check` fallisce se dimentichi di rigenerare.
- [ ] Un caso limite aggiunto alla fixture fa fallire i test di **entrambi** i client finché entrambe le implementazioni non lo gestiscono.

> **💡 Approfondimento — equivalenza dimostrata, non tradotta.**
> Quando la stessa logica esiste in due linguaggi (il due-grouping in Dart e in
> TS), la tentazione è "tradurre con attenzione" e sperare. Le golden fixtures
> rovesciano l'approccio: un file JSON neutrale definisce input e output attesi,
> e ogni client ha un test che lo carica e verifica la propria implementazione.
> La specifica diventa un artefatto condiviso ed eseguibile: se le
> implementazioni divergono, lo dice un test rosso, non un bug report.

---

### F4.2 — Oltre il repo: ciò che manca, di proposito (~2 settimane)

**Obiettivo:** proseguire da solo. Il repo dichiara onestamente cosa *non* ha
ancora — è la tua palestra di livello successivo.

**Costruisci (in ordine di valore):**
1. **CI/CD con GitHub Actions**: tre workflow (backend con Testcontainers,
   Flutter, webapp) che girano su ogni PR + il `--check` dei token. Badge nel README.
   - 🆓 [GitHub Actions — docs](https://docs.github.com/en/actions) · 🎯 [Flutter in Production (Code with Andrea)](https://codewithandrea.com/courses/flutter-in-production/) copre proprio CI/CD e deploy per Flutter.
2. **Offline-first nel client Flutter** con [Drift](https://drift.simonbinder.eu/)
   (SQLite): repository a doppia sorgente, coda di sync, conflitti last-write-wins.
   La fase 7 di [ROADMAP.md](ROADMAP.md) la descrive in dettaglio, settimana per settimana.
3. **Real-time con SSE**: `SseEmitter` in Spring, EventSource nei client,
   riconnessione con exponential backoff (fase 8 di ROADMAP.md).

**Esercizio finale — leggere codice con occhio critico:** leggi
[`doc/CODE_REVIEW.md`](CODE_REVIEW.md), la review onesta di questo stesso repo,
findings ordinati per severità. Per ognuno chiediti: lo avevo notato? So
spiegare perché è un problema? Saprei correggerlo? Poi correggine almeno due
(l'i18n con le stringhe hardcoded è un ottimo candidato).

**Verifica (Definition of Done):**
- [ ] Una PR sul tuo progetto viene bloccata dalla CI se un test è rosso, su qualunque dei tre lati.
- [ ] Almeno 2 finding della code review corretti nel tuo clone, test-first.
- [ ] Sai raccontare il progetto in 5 minuti: architettura, 3 decisioni di cui vai fiero, 3 cose che manca(no) e perché. Questo racconto **è** il tuo colloquio.

---

## E adesso?

Se sei arrivato qui con tutte le verifiche verdi, non hai "finito un corso":
hai costruito un sistema fullstack a tre teste con TDD, sicurezza reale e
decisioni argomentate — che è esattamente ciò che fa uno sviluppatore di mestiere.

Cosa dice di te questo percorso, e come usarlo:

- **Il progetto è il portfolio.** Non il codice in sé: il *journal* che sai
  scrivere tu stesso, i test che dimostrano i comportamenti, la CI verde.
- **Sai imparare stack nuovi**: hai attraversato Java, Dart e TypeScript
  riconoscendo gli stessi problemi sotto sintassi diverse. È la competenza che
  invecchia più lentamente.
- **Il percorso continua**: deploy in produzione, osservabilità, sicurezza
  offensiva, database ad alte prestazioni, architettura, AI engineering e
  carriera sono il capitolo successivo — ti aspetta in
  **[`LEARNING_PATH_2.md`](LEARNING_PATH_2.md)**, con lo stesso metodo e lo
  stesso laboratorio: questo progetto.

Buon lavoro. Una fase alla volta, sempre col test rosso prima. 🚦
