# C42 — Tipi dall'OpenAPI: il contratto del backend come codice

## Cosa è stato fatto

- **`webapp/src/api/schema.d.ts`**: 1655 righe generate da
  `openapi-typescript` a partire da `http://localhost:8081/v3/api-docs`.
  File committato, mai modificato a mano.
- **`webapp/package.json`**: script `generate:api` per rigenerarlo
  (`API_BASE_URL` sovrascrivibile).
- **`webapp/src/api/types.ts`**: i tipi di dominio che userà tutta la webapp
  (`Task`, `Tag`, `TodoList`, `User`, `AuthResponse`, `Page<T>`,
  `AnalyticsSummary`, `Completions`, `ApiErrorBody`), gli enum come array
  `as const` (`taskStatuses`, `taskPriorities`, `taskSortFields`,
  `sortDirections`) e i tipi delle richieste presi direttamente dallo schema.
  In fondo, le asserzioni che legano questi tipi allo schema generato.
- **`webapp/src/api/types.test.ts`**: quattro test sugli enum.

## Perché

Il backend pubblica già il proprio contratto con springdoc. Ritrascriverlo a
mano in TypeScript significherebbe mantenere due verità che divergeranno al
primo campo aggiunto — esattamente il problema che il journal C18 racconta per
il lato Flutter, dove il mapping wire↔dominio è scritto a mano.

Ma la generazione, da sola, non basta: **springdoc marca ogni campo di
risposta come opzionale**. In Java tutto è nullable finché non lo si annota, e
i DTO del progetto non hanno annotazioni di nullità sulle risposte. Il
risultato è `TaskResponse { id?: string; title?: string; status?: ... }`.
Usarlo direttamente significherebbe un `?? ''` o un `!` a ogni accesso, su
campi che il backend valorizza sempre: rumore che nasconde i pochi campi
davvero nullable (`description`, `dueDate`, `listId`, `color`).

Alternative valutate:

- **Usare lo schema generato così com'è** — scartata per il motivo sopra: la
  nullabilità diventa uniforme e quindi non informa più.
- **Un tipo utility che rende tutto obbligatorio** (`{[K in keyof T]-?: T[K]}`)
  — scartata, e peggiore: renderebbe obbligatori anche `description` e
  `dueDate`, cioè trasformerebbe in bugia proprio i campi che possono mancare.
- **Annotare i DTO Java** con `@Schema(requiredMode = REQUIRED)` — la
  soluzione strutturale, ma tocca ~15 record del backend per un beneficio che
  riguarda solo questo client. Annotata come possibile intervento futuro.
- **Client generato completo** (orval, openapi-fetch) — scartata: genera anche
  hook e fetcher, mentre il nostro client deve fare refresh trasparente dei
  token in modo molto specifico (C44). Ci teniamo i tipi, scriviamo noi il
  trasporto.

Scelta: tipi di dominio scritti a mano, **ancorati** allo schema generato da
asserzioni che il compilatore verifica.

## Come funziona

Le asserzioni in fondo a `types.ts` non producono codice: esistono solo per
far fallire `npm run typecheck` se il contratto si muove. Ne servono due tipi,
e il motivo è sottile.

```ts
type AssertAssignable<Schema, Domain extends Schema> = Domain
type AssertNever<T extends never> = T
```

`AssertAssignable` verifica che il nostro `Task` sia compatibile con
`TaskResponse`: se il backend cambia i valori di un enum (per esempio rimuove
`DONE`), il nostro tipo più stretto non è più assegnabile e il typecheck salta.

Da sola però non basta, ed è il punto interessante: siccome nello schema è
tutto opzionale, **un campo rinominato non verrebbe notato**. Se `displayName`
diventasse `fullName`, il nostro `User` avrebbe un campo in più (le proprietà
in eccesso sono ammesse nei controlli di assegnabilità fra tipi, a differenza
dei letterali) e uno in meno — ma quello mancante è opzionale, quindi nessun
errore. Il contratto sarebbe rotto e la compilazione felice.

Da qui il secondo controllo:

```ts
export type _UserKeys = AssertNever<Exclude<keyof User, keyof Schemas['UserDto']>>
```

`Exclude<keyof User, keyof UserDto>` è l'insieme dei campi che usiamo e che lo
schema non ha. Se è vuoto, il tipo è `never` e `AssertNever` lo accetta;
altrimenti il compilatore segnala **il nome esatto del campo fantasma**.
Verificato rinominando `displayName` di proposito:

```
src/api/types.ts(149,37): error TS2344:
  Type '"displayNameRinominato"' does not satisfy the constraint 'never'.
```

Nota implementativa: il vincolo `T extends never` va applicato al **punto di
uso**, non dentro un alias generico intermedio. TypeScript valuta il vincolo di
un alias generico sulla forma non risolta, e `Exclude<keyof Domain, keyof
Schema>` con parametri ancora astratti non è dimostrabilmente `never`: l'alias
fallirebbe sempre, anche quando tutto è a posto.

**Perché `npx` invece di una devDependency**: `openapi-typescript@7` dichiara
un peer `typescript@^5.x` e il progetto è su TypeScript 6, quindi `npm install`
rifiuta di risolvere l'albero. È uno strumento di codegen che si esegue di
rado e il cui output è committato: eseguirlo con `npx` a versione fissata è
più onesto che forzare `--legacy-peer-deps` e portarsi dietro un peer
dichiaratamente incompatibile.

**Gli enum come array `as const`** danno due cose al prezzo di una: il tipo
unione (`(typeof taskStatuses)[number]`) e l'array iterabile per popolare
i menu a tendina, senza doverli tenere allineati a mano.

## Il ciclo TDD

1. **Rosso** — `types.test.ts` verifica il contenuto e l'ordine dei quattro
   array di enum, più un caso che li confronta con i tipi estratti dallo
   schema generato tramite `satisfies`.
2. **Verde** — `types.ts`.
3. **Verifica delle asserzioni** — rinominato `displayName` di proposito,
   controllato che il typecheck fallisca indicando il campo, ripristinato.

Quest'ultimo passaggio è la parte importante: un'asserzione di tipo che non si
è mai vista fallire è indistinguibile da un commento. La prima versione delle
asserzioni, infatti, *non* rilevava le rinomine — l'ho scoperto solo provando
a romperle.

## Concetti chiave

- **Generare il contratto, non fidarsene ciecamente**: i generatori riflettono
  ciò che il produttore dichiara, e Java dichiara "tutto nullable".
- **Asserzioni a livello di tipo**: costano zero a runtime e trasformano una
  rottura di contratto in un errore di compilazione.
- **Un test negativo per ogni guardia**: se non l'hai vista fallire, non sai
  se ti sta proteggendo.
- **Nullabilità informativa**: se tutto è opzionale, l'opzionalità non dice
  più niente.

## Per approfondire

- [openapi-typescript](https://openapi-ts.dev/introduction)
- [TypeScript — Conditional types e `Exclude`](https://www.typescriptlang.org/docs/handbook/2/conditional-types.html)
- [springdoc — nullabilità e `requiredMode`](https://springdoc.org/#how-can-i-set-a-property-as-required)
- C18 (`C18-task-data-layer.md`) — lo stesso mapping, scritto a mano in Dart
