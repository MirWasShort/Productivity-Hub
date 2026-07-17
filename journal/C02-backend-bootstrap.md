# C02 — Bootstrap del backend Spring Boot + PostgreSQL in Docker

## Cosa è stato fatto

- Generato il progetto `backend/` da [start.spring.io](https://start.spring.io)
  (via `curl`, senza passare dal browser): Gradle Kotlin DSL, Java 21,
  Spring Boot 4.0.7, package `com.smarttodo`, con gli starter **Web (MVC)**,
  **Data JPA**, **PostgreSQL**, **Flyway**, **Validation**, **Security**,
  **Actuator**, **Testcontainers**.
- Aggiunte a mano in `build.gradle.kts` le dipendenze che start.spring.io non
  offre: **jjwt 0.13** (la libreria JWT che useremo per l'autenticazione,
  divisa in `api`/`impl`/`jackson`) e **springdoc-openapi 3** (Swagger UI).
- Sostituito `application.properties` con `application.yml`: datasource
  PostgreSQL locale, `ddl-auto: validate`, `open-in-view: false`, e le
  proprietà JWT (`app.jwt.*`) con il segreto sovrascrivibile via variabile
  d'ambiente `APP_JWT_SECRET`.
- Creato `docker-compose.yml` alla radice del repo: PostgreSQL 16 (alpine)
  con healthcheck e volume persistente.
- Nella configurazione Testcontainers generata, cambiata l'immagine da
  `postgres:latest` a `postgres:16-alpine`: i test devono girare sulla
  **stessa versione** del database di sviluppo/produzione, non su "l'ultima
  che capita".

## Perché

**Perché Spring Boot 4 e non 3.x come dice la SPEC?** start.spring.io oggi
offre solo la linea 4.x (la 3.5 è uscita dal supporto OSS a giugno 2026).
Meglio partire supportati che inseguire una versione morente. Le differenze
che ci toccano: gli starter sono più granulari (`spring-boot-starter-webmvc`
invece di `-web`, e ogni starter ha il suo `-test`), e nei test web si usa
`@MockitoBean` al posto del vecchio `@MockBean`.

**Perché `ddl-auto: validate` e non `update`?** Con `update` Hibernate
modifica lo schema da solo in base alle entity — comodo all'inizio,
catastrofico poi: lo schema diventa il risultato accidentale della storia
delle tue classi. Con `validate` lo schema è governato **solo** dalle
migrazioni Flyway, e se un'entity non corrisponde alla tabella l'app *si
rifiuta di partire* — l'errore emerge subito, non a runtime tre settimane
dopo.

**Perché `open-in-view: false`?** Il default (`true`) tiene la sessione
Hibernate aperta per tutta la richiesta HTTP, mascherando le lazy-loading
exception ma incoraggiando query implicite dalla view. Disattivarlo obbliga
a caricare esplicitamente ciò che serve — Spring stesso logga un warning se
lo lasci al default.

**Perché il segreto JWT sta in `application.yml`?** Solo il valore di
*sviluppo*. La riga `${APP_JWT_SECRET:dev-only-...}` significa "usa la
variabile d'ambiente se c'è, altrimenti il fallback dev". In produzione il
segreto arriva dall'ambiente e non è mai committato. (Mai committare segreti
veri: finiscono nella storia di Git per sempre.)

**Perché Testcontainers invece di un database H2 in memoria?** H2 *somiglia*
a PostgreSQL ma non lo è (tipi, funzioni, comportamento delle transazioni
differiscono). Testcontainers avvia un PostgreSQL **vero** in un container
usa-e-getta per i test: `./gradlew test` è autosufficiente (serve solo
Docker) e testa contro lo stesso motore della produzione. È anche la
raccomandazione esplicita della ROADMAP (Fase 1: "Skipping Testcontainers
and using H2 instead" è elencato tra gli errori da evitare).

## Come funziona

- **Gradle wrapper** (`./gradlew`): script committato nel repo che scarica
  da solo la versione giusta di Gradle (qui 9.5.1). Chiunque cloni il repo
  builda con la stessa versione, senza installare nulla. Nota WSL: Gradle
  vuole `JAVA_HOME`, che con asdf va esportato a mano
  (`export JAVA_HOME="$(asdf where java)"`).
- **`@ServiceConnection`** (in `TestcontainersConfiguration`): Spring Boot
  vede il bean `PostgreSQLContainer` e configura *da solo* url/user/password
  del datasource di test puntando al container. Niente proprietà duplicate.
- **docker-compose healthcheck**: `pg_isready` viene eseguito dentro il
  container finché il DB non accetta connessioni; `docker compose ps` mostra
  `healthy` quando è pronto davvero (un container "Up" non è ancora un DB
  utilizzabile).

## Il ciclo TDD in questo commit

Il test è `contextLoads()`, generato dallo starter: sembra vuoto ma verifica
molto — l'intero application context di Spring si costruisce, il container
PostgreSQL parte, Flyway si connette. È il "verde" di base su cui poggerà
tutto il resto: se una dipendenza è rotta o una configurazione è invalida,
questo test fallisce prima ancora di scrivere una riga di logica.

## Concetti chiave

- **Schema migration** (Flyway): lo schema del DB è codice versionato, non
  uno stato che Hibernate "aggiusta".
- **Testcontainers**: test d'integrazione contro infrastruttura reale ma
  effimera.
- **Configurazione esternalizzata**: i valori sensibili arrivano
  dall'ambiente (12-factor app), il file committato contiene solo default di
  sviluppo.
- **Gradle wrapper**: build riproducibile per chiunque cloni il repo.

## Per approfondire

- [Spring Boot reference — Getting Started](https://docs.spring.io/spring-boot/index.html)
- [Testcontainers + Spring Boot](https://docs.spring.io/spring-boot/reference/testing/testcontainers.html) (in particolare `@ServiceConnection`)
- [Flyway — Why database migrations?](https://documentation.red-gate.com/fd/why-database-migrations-184127574.html)
- [The Twelve-Factor App — Config](https://12factor.net/config)
- [Don't use open-in-view](https://vladmihalcea.com/the-open-session-in-view-anti-pattern/) (Vlad Mihalcea)
- ROADMAP: Fase 1, Settimane 5-6 e kata 1.2 (Docker Compose Playground)
