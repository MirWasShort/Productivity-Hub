# C39 — Scaffold della webapp: Vite, React 19, TypeScript strict

## Cosa è stato fatto

- **`webapp/`**: nuovo pacchetto nel monorepo, accanto a `frontend/` (Flutter,
  client mobile) e `backend/`. Generato con `npm create vite@latest webapp --
  --template react-ts` (Vite 8, React 19, TypeScript 6).
- **`webapp/tsconfig.app.json`**: aggiunti `strict`, `noUncheckedIndexedAccess`,
  `noImplicitOverride` e l'alias di path `@/* → ./src/*`; il template non
  attiva `strict` di default.
- **`webapp/vite.config.ts`**: alias `@` risolto anche a runtime e blocco
  `test` di Vitest (ambiente jsdom, `globals: true`, setup file).
- **`webapp/src/test/setup.ts`**: matcher `jest-dom` e `cleanup()` di
  Testing Library dopo ogni test.
- **`webapp/src/App.tsx` + `App.test.tsx`**: placeholder minimo e primo test di
  smoke; rimossa tutta la landing page demo del template (asset, CSS, icone).
- **`webapp/package.json`**: script `dev`, `build`, `preview`, `lint`,
  `typecheck`, `test`, `test:watch`, `format`, `format:check`.
- **`webapp/.env.development`**: `VITE_API_BASE_URL=http://localhost:8081`.
- **`webapp/README.md`**: stack, comandi, configurazione.
- **`webapp/.prettierrc.json` / `.prettierignore`**: formattazione condivisa.

## Perché

Il client Flutter diventa l'app **mobile**; la webapp è un client **ad hoc**
per il desktop, dove c'è più spazio e prima o poi vorremo cose che sul telefono
non hanno senso (pannelli affiancati, scorciatoie da tastiera, azioni in blocco).
Flutter compila anche per il web, ma il risultato è un'app disegnata per il
touch renderizzata su canvas: si può fare di meglio scrivendo HTML vero.

Alternative valutate per lo stack:

- **Flutter web** — scartata: è il motivo per cui esiste questo pacchetto.
- **Next.js** — scartata: l'app è al 100% dietro login con token in JS, l'SSR
  non porta nulla e complica il deploy. Una SPA statica basta.
- **React Router in framework mode** — scartata per ora: loader/action e SSR
  sono peso non necessario; useremo la library mode (`createBrowserRouter`).

**Deviazione dal piano su un punto**: il piano prevedeva ESLint 9 flat config,
ma `create-vite@9` ora genera `oxlint` (scritto in Rust, gira in millisecondi,
zero configurazione, copre `rules-of-hooks`). Tenerlo evita di combattere con
lo scaffold per un beneficio marginale; se in futuro servissero regole
type-aware si aggiunge `typescript-eslint` accanto.

## Come funziona

**`tsc -b` (build mode)**: il progetto è diviso in due tsconfig referenziati da
`tsconfig.json` — `tsconfig.app.json` (il codice in `src`, ambiente DOM) e
`tsconfig.node.json` (solo `vite.config.ts`, ambiente Node). Servono ambienti
diversi: `vite.config.ts` importa `node:url`, il codice dell'app no. `npm run
build` fa `tsc -b && vite build`: prima il typecheck di entrambi, poi il bundle.

**L'alias `@`** va dichiarato **due volte**, e non è una svista: `paths` in
tsconfig serve a TypeScript per risolvere i tipi, `resolve.alias` in
`vite.config.ts` serve a Vite (e a Vitest, che riusa la stessa config) per
risolvere i moduli a runtime. Se ne dimentichi uno, compila ma non parte —
o viceversa.

Nota su TypeScript 6: `baseUrl` è deprecato e fa fallire il build. Dalla 5.4 i
pattern di `paths` sono relativi al file tsconfig, quindi `"@/*": ["./src/*"]`
funziona da solo.

**Vitest** riusa `vite.config.ts` (stessi alias, stessi plugin, stesse
trasformazioni): non c'è una seconda pipeline da tenere allineata, a differenza
di Jest che va configurato a parte. `environment: 'jsdom'` dà un DOM finto in
Node; `globals: true` rende `describe`/`it`/`expect` disponibili senza import
(come in `flutter test`); `setupFiles` gira prima di ogni file di test.

`cleanup()` in `afterEach` smonta i componenti montati: senza, i test successivi
troverebbero nel DOM anche gli elementi dei test precedenti e query come
`getByRole` fallirebbero per ambiguità.

## Il ciclo TDD

1. **Rosso** — `src/App.test.tsx` monta `App` e cerca l'heading "Smart TODO";
   falliva perché `App` era ancora la landing page demo di Vite.
2. **Verde** — `App` ridotto al placeholder con l'heading giusto.
3. **Gate** — `npm run lint && npm run typecheck && npm test && npm run build`
   tutti verdi.

È un test minuscolo e volutamente banale: serve a dimostrare che la catena
Vitest → jsdom → alias `@` → JSX → jest-dom è cablata bene. Da qui in poi ogni
commit può partire dal test.

## Concetti chiave

- **Monorepo multi-client**: un backend REST client-agnostic può servire N
  client; ogni client sceglie le sue idiomatiche invece di subire quelle di un
  altro.
- **Project references di TypeScript**: ambienti diversi (DOM vs Node) nello
  stesso pacchetto vogliono tsconfig diversi.
- **Un alias, due risolutori**: il type checker e il bundler risolvono i moduli
  in modo indipendente.
- **Config condivisa test/build**: Vitest sopra Vite elimina la classe di bug
  "passa in test, rompe in build".

## Per approfondire

- [Vite — Config](https://vite.dev/config/) e [Vitest — Config](https://vitest.dev/config/)
- [Testing Library — React](https://testing-library.com/docs/react-testing-library/intro/)
- [TypeScript — `paths` senza `baseUrl`](https://www.typescriptlang.org/tsconfig#paths)
- [oxlint](https://oxc.rs/docs/guide/usage/linter.html)
