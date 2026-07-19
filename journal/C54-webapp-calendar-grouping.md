# C54 — Raggruppamento del calendario: chiavi che sopravvivono ai fusi

## Cosa è stato fatto

- **`webapp/src/features/calendar/calendar-grouping.ts`**: port di
  `calendar_grouping.dart` — `localDayKey()`, `groupTasksByDay()`, `tasksOn()`.
- **`webapp/src/features/calendar/queries.ts`**: `useCalendarTasks()`, la
  fetch dei task **non filtrata**, ordinata per scadenza.
- **`webapp/src/features/calendar/calendar-grouping.test.ts`**: 5 test.

## Perché

**Il calendario ignora i filtri della lista.** Se il chip "Da fare" è attivo e
il calendario ne tenesse conto, il mese apparirebbe bucato: mancherebbero
proprio i giorni con i task completati, senza che nulla lo spieghi. La vista
mensile è una panoramica, e una panoramica parziale disorienta. Stessa scelta
del client Flutter, dove `calendarTasksProvider` è indipendente da
`taskFilterProvider`.

Il prezzo è una seconda copia degli stessi dati del server in cache — quella
che in C38 si era desincronizzata. Qui il rischio è disinnescato dalla chiave:
`['tasks', 'calendar']` sta sotto il prefisso `['tasks']`, che ogni mutazione
già invalida.

## Come funziona

**Perché una stringa come chiave.** In Dart, `DateTime` implementa
l'uguaglianza per valore, quindi due date uguali sono la stessa chiave di
mappa. In JavaScript no: due `Date` con lo stesso istante sono oggetti
distinti, e una `Map` che le usa come chiavi non troverebbe mai niente.
`localDayKey()` produce quindi `YYYY-MM-DD`, che come chiave è anche più facile
da leggere quando si ispeziona lo stato.

**Perché il giorno *locale*.** Il backend manda istanti UTC. Un task che scade
alle 23:30 UTC del 5 luglio, per chi sta in Italia d'estate, scade all'01:30
del **6** luglio: sul calendario deve comparire lì, dove l'utente lo cerca.
Usare `getFullYear/getMonth/getDate` — che sono già in ora locale — invece di
tagliare la stringa ISO (`dueDate.slice(0, 10)`, che darebbe il giorno UTC)
è la differenza fra un pallino nel posto giusto e uno nel giorno sbagliato per
tutti quelli che scadono a tarda sera.

**I task senza scadenza restano fuori.** Non hanno un giorno a cui
appartenere; comparirebbero arbitrariamente da qualche parte, o non
comparirebbero — meglio dirlo nel codice che scoprirlo dopo.

## Il ciclo TDD

Cinque test: la chiave è il giorno locale (verificata alle 23:00 e a
mezzanotte, le due ore che sbagliano se si usa UTC); i task dello stesso
giorno finiscono insieme a qualunque ora; quelli senza scadenza restano fuori;
il raggruppamento regge a cavallo di mese e di anno; `tasksOn` seleziona per
giorno ignorando l'ora.

I test costruiscono le date con `new Date(anno, mese, giorno, ora)`, cioè in
**ora locale**: è così che le vede l'utente, ed è ciò che il calendario deve
rispettare, qualunque sia il fuso di chi esegue i test.

## Concetti chiave

- **Le chiavi di mappa in JavaScript sono per identità**, salvo primitivi: una
  data come chiave va serializzata.
- **UTC per trasportare, locale per mostrare**: la conversione va fatta una
  volta sola, nel punto giusto.
- **Escludere esplicitamente** ciò che non appartiene alla vista, invece di
  lasciare che ci finisca per caso.

## Per approfondire

- [MDN — `Map` e uguaglianza delle chiavi](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Map)
- C33 (`C33-calendar-view.md`) e C38 (`C38-calendar-invalidation.md`)
