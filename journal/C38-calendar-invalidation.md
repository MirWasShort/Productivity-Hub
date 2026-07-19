# C38 — Il calendario si aggiorna da solo dopo ogni mutazione

## Cosa è stato fatto

- **`task_list_notifier.dart`**: dopo ogni mutazione andata a buon fine
  (`createTask`, `updateTask`, `deleteTask`) il notifier invalida
  `calendarTasksProvider` tramite un helper `_invalidateCalendar()`.
- **`task_list_notifier_test.dart`**: due test nuovi contano le fetch del
  repository e verificano che, dopo ogni mutazione, una rilettura del
  provider calendario rifetchi dal server.

## Perché

Creando o completando un task, la vista calendario non lo mostrava
finché non si ricaricava la pagina. La causa: `calendarTasksProvider` è
una fetch **indipendente e senza filtri** (il calendario mostra tutto,
qualunque filtro sia attivo nel tab task), quindi non osserva
`taskListProvider` e nessuna mutazione lo toccava — veniva invalidato
solo al logout. Due fonti di verità per gli stessi dati server, mai
sincronizzate.

Alternative considerate:

- **Far osservare `taskListProvider` al calendario** — scartata: la
  lista è filtrata, il calendario no; e ogni battuta di ricerca avrebbe
  rifetchato anche il calendario.
- **`autoDispose` + refetch al rientro nel tab** — scartata: i tab
  vivono in uno `StatefulShellRoute.indexedStack`, il widget calendario
  resta montato quando si cambia tab, quindi il provider non viene mai
  rilasciato.
- **Cache unica dei task da cui lista e calendario derivano** — è la
  soluzione strutturale (elimina la divergenza per costruzione), ma è
  un refactor più ampio, pianificato con gli altri interventi Riverpod
  della code review (`doc/CODE_REVIEW.md`, F-03/F-08/F-10/F-11).

Scelta: l'invalidazione mirata nel punto unico da cui passano **tutte**
le mutazioni. Edit screen, quick-add, checkbox sulla card e
swipe-delete chiamano tutti `taskListProvider.notifier`, quindi tre
righe coprono ogni percorso.

## Come funziona

`ref.invalidate(provider)` marca il provider come sporco: se qualcuno lo
sta osservando viene ricostruito subito, altrimenti alla prossima
lettura. Il calendario, quando è visibile, fa `ref.watch` e quindi si
aggiorna da solo; quando non è montato la fetch riparte al primo accesso
successivo — nessun lavoro sprecato per una vista che non si sta
guardando.

In `deleteTask` l'invalidazione sta nel ramo di successo: se la delete
fallisce il server non è cambiato, e il ramo di errore già ricarica la
lista per ripristinare la verità.

## Il ciclo TDD

1. **Rosso** — i test leggono lista e calendario (2 fetch), mutano, e
   rileggono il calendario aspettandosi una terza fetch:
   `verify(() => repository.list()).called(3)` falliva perché il
   calendario serviva la cache.
2. **Verde** — l'helper `_invalidateCalendar()` chiamato dalle tre
   mutazioni.

## Concetti chiave

- **Ogni cache in più è un obbligo di sincronizzazione in più**: il bug
  non era nel codice del calendario, ma nell'esistenza di una seconda
  copia dei dati senza un contratto su chi la aggiorna.
- **Invalidare nel punto di passaggio obbligato**: mettere
  l'invalidazione nel notifier (non nelle schermate) la rende
  impossibile da dimenticare per i chiamanti presenti e futuri.
- **`invalidate` è pigro**: non rifetcha nulla finché nessuno guarda —
  la differenza tra "aggiorna ora" e "segna come vecchio".

## Per approfondire

- [Riverpod — ref.invalidate](https://riverpod.dev/docs/concepts/reading#using-refinvalidate)
- `doc/CODE_REVIEW.md` — finding F-03 (questa fix) e F-08/F-10/F-11
  (la soluzione strutturale a cache unica)
