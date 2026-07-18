# C27 — Scadenze intelligenti: raggruppamento e ritardi in evidenza

## Cosa è stato fatto

- **`due_grouping.dart`** (domain service): la funzione **pura**
  `groupByDue(tasks, now)` → sezioni ordinate **In ritardo / Oggi /
  Domani / Questa settimana / Più avanti / Senza scadenza / Completati**
  (vuote omesse), più `isOverdue(task, now)` — la definizione *unica* di
  ritardo: scadenza passata E non completato.
- La lista renderizza le sezioni con **header + badge conteggio**
  (rosso per In ritardo, primary per le altre); il raggruppamento vale
  solo col sort di default — un sort esplicito dà lista piatta.
- **`TaskCard`**: la riga scadenza dei task in ritardo diventa
  `colorScheme.error` con icona warning e peso maggiore.
- 11 test scritti prima sulla funzione pura (i *confini*: 23:59 di oggi
  è Oggi; stamattina alle 9 con orologio alle 15 è In ritardo; DONE mai
  in ritardo; ordine fisso) + widget test delle sezioni con badge.

## Perché

**Perché una funzione pura in `domain/services`?** Il bucketing è
logica di dominio piena di casi limite temporali — il posto peggiore per
metterla è dentro un widget. Da funzione pura `(tasks, now) → sezioni` è
testabile con un `now` **iniettato**: niente orologio di sistema nei
test, ogni confine verificato con date esatte. Il widget si limita a
renderizzare il risultato.

**La decisione di design: i DONE collassano in "Completati".** Il
requisito era "DONE mai in ritardo", ma restava aperto *dove* mettere un
task completato con scadenza passata. Le opzioni brutte: dentro "In
ritardo" (falso allarme), in un bucket di calendario (rumore tra il
lavoro attivo). La scelta: il raggruppamento per urgenza riguarda il
lavoro *da fare*; tutto ciò che è fatto scivola in un'unica sezione in
fondo, qualunque data avesse. È la semantica di Todoist/Things, e rende
il badge di "In ritardo" un numero di cui fidarsi.

**Perché "In ritardo" usa l'ora e non il giorno?** Un task scaduto alle
9 di stamattina *è* in ritardo alle 15 — dirgli "Oggi" sarebbe mentire.
Il confine di Oggi/Domani è invece il giorno di calendario **locale**
(`toLocal()` prima di ogni confronto: le date viaggiano in UTC dal
backend, ma "oggi" è un concetto del fuso dell'utente).

**Perché il raggruppamento si spegne con un sort esplicito?** Se
l'utente ordina per titolo, intercalare header di urgenza spezzerebbe
l'ordine chiesto. Regola semplice: raggruppamento e ordinamento sono
modi alternativi di leggere la lista, non si sovrappongono.

## Come funziona

- `classify` calcola i giorni di distanza tra il giorno di scadenza e
  oggi (mezzenotte locale): 0=Oggi, 1=Domani, 2..6=Questa settimana,
  oltre=Più avanti — con un `switch` su pattern relazionali Dart 3
  (`>= 2 && <= 6`).
- Le sezioni escono già nell'ordine dell'enum (`DueGroup.values`):
  l'ordine di presentazione è una proprietà del tipo, non del chiamante.
- `isOverdue` è esportata e usata anche dalla card: un'unica sorgente
  per la regola, come pianificato — quando arriverà l'analytics backend
  (C34), userà la stessa definizione.

## Il ciclo TDD in questo commit

1. **Rosso** — 11 test di confine sulla funzione pura inesistente.
2. **Verde** — la funzione al primo colpo (i test di confine scritti
   prima *costringono* a pensare i casi limite prima del codice — qui il
   TDD dà il meglio); poi sezioni UI e accento card.
3. **Refactor** — il rendering della card dismissible estratto in
   `_dismissibleCard` per servire sia il ramo raggruppato sia il piatto.

## Concetti chiave

- **Tempo iniettato**: `now` come parametro = test deterministici.
- **Confini locali**: "oggi" è un concetto di fuso; UTC solo in transito.
- **Una regola, una definizione**: `isOverdue` condivisa tra grouping,
  card e (futuro) analytics.
- **Design deciso, non subito**: i DONE in fondo è una *scelta*
  documentata, non un caso dimenticato.

## Per approfondire

- [Dart 3 — patterns e relational patterns](https://dart.dev/language/patterns)
- [Working with time zones (Flutter/Dart)](https://dart.dev/libraries/dart-core#datetime)
- [NN/g — Visibility of system status](https://www.nngroup.com/articles/visibility-system-status/) (perché il ritardo va *mostrato*, non calcolato mentalmente)
- ROADMAP: la Fase 6 non prevede questo esplicitamente — è un'estensione UX nata dall'obiettivo "uso quotidiano"
