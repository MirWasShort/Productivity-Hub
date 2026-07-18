# C33 — Vista calendario con granularità mese/settimana

## Cosa è stato fatto

- Dipendenza **`table_calendar 3.2.0`** (smoke-test di compatibilità con
  Flutter 3.44 superato: `pub get` + render + analyze puliti).
- **`calendar_grouping.dart`** (domain, puro): `groupTasksByDay` (bucket
  per giorno locale, task senza scadenza esclusi) e `tasksOn(day)`.
- **`calendar_notifier.dart`**: `CalendarState` (focusedDay, selectedDay,
  format) + `CalendarNotifier`; `calendarTasksProvider` (FutureProvider
  che carica *tutti* i task, indipendente dal filtro della tab lista).
- **`CalendarScreen`**: `TableCalendar` con toggle formato
  **Mese / 2 settimane / Settimana** (= la granularità richiesta),
  marker sui giorni con task (`eventLoader`), lista dei task del giorno
  selezionato sotto, tap su task → dettaglio, **FAB → `/tasks/new?date=`**
  che precompila la scadenza.
- 5 test: 3 sulla funzione di grouping pura, 2 widget (task del giorno
  mostrati, empty state).

## Perché

**Perché il calendario carica *tutti* i task e non solo il mese?** Il
piano prevedeva un fetch per range mensile, ma per un'app personale
(decine di task, non migliaia) caricare tutto e raggruppare in memoria è
più semplice e altrettanto veloce — e rende il cambio mese istantaneo
(niente rifetch a ogni swipe). Il grouping è una funzione pura testabile;
se un domani i volumi crescessero, si aggiunge il range al fetch senza
toccare né la funzione né la UI. Ottimizzare per il caso reale, non per
quello ipotetico.

**Perché il calendario è indipendente dal filtro della tab lista?** Sono
due contesti mentali diversi: la tab Task è "cosa devo fare, filtrato";
il Calendario è "cosa c'è quando". Applicare i filtri della lista al
calendario confonderebbe (perché il 20 è vuoto? ah, c'è un filtro
altrove). Il calendario mostra sempre tutto: prevedibile.

**Perché `table_calendar` e non una griglia a mano?** Il piano prevedeva
il fallback custom se il pacchetto fosse incompatibile con Flutter 3.44
(ultimo publish ~18 mesi fa). Lo smoke test è passato, quindi si usa:
gestisce formati, swipe tra mesi, marker degli eventi e localizzazione —
150 righe di griglia a mano risparmiate. La funzione di grouping e il
notifier erano scritti *widget-agnostic* apposta, così il fallback
sarebbe costato solo la schermata.

**Il prefill via query param.** Il FAB del calendario naviga a
`/tasks/new?date=2026-07-20`: la rotta legge il param, `TaskEditScreen`
precompila la scadenza. È il pattern GoRouter per passare dati leggeri
tra schermate senza stato condiviso — la data vive nell'URL, non in un
provider.

**La lezione del layout.** La prima versione usava `Column` +
`Expanded`: nel test della shell (viewport 800×600) il TableCalendar
mese sforava di 41px → errore di overflow. Trasformato tutto in un unico
`ListView` (calendario + task del giorno che scrollano insieme): su
qualunque schermo scorre invece di sforare. Regola: quando un contenuto
di altezza variabile deve stare in uno spazio incerto, scrollarlo è più
robusto che incastrarlo con `Expanded`.

## Come funziona

- `eventLoader(day)` restituisce i task di quel giorno dalla mappa
  pre-calcolata: `table_calendar` disegna i pallini-marker.
- `selectedDayPredicate` + `onDaySelected` collegano la selezione allo
  stato del notifier; `onFormatChanged`/`onPageChanged` sincronizzano
  formato e mese.
- Tutti i confini di giorno passano da `_localDay` (`toLocal()` +
  troncamento a mezzanotte): stesso principio di C27, "oggi" è il fuso
  dell'utente.

## Il ciclo TDD in questo commit

Rosso (grouping puro + schermata) → verde con `table_calendar` → refactor
del layout da Column/Expanded a ListView per eliminare l'overflow.

## Concetti chiave

- **Ottimizzare per il caso reale**: caricare tutto e raggruppare in
  memoria batte un fetch per-mese finché i volumi sono piccoli.
- **Contesti indipendenti**: il calendario ignora i filtri della lista.
- **Dati leggeri via URL**: la data pre-compilata è un query param.
- **Scrollare > incastrare**: contenuti alti in spazi incerti vanno resi
  scorrevoli.

## Per approfondire

- [table_calendar](https://pub.dev/packages/table_calendar)
- [GoRouter — query parameters](https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html)
- [Flutter — Slivers e scroll](https://docs.flutter.dev/ui/layout/scrolling)
- ROADMAP: la vista calendario è un'estensione UX (non nella Fase 6/8 originale) nata dall'obiettivo demo
