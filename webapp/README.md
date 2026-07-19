# Webapp (React + TypeScript)

Client **web** dello Smart TODO, fratello del client Flutter in [`../frontend`](../frontend)
(che resta il client mobile). Stesso backend, stesso feeling, UI pensata per il desktop.

## Stack

Vite 8 · React 19 · TypeScript strict · Vitest + Testing Library · oxlint · Prettier.
Nei commit successivi: Tailwind + shadcn/ui, React Router, TanStack Query, zustand.

## Comandi

```bash
npm install
npm run dev          # dev server (http://localhost:5173)
npm run typecheck    # tsc -b
npm run lint         # oxlint
npm test             # vitest run
npm run build        # tsc -b && vite build
npm run preview      # serve la build di produzione
npm run format       # prettier --write .
```

Il gate prima di ogni commit è `npm run lint && npm run typecheck && npm test && npm run build`.

## Configurazione

`VITE_API_BASE_URL` (default `http://localhost:8081`, vedi `.env.development`) indica
l'host del backend; il client API vi appende `/api/v1`. È l'equivalente web del
`--dart-define=API_BASE_URL` usato dal client Flutter.

Il backend deve essere in esecuzione (`docker compose up -d` + `./gradlew bootRun`
dalla root del monorepo): accetta CORS da qualunque `http://localhost:*`.
