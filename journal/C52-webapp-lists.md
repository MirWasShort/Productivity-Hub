# C52 — Liste: la selezione vive nell'URL

## Cosa è stato fatto

- **`webapp/src/features/lists/{api,queries}.ts`**: CRUD delle liste; la
  cancellazione invalida anche i task, perché il backend li scollega.
- **`webapp/src/features/lists/list-editor-dialog.tsx`**: dialogo con nome e
  gli otto colori preimpostati.
- **`webapp/src/components/layout/sidebar-lists.tsx`**: "Tutte le attività",
  le liste con il pallino colorato, eliminazione con conferma, "Nuova lista".
- **`webapp/src/features/tasks/task-list-page.tsx`**: la lista selezionata
  arriva da `?list=<id>`; il titolo della pagina diventa il nome della lista e
  i task aggiunti mentre è attiva le appartengono.
- **`webapp/src/features/tasks/task-edit-page.tsx`**: selettore della lista.
- **`webapp/src/test/api-mock.ts`**: finto backend condiviso dai test.
- Test: 7 sulle liste.

## Perché

**La selezione della lista sta nell'URL, non in uno stato condiviso.** È la
decisione di questo commit. La barra laterale e la lista dei task sono due
componenti lontani nell'albero: nel client Flutter li collega un provider
Riverpod globale (`taskFilterProvider`), e sul web si potrebbe fare lo stesso
con uno store.

Ma sul web esiste già un posto naturale per dire "cosa sto guardando":
l'indirizzo. Mettendo la lista in `?list=<id>` si ottengono gratis quattro
cose che uno store non dà:

- il link è **condivisibile** e si può mettere fra i preferiti;
- il pulsante **Indietro** del browser fa quello che l'utente si aspetta;
- ricaricare la pagina non perde il contesto;
- i due componenti non si conoscono: parlano attraverso la navigazione.

È una di quelle differenze in cui la webapp non imita il mobile ma usa ciò che
la piattaforma già offre.

**Perché la cancellazione invalida anche i task.** Il vincolo di chiave esterna
è `ON DELETE SET NULL` (C30): eliminando una lista, i suoi task restano e
diventano senza lista. Se invalidassimo solo `['lists']`, le card
continuerebbero a mostrare l'appartenenza a una lista che non esiste più.

**Otto colori, non un selettore libero.** Stessa scelta del client Flutter:
otto tinte distinguibili a colpo d'occhio valgono più di sedici milioni tutte
uguali, e garantiscono contrasto sufficiente in entrambi i temi.

## Come funziona

**Filtro composto.** La pagina tiene il proprio `filter` (ricerca, stato,
ordinamento) e lo unisce alla lista letta dall'URL:

```ts
const activeFilter = useMemo(() => ({ ...filter, listId: selectedListId }), [...])
```

Le due sorgenti restano separate — chi le cambia è diverso — ma a valle esiste
un solo filtro, che è anche la chiave di cache: navigare fra due liste produce
due query distinte, entrambe conservate.

**Il finto backend dei test.** Da questo commit la barra laterale carica le
liste su **ogni** pagina, e i mock che rispondevano sempre la stessa cosa
hanno iniziato a restituire una pagina di task dove il codice si aspettava un
array di liste. Venti test sono diventati rossi tutti insieme.

La correzione è `createApiMock`, che instrada per percorso e ha ripieghi
sensati (elenco vuoto per liste e tag, pagina vuota per i task): ogni test
dichiara solo ciò che gli interessa. Il fatto che venti test siano caduti
insieme è un buon segno — significa che montano l'app vera e non una finzione
comoda.

## Il ciclo TDD

Sette test: le liste compaiono nella barra; sceglierne una filtra i task
(`listId` nella query) e cambia il titolo della pagina; **aprire direttamente
`/tasks?list=list-2` mostra già il filtro attivo** — la prova che lo stato è
davvero nell'URL e non in memoria; un task aggiunto con una lista selezionata
le appartiene; la creazione manda nome e colore scelto; l'eliminazione chiede
conferma spiegando che i task restano; l'editor permette di scegliere la lista.

## Concetti chiave

- **L'URL è uno stato condiviso che il browser gestisce per te**: prima di
  introdurre uno store globale, chiedersi se la cosa da condividere non sia
  semplicemente "dove sono".
- **Stato composto da fonti diverse**: unire in lettura è più semplice che
  sincronizzare in scrittura.
- **Invalidare ciò che il server cambia di riflesso**: `ON DELETE SET NULL` è
  una modifica ai task, anche se la richiesta parlava di liste.
- **Un mock realistico è un mock instradato**: quando l'app fa più chiamate
  diverse, un mock a risposta unica racconta una bugia.

## Per approfondire

- [React Router — `useSearchParams`](https://reactrouter.com/api/hooks/useSearchParams)
- [TanStack Query — chiavi che includono i parametri](https://tanstack.com/query/latest/docs/framework/react/guides/query-keys)
- C31 (`C31-frontend-lists-drawer.md`) — il drawer delle liste in Flutter
- C30 (`C30-task-lists-tags-integration.md`) — `ON DELETE SET NULL` lato backend
