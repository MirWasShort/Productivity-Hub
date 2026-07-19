# Webapp (React + TypeScript)

Client **web** dello Smart TODO, fratello del client Flutter in
[`../frontend`](../frontend) (che resta il client mobile). Stesso backend,
stesso feeling, interfaccia pensata per il desktop.

## Stack

| Ambito       | Scelta                                                                 |
| ------------ | ---------------------------------------------------------------------- |
| Build        | Vite 8, React 19, TypeScript strict                                    |
| Stile        | Tailwind v4 + shadcn/ui, token presi dal Material 3 del client Flutter |
| Rotte        | React Router v7 (library mode)                                         |
| Dati server  | TanStack Query v5                                                      |
| Stato client | zustand (sessione, tema)                                               |
| Form         | react-hook-form + zod                                                  |
| Date         | date-fns (locale `it`)                                                 |
| Grafici      | Recharts                                                               |
| Test         | Vitest + Testing Library                                               |
| Qualità      | oxlint, Prettier                                                       |

## Comandi

```bash
npm install
npm run dev          # http://localhost:5173
npm run typecheck    # tsc -b
npm run lint         # oxlint
npm test             # vitest run
npm run build        # tsc -b && vite build
npm run preview      # serve la build di produzione
npm run format       # prettier --write .
npm run generate:api # rigenera src/api/schema.d.ts dal backend acceso
```

Il gate prima di ogni commit è
`npm run lint && npm run typecheck && npm test && npm run build`.

## Configurazione

`VITE_API_BASE_URL` (default `http://localhost:8081`, vedi `.env.development`)
indica l'host del backend; il client vi appende `/api/v1`. È l'equivalente web
del `--dart-define=API_BASE_URL` di Flutter.

Il backend dev'essere in esecuzione (`docker compose up -d` e `./gradlew
bootRun` dalla radice del monorepo): accetta CORS da qualunque
`http://localhost:*`.

## Struttura

```
src/
├── api/            schema.d.ts (generato) e tipi di dominio
├── components/     ui/ (shadcn), layout/ (shell, sidebar, stati vuoti)
├── features/       auth, tasks, lists, tags, calendar, dashboard
├── lib/            api/ (client, refresh), auth/, theme/, router, query-client
└── test/           setup, finto backend, render dell'app
```

Ogni feature tiene insieme le sue chiamate (`api.ts`), le sue query
(`queries.ts`), la logica pura (`due-grouping.ts`, `weekly-completions.ts`,
`calendar-grouping.ts`) e le sue pagine.

## Differenze volute rispetto al client Flutter

- **Barra laterale unica** al posto di barra inferiore + drawer: sul desktop
  c'è spazio, nasconderla sarebbe un peggioramento.
- **La lista selezionata sta nell'URL** (`/tasks?list=<id>`): link
  condivisibile, pulsante Indietro coerente.
- **Eliminazione su hover con conferma** al posto dello swipe, che con un
  mouse non esiste.
- **Titolo della scheda, favicon, scorciatoia `/`**: cose che sul web esistono.
- **Rinomina dei tag**, che nel client Flutter non è ancora esposta.
- **Colori dei grafici diversi da quelli delle pillole**: gli accenti di
  priorità non superano la validazione per l'uso in un grafico (vedi
  `journal/C57`).
