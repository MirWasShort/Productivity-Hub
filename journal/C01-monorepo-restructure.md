# C01 — Ristrutturazione del repo in monorepo backend/frontend

## Cosa è stato fatto

- Rimossi tutti i file della vecchia app Flutter che viveva alla radice del
  repo: `lib/`, `test/`, le cartelle di piattaforma (`android/`, `ios/`,
  `web/`, `windows/`, `linux/`, `macos/`), `pubspec.yaml`, `pubspec.lock`,
  `analysis_options.yaml`, `.metadata`.
- `Initial_documentation/` è diventata `doc/` (con `git mv`, che preserva la
  storia dei file).
- `CLAUDE.md` è stato spostato alla radice del repo: è un file di guida per
  lo sviluppo e si aspetta di trovare la documentazione in `doc/` — ora i
  percorsi che cita (`doc/SPEC.md`, `doc/ROADMAP.md`) esistono davvero.
- Riscritti `README.md` (era il boilerplate di `flutter create`) e
  `.gitignore` (era quello di un progetto Flutter singolo; ora copre un
  monorepo con `backend/` e `frontend/`).
- Creata questa directory `journal/`.

Il layout di arrivo:

```
backend/            # (dal prossimo commit) Spring Boot API
frontend/           # (più avanti) app Flutter
doc/                # SPEC.md, ROADMAP.md
journal/            # questo diario
docker-compose.yml  # (dal prossimo commit) PostgreSQL
```

## Perché

**Perché buttare via il codice esistente?** La vecchia app era un prototipo
da tutorial: `setState` ovunque, chiamate HTTP a Firebase con l'URL hardcoded
in 4 punti diversi, un bug per cui lo swipe-to-delete cancellava *l'intero
database* invece del singolo task, zero test reali. La `SPEC.md` descrive
tutt'altro progetto: backend Java con architettura esagonale, JWT, PostgreSQL,
frontend Clean Architecture. Rifattorizzare il prototipo verso quella meta
sarebbe costato più che ripartire — e non c'era niente da salvare che non si
riscriva in un'ora.

**Perché un monorepo?** Frontend e backend evolvono insieme (un endpoint nuovo
= un data source nuovo), condividono la documentazione e il ciclo di vita.
Due repo separati hanno senso quando team diversi lavorano a ritmi diversi;
per un progetto da portfolio di una persona sola, un monorepo è più semplice
da navigare, da clonare e da raccontare. L'alternativa (repo separati +
submodule o link incrociati) aggiunge attrito senza benefici qui.

**Perché il lavoro avviene su un feature branch** (`feature/monorepo-rewrite`)
e non su `main`? È la GitHub flow descritta anche nella ROADMAP (Fase 0,
settimana 4): `main` resta sempre nello stato "funzionante noto", il lavoro
grosso avviene su un branch e arriva su `main` tramite una pull request che
si può rivedere commit per commit.

## Come funziona

Due dettagli di Git che vale la pena capire:

- `git mv vecchio nuovo` è equivalente a `mv` + `git add`: Git non traccia
  "rinomine" come operazioni native, le *rileva* confrontando i contenuti.
  Usare `git mv` rende l'intenzione esplicita e mantiene il diff pulito
  (vedrai `renamed: Initial_documentation/SPEC.md -> doc/SPEC.md`).
- `git rm -r` rimuove i file sia dal working tree sia dall'*index* (l'area di
  staging). Se un file ha modifiche staged non ancora committate, Git rifiuta
  di cancellarlo per proteggerti — serve `-f` per confermare che sai cosa
  stai facendo (ci è successo con `doc/README.md`).

## Il ciclo TDD in questo commit

Niente codice, niente test: è un commit di sola ristrutturazione. Il criterio
di "verde" qui è che il repo sia in uno stato coerente: nessun file orfano,
documentazione raggiungibile ai percorsi che `CLAUDE.md` dichiara, `git
status` pulito dopo il commit. Il TDD vero comincia dal prossimo commit.

## Concetti chiave

- **Monorepo**: un repository, più progetti correlati. Semplifica sviluppo
  coordinato e onboarding; il costo (build più complesse, permessi granulari)
  si paga solo su scale molto più grandi.
- **Feature branch / GitHub flow**: `main` sempre deployabile, lavoro su
  branch, merge via pull request.
- **Rewrite vs refactor**: si riscrive quando il costo di trasformare il
  codice esistente supera quello di ripartire — raro nei progetti maturi,
  frequente nei prototipi.

## Per approfondire

- [Pro Git, cap. 2-3](https://git-scm.com/book/en/v2) — fondamenti di Git, branching
- [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow)
- [Monorepo explained](https://monorepo.tools/) — panoramica pro/contro
- ROADMAP: Fase 0, Settimana 4 ("Git & Tooling") e kata 0.5 (Git Kata)
