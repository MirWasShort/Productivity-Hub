# C26 — Filter bar: chip, ricerca con debounce e ordinamento

## Cosa è stato fatto

- **`TaskFilter`** (domain): classe immutabile con i criteri attivi —
  status, priority, search, listId (pronto per le liste), sortBy +
  direction — uguaglianza strutturale, `isDefault`, e `copyWith` con
  flag `clear*` espliciti.
- **`TaskFilterNotifier`**: toggle single-select per status/priority
  (ri-tap = deseleziona), `setSearch` (stringa vuota = clear),
  `setSort`, `setListId`, `clear`.
- **`TaskListNotifier.build()` ora fa `ref.watch(taskFilterProvider)`**:
  al cambio di filtro Riverpod ri-esegue build e la lista si ricarica da
  sola — zero cablaggio manuale. La UI usa `skipLoadingOnReload: true`:
  durante il reload restano visibili i dati precedenti, niente flash di
  spinner a ogni tap.
- **`TaskFilterBar`**: campo di ricerca con **debounce a 300ms** (un
  `Timer` a mano, 10 righe), chip di stato/priorità, menu di ordinamento
  (Più recenti / Scadenza più vicina / Priorità più alta / Titolo A-Z).
- Datasource: il filtro diventa query param wire (`IN_PROGRESS`,
  `DUE_DATE`...), i param inattivi sono **omessi**, il sort è sempre
  esplicito. Empty state consapevole: "Nessun risultato, prova ad
  allentare i filtri" quando un filtro è attivo.
- 12 test scritti prima: semantica del filtro (set/clear/uguaglianza),
  serializzazione dei param (attivi e omessi), debounce (incluso il
  reset della finestra se ridigiti), toggle chip, menu sort.

## Perché

**Perché il debounce?** Senza, ogni carattere digitato è una richiesta
HTTP: "spesa" = 5 chiamate, 4 delle quali buttate. Il timer riparte a
ogni tasto e scatta solo dopo 300ms di pausa — una chiamata per
*intenzione*, non per keystroke. Il test lo verifica controllando che a
100ms il filtro non sia ancora cambiato e che ridigitare azzeri la
finestra. Un pacchetto per questo sarebbe overkill: è un `Timer`.

**Perché `ref.watch` dentro `build()` del notifier?** È l'idioma
Riverpod per stati derivati: la lista *dipende* dal filtro, quindi lo
osserva. Cambio filtro → invalidazione → nuovo build → nuova fetch. Le
alternative (chiamare manualmente `reload()` da ogni chip) sparpagliano
il cablaggio in N punti; qui la dipendenza è dichiarata in uno.

**Perché i `clear*` flag nel copyWith?** Il `copyWith` classico non
distingue "non passato" da "impostato a null" (entrambi arrivano come
null). I flag espliciti (`clearStatus: true`) rendono l'intenzione
un'API: nel notifier il toggle è leggibile, nei test pure. (Freezed
risolve con sentinelle interne; per una classe scritta a mano i flag
sono la via semplice.)

**Perché i param inattivi si omettono e il sort no?** Un param assente
= "nessun filtro" per contratto; ometterli tiene le URL pulite e i log
leggibili. Il sort invece viaggia sempre esplicito: se un domani il
default del server cambiasse, il client non cambierebbe comportamento a
sorpresa — client e server restano indipendenti sul default.

## Come funziona

- Il flusso completo: chip tap → `toggleStatus` → nuovo `TaskFilter` →
  Riverpod invalida `taskListProvider` → `build()` rilegge il filtro →
  `repository.list(filter:)` → datasource → query param → la
  Specification di C25 filtra in SQL. Il client non filtra mai in
  memoria: un solo cervello per i filtri, il database.
- Curiosità mocktail emersa: gli stub esistenti `when(() =>
  repository.list())` hanno continuato a matchare perché Dart applica i
  default dei parametri *al call site* — dentro il `when` la chiamata
  diventa `list(filter: TaskFilter())`, identica (per uguaglianza
  strutturale) a quella runtime. L'uguaglianza strutturale del filtro
  non era un vezzo: è ciò che tiene in piedi stub e confronti.

## Il ciclo TDD in questo commit

1. **Rosso** — 12 test su classi inesistenti.
2. **Verde** — filtro, notifier, bar, datasource, integrazione lista.
3. **Refactor** — l'empty state ha guadagnato la variante "filtri
   attivi" appena la struttura l'ha resa naturale.

## Concetti chiave

- **Debounce**: una richiesta per intenzione, non per keystroke.
- **Stato derivato con `ref.watch` in build**: le dipendenze si
  dichiarano, non si cablano.
- **skipLoadingOnReload**: il reload non deve sembrare un primo load.
- **Il filtro vive nel server**: il client esprime criteri, il DB li
  applica.

## Per approfondire

- [Riverpod — combining providers](https://riverpod.dev/docs/concepts/combining_providers)
- [AsyncValue.when — skipLoadingOnReload](https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValueX/when.html)
- [Material 3 — Chips](https://m3.material.io/components/chips/overview)
- ROADMAP: Fase 6, Settimana 29 (Frontend — Filtering & Search), kata 6.4 (Debounce Kata)
