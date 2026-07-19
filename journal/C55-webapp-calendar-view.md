# C55 — Vista calendario: una griglia scritta a mano

## Cosa è stato fatto

- **`webapp/src/features/calendar/calendar-view.ts`**: `visibleDays()`, le tre
  granularità (mese / 2 settimane / settimana) e le loro etichette.
- **`webapp/src/features/calendar/calendar-grid.tsx`**: la griglia 7 colonne,
  lunedì-first, con pallino sui giorni che hanno task.
- **`webapp/src/features/calendar/calendar-page.tsx`**: intestazione con
  navigazione avanti/indietro e "Oggi", selettore di granularità, lista dei
  task del giorno scelto (con la stessa `TaskCard` della lista) e pulsante che
  apre l'editor con la data già impostata.
- Test: 7 sulla pagina, 2 sulla funzione dei giorni visibili.

## Perché

**Griglia a mano invece di una libreria.** Il client Flutter usa
`table_calendar`; su web l'equivalente sarebbe `react-big-calendar` o simili,
progettati per agende con eventi a fasce orarie, trascinamento e ricorrenze.
Qui serve molto meno: sette colonne, un pallino sui giorni occupati, tre
granularità. `eachDayOfInterval` di date-fns fa il calcolo, CSS Grid
l'impaginazione — poche decine di righe contro una dipendenza da adattare,
con in più il controllo completo su accessibilità e stile.

**Il calendario resta indipendente dai filtri.** Vedi C54: una panoramica
mensile con dei buchi non è una panoramica.

## Come funziona

**Sempre settimane intere.** `visibleDays` non restituisce "i giorni del mese"
ma i giorni **dal lunedì della settimana che contiene il primo** alla domenica
di quella che contiene l'ultimo. Così la griglia ha sempre righe complete, le
celle non cambiano dimensione fra un mese e l'altro, e i giorni degli altri
mesi ci sono ma smorzati (`text-muted-foreground/50`). È il motivo per cui il
test verifica `days.length % 7 === 0` e che il primo giorno sia un lunedì.

**Ogni giorno è un `<button>`, non un `<div>` cliccabile.** Ne segue gratis la
navigazione da tastiera, il ruolo corretto per gli screen reader e
`aria-pressed` per dire quale giorno è selezionato. L'etichetta accessibile
include il conteggio (`"15 luglio 2026, 3 task"`): il pallino è
un'informazione visiva, e da sola non arriverebbe a chi non lo vede.

**Il pallino invece del numero.** In una cella quadrata di una griglia mensile
un contatore starebbe stretto e sarebbe illeggibile su schermi piccoli; la
lista sotto la griglia dice comunque quanti e quali sono.

**La navigazione si adatta alla granularità**: in vista mensile le frecce si
spostano di un mese, in vista settimanale di sette giorni, in due settimane di
quattordici. Nelle viste brevi cambia anche il giorno selezionato, che
altrimenti resterebbe fuori dallo schermo.

**Il giorno selezionato viaggia nell'URL verso l'editor**
(`/tasks/new?date=…`), lo stesso meccanismo del client Flutter e la stessa
idea di C52: quando un'informazione deve passare da una pagina all'altra,
l'indirizzo è il canale più semplice che esista.

Una nota sul nome: `format` è insieme un parametro di questo componente (la
granularità) e una funzione di date-fns. L'import è rinominato in `formatDate`,
perché una variabile che oscura una funzione importata è il tipo di bug che
compila e non funziona.

## Il ciclo TDD

Nove test: all'apertura si vedono i task di oggi e non quelli di domani;
cliccando un altro giorno la lista sotto cambia; l'etichetta accessibile
contiene il numero di task; un giorno vuoto lo dice; **la richiesta del
calendario non porta filtri** ed è ordinata per scadenza; il pulsante
"Aggiungi" apre l'editor con la data già scelta; passando a "Settimana" restano
sette celle. Più due test puri su `visibleDays` (settimane intere, 14 e 7
giorni).

## Concetti chiave

- **Una libreria si valuta su ciò che serve davvero**: qui il 90% delle
  funzioni sarebbe rimasto inutilizzato.
- **Elementi interattivi nativi**: un `<button>` porta con sé tastiera, ruolo
  e stato.
- **Le informazioni visive vanno raddoppiate nel testo accessibile**: un
  pallino non ha voce.
- **Attenzione agli identificatori che oscurano gli import**.

## Per approfondire

- [date-fns — `eachDayOfInterval`, `startOfWeek`](https://date-fns.org/docs/eachDayOfInterval)
- [MDN — CSS Grid](https://developer.mozilla.org/docs/Web/CSS/CSS_grid_layout)
- C33 (`C33-calendar-view.md`) e C37 (`C37-calendar-format-button.md`)
