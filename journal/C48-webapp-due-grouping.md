# C48 — Scadenze intelligenti, seconda volta: portare una funzione pura

## Cosa è stato fatto

- **`webapp/src/features/tasks/due-grouping.ts`**: port di
  `frontend/lib/features/task/domain/services/due_grouping.dart`. Sette gruppi
  (`overdue`, `today`, `tomorrow`, `thisWeek`, `later`, `noDate`,
  `completed`), le etichette italiane, `isOverdue()` e `groupByDue()`.
- **`webapp/src/features/tasks/due-grouping.test.ts`**: 11 casi che coprono
  l'intera tabella di classificazione, i confini e l'ordine delle sezioni.

## Perché

Questa è la prima logica di **dominio** che la webapp condivide con il client
Flutter, e la domanda ovvia è: perché riscriverla invece di generarla?

Perché è una funzione pura di quaranta righe, e il costo vero non è scriverla
due volte — è **tenerle d'accordo**. Un transpiler Dart→TypeScript
risolverebbe il problema sbagliato: automatizzerebbe la traduzione (facile) e
non garantirebbe comunque l'equivalenza (difficile), perché le due
piattaforme differiscono proprio dove conta, cioè nell'aritmetica delle date.

La garanzia arriverà in C61, con le **golden fixture**: gli stessi casi
input/output in un file JSON, verificati sia da `flutter test` sia da Vitest.
Se una delle due implementazioni deriva, il test dell'altra lo dice. È
equivalenza dimostrata invece che sperata, e non richiede di far parlare due
linguaggi.

## Come funziona

**Il tempo è un parametro.** `groupByDue(tasks, now)` riceve l'istante invece
di chiamare `new Date()` dentro: è ciò che rende testabili i confini. Il test
fissa mercoledì 15 luglio 2026 alle 12:00 e verifica che le 09:00 dello
**stesso giorno** siano "in ritardo" mentre le 18:00 siano "oggi" — un caso che
con l'orologio reale sarebbe verde o rosso a seconda di quando lo esegui.

**Giorni di calendario, non ore diviso 24.** La classificazione usa
`differenceInCalendarDays` di date-fns, che confronta le date *azzerate a
mezzanotte locale*. La differenza è sostanziale: fra le 23:00 di oggi e
l'01:00 di domani ci sono due ore, ma un giorno di calendario — e per un
utente quella scadenza è "domani", non "fra due ore". Una divisione per
86.400.000 direbbe zero, e il task finirebbe in "Oggi". Il codice Dart fa la
stessa cosa costruendo `DateTime(y, m, d)` per entrambe le date; qui la
libreria lo fa per noi, DST compreso.

**L'ordine delle sezioni è dato dall'array `dueGroups`**, non dall'ordine di
inserimento. Si raccoglie in una `Map`, poi si scorre l'array dei gruppi in
ordine di urgenza filtrando quelli vuoti. Così l'ordine è una proprietà
dichiarata in un punto solo, e le sezioni vuote spariscono invece di lasciare
intestazioni orfane.

**L'ordine *dentro* la sezione è quello di arrivo**, cioè quello deciso dal
backend con `sortBy`. Il raggruppamento non riordina: aggiunge una struttura
sopra un elenco già ordinato. Un test lo blinda, perché è il tipo di proprietà
che si perde facilmente rifattorizzando con `sort()`.

## Il ciclo TDD

Undici test scritti prima dell'implementazione, uno per riga della tabella di
classificazione del sorgente Dart:

- scaduto ieri e scaduto stamattina → "In ritardo";
- oggi più tardi → "Oggi"; +1 → "Domani"; +2 e +6 → "Questa settimana";
- +7 e +365 → "Più avanti"; nessuna scadenza → "Senza scadenza";
- completato con qualunque scadenza (passata, oggi, assente) → "Completati";
- in corso e scaduto → resta "In ritardo";
- ordine delle sezioni con i vuoti saltati, ordine interno preservato,
  elenco vuoto, e la presenza di un'etichetta per tutti e sette i gruppi.

I confini sono testati **a coppie** (+1/+2, +6/+7): un test solo sul valore
centrale passerebbe anche con la disuguaglianza sbagliata.

## Concetti chiave

- **Iniettare il tempo**: una funzione che legge l'orologio da sé non è
  testabile, è solo fortunata.
- **Giorni di calendario ≠ intervalli di 24 ore**: per gli esseri umani
  "domani" è un giorno del calendario, non un numero di millisecondi.
- **Testare i confini a coppie**, sempre da entrambi i lati.
- **L'ordine dichiarato in un posto solo**: l'array dei gruppi *è* la
  specifica dell'urgenza.
- **Duplicare consapevolmente**: quaranta righe pure si riscrivono; a essere
  costoso è tenerle allineate, e per quello servono le fixture condivise.

## Per approfondire

- [date-fns — `differenceInCalendarDays`](https://date-fns.org/docs/differenceInCalendarDays)
- C27 (`C27-due-grouping.md`) — l'originale in Dart, con la stessa tabella
