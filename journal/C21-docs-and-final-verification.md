# C21 — Documentazione finale e verifica end-to-end

## Cosa è stato fatto

- **Verifica completa del sistema**, eseguita per davvero prima di
  questo commit:
  - `./gradlew test` — tutta la suite backend verde (unit, slice,
    Testcontainers IT, AuthFlowIT end-to-end);
  - `./gradlew bootRun` + smoke test curl sull'app viva: health,
    register, create task (TODO), list (totalElements=1), update a DONE,
    delete (204), Swagger UI raggiungibile (200), preflight CORS da
    `localhost:5555` accettata (200);
  - `flutter analyze` pulito, `flutter test` — 59 test verdi;
  - `flutter build web` — l'app compila in bundle web di produzione.
- **`README.md`** aggiornato: stack reale, feature implementate,
  istruzioni di run corrette (porta 8081, `JAVA_HOME`, dart-define).
- **`CLAUDE.md`** riscritto: comandi *reali* (non più "planned"),
  convenzioni del repo (TDD, journal per commit, note Boot 4, migrazioni
  immutabili), stato attuale onesto — cosa c'è e cosa manca rispetto
  alla roadmap.

## Perché

**Perché la verifica finale se ogni commit era già verde?** Ogni commit
verificava *il proprio* incremento. Questo giro finale ripercorre tutto
in sequenza sull'ambiente pulito — è la prova generale che chiunque
cloni il repo e segua il README arriva a un sistema funzionante. La
documentazione che descrive comandi mai eseguiti è la forma più comune
di documentazione falsa.

**Perché CLAUDE.md dettagliato?** È il file che un assistente AI (o un
umano frettoloso) legge per primo: comandi esatti, convenzioni, trappole
note (JAVA_HOME con asdf, `@MockitoBean`, package di test Boot 4,
codegen). Ogni trappola documentata è un'ora di debugging risparmiata a
chi arriva dopo.

**La sezione "Current Status" dice anche cosa manca.** Il progetto
originale aveva un CLAUDE.md che dichiarava "nessun codice implementato"
accanto a un'app esistente — documentazione e realtà divergenti. La
regola adottata: lo stato dichiara sempre entrambe le metà, il fatto e
il non-ancora.

## Dove siamo rispetto alla SPEC

Implementato (Fasi 1-5 della roadmap, compresse):
- ✅ Backend esagonale: dominio puro, port/adapter, Flyway V1-V3
- ✅ Auth completa: register, login, refresh **con rotazione**, BCrypt,
  token opachi hashati a riposo
- ✅ Task CRUD scoped per utente (404 sugli altrui), paginato
- ✅ Error contract unico + Swagger + CORS
- ✅ Frontend Clean Architecture: Riverpod 3, Dio con refresh
  trasparente, GoRouter con guardie, secure storage
- ✅ Schermate: login, registrazione, lista (empty/error/loading,
  swipe-delete, quick-add), dettaglio, form create/edit
- ✅ ~120 test totali tra backend e frontend, tutti nati prima del codice

Non implementato (fasi successive della roadmap, tagli dichiarati nel
piano): liste/tag/filtri (Fase 6), offline-first con Drift (Fase 7),
SSE/notifiche/analytics (Fase 8), CI/CD e Docker del backend (Fase 9),
forgot-password, rate limiting, logout server-side.

## Come continuare

Il percorso è tracciato dalla ROADMAP: il prossimo incremento naturale è
la **Fase 6** (liste e tag), che ripercorre esattamente il ciclo visto
in questi 21 commit — migrazione → dominio → port → service → controller
→ modello → datasource → notifier → schermata, ogni passo test-first.
Il journal di questi commit è il manuale di istruzioni: C09 per il
pattern backend completo, C18-C20 per quello frontend.

## Concetti chiave (dell'intero progetto)

- **Ogni commit è runnabile**: la storia di git è una sequenza di stati
  funzionanti, non un percorso di macerie con un lieto fine.
- **TDD come metodo, non cerimonia**: i test hanno intercettato bug veri
  (toJson shallow, CSRF nelle slice, controller disposed, fallback che
  mangiava i 400) *prima* che arrivassero in produzione.
- **I tagli si dichiarano**: ciò che manca è scritto, non nascosto.
- **La documentazione si verifica** come il codice: eseguendo ciò che
  promette.

## Per approfondire

- [journal/README.md](README.md) — l'indice di tutto il percorso
- doc/ROADMAP.md, Fase 6 — il prossimo passo
- [Keep a Changelog](https://keepachangelog.com/) e [Conventional Commits](https://www.conventionalcommits.org/) — le convenzioni dietro i messaggi di commit di questo repo
