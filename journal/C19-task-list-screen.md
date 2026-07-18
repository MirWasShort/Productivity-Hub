# C19 — La lista task: AsyncNotifier e stati della UI

## Cosa è stato fatto

- **`TaskListNotifier`** (`AsyncNotifier<List<Task>>`): `build()` carica la
  lista dal repository; `refresh()`; `createTask` (aggiunge in testa);
  `updateTask` (sostituisce in place); `deleteTask` **optimistic-lite**:
  rimuove subito localmente, chiama l'API, e se il server dissente ricarica
  la lista per ristabilire la verità.
- **`TaskListScreen`** al posto del placeholder di C17: `AsyncValue.when`
  per i tre stati (spinner / errore con Riprova / dati), empty state,
  `RefreshIndicator` (pull-to-refresh), `Dismissible` per lo swipe-delete,
  checkbox che porta il task a DONE (con strikethrough), chip colorata per
  la priorità, logout in appbar.
- **Quick-add**: il FAB apre un bottom sheet con un solo campo titolo —
  creazione rapida senza lasciare la lista (il form completo arriva in C20).
- 10 test scritti prima: 6 sul notifier (load, errore, create, delete +
  rollback su fallimento, update) e 4 widget test (render, empty, errore
  con retry, quick-add che arriva al repository col titolo digitato).

## Perché

**Perché `AsyncNotifier` invece del pattern manuale
loading/data/error?** Lo stato di C17 (`AuthState` sealed a mano) andava
bene per una macchina a stati custom. Una *lista caricata da rete* è
invece il caso archetipo di `AsyncValue`: Riverpod fornisce gratis i tre
stati, `AsyncValue.guard` per catturare gli errori, e `when` obbliga la
UI a gestirli tutti — un empty state dimenticato si vede a colpo
d'occhio, uno stato di errore dimenticato *non compila*.

**Perché la delete è ottimistica e le altre no?** Lo swipe-delete con
attesa del server congelerebbe l'animazione del `Dismissible` (che ha
già rimosso visivamente la riga!). Rimuovere subito e ricaricare in caso
di errore dà UX fluida e coerenza garantita. Create e update invece
aggiornano lo stato *dopo* la conferma del server: sono operazioni con
feedback proprio (lo sheet si chiude, la checkbox cambia) e l'optimism
completo — con revert puntuale — è complessità tagliata dal piano.

**Perché il quick-add invece di navigare subito al form completo?** Il
gesto più frequente in una to-do app è "butta dentro un titolo". Un
bottom sheet con un campo costa 60 righe e resta utile anche dopo C20:
quick-add per la velocità, form completo per i dettagli. (E ha permesso
a questo commit di essere *interamente* usabile senza dipendere dalle
schermate future.)

**La lezione del test fallito (tre volte).** Il quick-add test è passato
solo al terzo giro, con tre cause diverse e istruttive:
1. lo stub mocktail non includeva `priority` → argomenti diversi = mock
   muto = `Null is not a Future` (i mock matchano l'*intera* firma);
2. il `TextEditingController` era disposed nel `whenComplete` dello sheet
   mentre l'animazione di chiusura lo stava ancora usando → estratto
   `_QuickAddSheet` come `StatefulWidget` che possiede il suo controller
   (la regola: chi crea il controller ne gestisce il ciclo di vita, e il
   ciclo di vita giusto è quello del widget);
3. la `verify` finale aveva la firma vecchia — stub e verify vanno
   aggiornati *insieme*.

## Come funziona

- `AsyncValue.when(loading:, error:, data:)` è pattern matching sui tre
  stati: la schermata è una funzione totale dello stato.
- `Dismissible(key: ValueKey(task.id))`: la key stabile è ciò che
  permette a Flutter di capire *quale* riga è stata rimossa.
- `RefreshIndicator` + `AlwaysScrollableScrollPhysics`: il pull-to-refresh
  funziona anche quando la lista non riempie lo schermo.
- Il notifier aggiorna lo stato per **sostituzione immutabile** (spread e
  collection-for producono liste nuove): Riverpod rileva il cambiamento
  per identità, non serve nessun `notifyListeners`.

## Il ciclo TDD in questo commit

1. **Rosso** — 10 test su notifier e schermata inesistenti; più un rosso
   *inatteso*: il test sull'errore di `build` era scritto su `.future` e
   andava in timeout — riscritto osservando lo stato (`hasError`), che è
   ciò che la UI consuma davvero.
2. **Verde** — notifier + schermata + le tre iterazioni del quick-add.
3. **Refactor** — `_TaskTile` e `_QuickAddSheet` estratti come widget
   privati: la schermata resta leggibile come un indice.

## Concetti chiave

- **AsyncValue**: loading/error/data come tipo, non come convenzione.
- **Optimistic update con rollback**: la UI mente per gentilezza, il
  server resta la verità.
- **Ownership dei controller**: chi crea un `TextEditingController` è un
  widget con un `dispose`.
- **I mock matchano firme intere**: stub e verify evolvono col codice.

## Per approfondire

- [Riverpod — AsyncNotifier](https://riverpod.dev/docs/providers/notifier_provider)
- [Flutter — Dismissible](https://api.flutter.dev/flutter/widgets/Dismissible-class.html) e [RefreshIndicator](https://api.flutter.dev/flutter/material/RefreshIndicator-class.html)
- [Optimistic UI patterns](https://uxdesign.cc/optimistic-1000-34d9eefe4c05)
- ROADMAP: Fase 5, Settimana 24 (Task CRUD — Screens: lista con loading/empty/error, swipe delete) e Settimana 25 (optimistic updates)
