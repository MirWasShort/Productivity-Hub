# C36 — Documentazione e verifica finale del secondo blocco

## Cosa è stato fatto

- **Verifica completa end-to-end**, eseguita prima del commit:
  - `./gradlew test` — intera suite backend verde (unit, slice,
    Testcontainers, AuthFlowIT);
  - DB pulito (`docker compose down -v`) → `bootRun` → **migrazioni V1–V8
    applicate in ordine** (verificato su `flyway_schema_history`);
  - smoke test curl dei flussi nuovi: crea lista + tag, tag duplicato →
    409, task con lista+tag, filtro per tag/lista/ricerca, sort invalido
    → 400, completamento → analytics summary + completions coerenti;
  - `flutter analyze` pulito, `flutter test` ~125 verdi,
    `flutter build web` compilato.
- **README.md**: elenco feature aggiornato (liste/tag, filtri, scadenze,
  calendario, dashboard, dark mode).
- **DEMO.md**: nuovo percorso demo d'impatto (dark mode → filtri → liste/
  tag → scadenze → calendario → dashboard) sopra i flussi base; conteggi
  aggiornati.
- **CLAUDE.md**: stack esteso, elenco V1–V8 con "next is V9", stato
  onesto (cosa c'è / cosa manca).

## Perché

**Perché la verifica su DB pulito?** Ogni commit ha verificato il suo
incremento contro un database che accumulava schema. La prova finale
parte da zero e applica V1→V8 in sequenza: dimostra che un nuovo
sviluppatore, clonando e facendo `docker compose up`, ottiene lo schema
completo senza sorprese. Le migrazioni sono immutabili e ordinate; questo
test lo certifica.

**Perché aggiornare la demo, non solo aggiungere?** Il pubblico di una
demo ha attenzione limitata: va mostrato *prima* ciò che colpisce (dark
mode, dashboard, calendario) e *dopo* le fondamenta (auth, isolamento,
refresh). Riordinare il DEMO.md per impatto è parte del lavoro tanto
quanto il codice: una feature che nessuno vede in demo è, per la demo,
inesistente.

**Lo stato in CLAUDE.md dice ancora cosa manca.** Offline-first, SSE,
notifiche, CI restano fuori (fasi 7-9 della roadmap). Dichiararlo evita
che la documentazione prometta più di quanto il codice mantenga — la
stessa disciplina di C21.

## Il secondo blocco in sintesi (C22–C36)

Partiti da un'app auth+task funzionante ma spartana, in 15 commit
incrementali (tutti verdi, tutti runnabili, ognuno col suo journal):

- **Design**: Material 3 con dark mode persistito, `ThemeExtension` per
  le priorità, task card, empty state, shell a 3 tab.
- **Produttività**: filtri/ricerca/ordinamento (JPA Specification lato
  server), scadenze intelligenti con raggruppamento e overdue.
- **Organizzazione**: liste e tag full-stack (V4–V7), con filtri
  integrati, drawer, multi-select nell'editor.
- **Pianificazione**: vista calendario con granularità mese/settimana.
- **Analisi**: dashboard con statistiche e grafici (V8 `completed_at`),
  progettata seguendo la skill dataviz.

Nuove tabelle: 5 (todo_lists, tags, task_tags, +2 colonne). Nuovi
endpoint: liste, tag, analytics, e i filtri estesi sui task. Test saliti
da ~120 a ~215 tra i due lati.

## Come continuare

La roadmap indica le fasi 7-9: **offline-first con Drift** (il salto
architetturale più grande — sync e conflict resolution), **real-time con
SSE**, **notifiche locali**, **CI/CD**. Il journal di questi 36 commit è
il manuale: ogni nuovo full-stack slice ripercorre lo stampo di C09
(backend) e C18–C20 (frontend), test-first.

## Concetti chiave (dell'intera evoluzione)

- **Design prima delle feature**: il tema e la shell costruiti per primi,
  così ogni schermata nasce coerente.
- **Il filtro vive nel server**: il client esprime criteri, il DB decide.
- **Una regola, implementazioni che combaciano**: overdue identico in
  lista, card e dashboard.
- **Forma prima del colore**: i grafici seguono la disciplina dataviz.
- **Ogni commit runnabile, ogni commit documentato**: la storia di git è
  una sequenza di stati funzionanti con la loro spiegazione.

## Per approfondire

- [journal/README.md](README.md) — l'indice completo C01–C36
- doc/ROADMAP.md, Fasi 7-9 — i prossimi passi
- [DEMO.md](../DEMO.md) — come mostrarlo
