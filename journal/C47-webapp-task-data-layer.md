# C47 — Data layer dei task: filtro, cache e mutazioni ottimistiche

## Cosa è stato fatto

- **`webapp/src/features/tasks/filters.ts`**: il tipo `TaskFilter`, il filtro
  di default, `isDefaultFilter()`, i combinatori (`toggleFilterValue`,
  `withSearch`, `withSort`, `clearFilterField`) e `toQueryParams()`.
- **`webapp/src/features/tasks/api.ts`**: le cinque chiamate REST più
  `toUpdateRequest()`, che ricostruisce il corpo completo per la PUT.
- **`webapp/src/features/tasks/queries.ts`**: `taskKeys`, `useTasks`,
  `useTask`, `useCreateTask`, `useUpdateTask`, `useDeleteTask`, con
  aggiornamento ottimistico e ripristino in caso di errore.
- Test: 6 sul filtro, 6 su query e mutazioni.

## Perché

**Il filtro è un valore, non uno stato sparso.** Tenerlo come un unico oggetto
immutabile con combinatori puri (`toggleFilterValue(filter, 'status', 'TODO')`)
rende ogni transizione testabile senza montare nulla, e permette di usare il
filtro **come parte della chiave di cache**. È la stessa scelta di
`TaskFilter` in Flutter (C26), dove la lista si ricarica perché il notifier
osserva il filtro; qui il meccanismo è lo stesso, espresso in chiavi.

**Perché una sola pagina da 50.** Il backend pagina, il client Flutter no:
chiede `page: 0, size: 50` e si ferma lì, con un commento onesto ("la
paginazione vera è una funzionalità a sé"). La webapp fa lo stesso, per
parità: introdurre lo scroll infinito solo di qua creerebbe due prodotti
diversi, e la paginazione va progettata insieme al raggruppamento per
scadenza — che ha bisogno di vedere tutti i task per formare le sezioni.

**Perché `toUpdateRequest`.** `PUT /tasks/:id` **sostituisce** il task: se il
corpo omette `description`, la descrizione viene cancellata. Spuntare una
casella significa quindi rimandare l'intero task con il solo `status`
modificato. Metterlo in una funzione dedicata evita che qualcuno, un domani,
mandi un corpo parziale e si porti via i dati senza accorgersene.

## Come funziona

**Le chiavi di cache sono gerarchiche.** Tutto ciò che riguarda i task vive
sotto il prefisso `['tasks']`: la lista filtrata è `['tasks', 'list', filter]`,
il dettaglio `['tasks', 'detail', id]`, la fetch del calendario `['tasks',
'calendar']`. TanStack Query invalida **per prefisso**, quindi una sola
`invalidateQueries({ queryKey: ['tasks'] })` dopo ogni mutazione tocca anche
il calendario.

È la soluzione strutturale al bug di C38, dove il calendario Flutter restava
indietro perché nessuno lo invalidava e la correzione fu aggiungere una
chiamata esplicita in ogni mutazione. Qui la gerarchia delle chiavi fa sì che
il calendario sia coperto **per costruzione**: chi aggiungerà una nuova query
sui task sotto lo stesso prefisso la otterrà aggiornata senza doverci pensare.
Gli analytics, che sono dati derivati dai task, si invalidano insieme.

**L'aggiornamento ottimistico in tre tempi**, per `onMutate` / `onError` /
`onSettled`:

1. `cancelQueries` ferma le fetch in volo — altrimenti una risposta partita
   prima potrebbe atterrare dopo e sovrascrivere il nostro aggiornamento;
2. si fotografa lo stato attuale (`getQueriesData`) e si applica subito la
   modifica in cache: la spunta risponde all'istante;
3. se il server rifiuta, `onError` rimette la fotografia; in ogni caso
   `onSettled` invalida, così l'ultima parola resta al server.

`setQueriesData` (al plurale) aggiorna **tutte** le query che corrispondono al
prefisso: le liste con filtri diversi eventualmente in cache e quella del
calendario, tutte insieme.

**`placeholderData: (previous) => previous`** su `useTasks`: cambiando filtro
la chiave cambia, quindi tecnicamente è una query nuova e senza dati. Con il
placeholder la lista precedente resta a schermo mentre arriva la nuova, invece
di far lampeggiare uno scheletro a ogni carattere digitato nella ricerca.

## Il ciclo TDD

1. **Rosso** — `filters.test.ts`: filtro di default, riconoscimento del
   non-default (anche per il solo ordinamento), traduzione in query con le
   dimensioni spente omesse, toggle a selezione singola su stato, priorità e
   tag, ricerca di soli spazi equivalente a nessuna ricerca.
2. **Verde** — `filters.ts`.
3. **Rosso** — `queries.test.tsx`: lettura dalla busta paginata; **la spunta
   appare prima della risposta** (la promessa del server viene trattenuta a
   mano e si verifica che la cache sia già aggiornata); ripristino su errore
   per update e delete; invalidazione di `['tasks']` e `['analytics']`.
4. **Verde** — `api.ts` e `queries.ts`.

Il test dell'ottimismo è quello che vale la pena leggere: trattenendo la
risposta si dimostra che l'interfaccia non sta aspettando la rete. Il suo
gemello — il ripristino dopo il 404 — dimostra che l'ottimismo non è
sconsideratezza.

## Concetti chiave

- **Il filtro come valore**: puro, testabile, e utilizzabile come chiave.
- **Chiavi gerarchiche**: rendono l'invalidazione una proprietà della
  struttura, non una lista di chiamate da ricordare.
- **PUT sostituisce**: un corpo parziale su una PUT è una cancellazione
  travestita.
- **Ottimismo con rete di sicurezza**: fotografia prima, ripristino se serve,
  verifica dal server sempre.
- **Cancellare le fetch in volo** prima di scrivere in cache, o una risposta
  vecchia sovrascriverà quella nuova.

## Per approfondire

- [TanStack Query — aggiornamenti ottimistici](https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates)
- [TanStack Query — chiavi e invalidazione](https://tanstack.com/query/latest/docs/framework/react/guides/query-invalidation)
- C26 (`C26-frontend-filter-bar.md`) e C38 (`C38-calendar-invalidation.md`)
