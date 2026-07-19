# C61 — Golden fixture: la prova che le due implementazioni coincidono

## Cosa è stato fatto

- **`fixtures/{due-grouping,weekly-completions,calendar-grouping}.json`**: 14
  casi input/output della logica di dominio, con la convenzione sulle date
  documentata in `fixtures/README.md`.
- **`frontend/test/domain/golden_fixtures_test.dart`**: la suite Dart li legge
  e li verifica contro `groupByDue`, `weeklyBuckets`, `groupTasksByDay`.
- **`webapp/src/test/golden-fixtures.test.ts`**: la suite TypeScript fa lo
  stesso con i port.

## Perché

Questo commit chiude il ragionamento cominciato in C48 e proseguito in C60.

L'idea di partenza era un **motore che generasse la webapp dal client Flutter**.
Applicata al design system è diventata una cosa utile (C60: una sorgente di
token, due generatori). Applicata alla logica di dominio sarebbe stata un
transpiler Dart→TypeScript — e il transpiler risolve il problema sbagliato.
Tradurre quaranta righe pure è la parte facile; la parte difficile è
**dimostrare che le due versioni si comportano allo stesso modo**, e un
traduttore automatico non la dimostra: la assume.

Le golden fixture la dimostrano. Gli stessi casi, verificati da entrambe le
suite: se una delle due implementazioni deriva — perché qualcuno cambia un
confine, o perché una libreria di date si comporta diversamente da come ci si
aspettava — il test dell'altra lo dice. Ed è verifica **continua**: gira a ogni
esecuzione dei test, non una volta sola al momento della traduzione.

In più le fixture sono leggibili da un essere umano. `"confini: domenica chiude
la settimana, lunedì apre la successiva"` è una specifica che si può discutere;
un albero sintattico tradotto no.

## Come funziona

**Le date sono scritte senza fuso** (`2026-07-15T12:00:00`). È il dettaglio che
rende le fixture eseguibili ovunque: sia `DateTime.parse` in Dart sia
`new Date(...)` in JavaScript interpretano una data-ora priva di offset come
**ora locale**. I casi descrivono quindi orari da orologio a muro, e i
risultati non dipendono dal fuso di chi lancia i test — cosa che invece
succederebbe con istanti in UTC, dato che tutta la logica ragiona per giorni
locali (C48, C54, C56).

**Ogni caso genera un test con il proprio nome**, in entrambi i linguaggi:
l'output di `flutter test` e quello di `vitest` elencano le stesse quattordici
frasi. Chi legge i due report vede la stessa specifica.

**Il test TypeScript verifica anche la chiave del calendario**: ogni chiave
prodotta deve essere il giorno locale della data corrispondente. È un controllo
in più che il lato Dart non ha bisogno di fare, perché lì la chiave è un
`DateTime` e non una stringa — una delle differenze fra le due implementazioni
che le fixture, lavorando sui risultati, attraversano senza problemi.

## La verifica della verifica

Come per le asserzioni di tipo in C42, una guardia che non si è mai vista
fallire non serve a niente. Cambiato di proposito il confine di "questa
settimana" nel port TypeScript (`<= 6` diventa `<= 5`):

```
× oggi, domani e questa settimana
      "group": "thisWeek",
+     "group": "later",
```

La fixture se ne accorge e indica il caso esatto. Ripristinato, 14 casi verdi
in entrambe le suite. Suite complete: **142 test Flutter**, **168 test webapp**.

## Cosa non coprono

Le fixture coprono la **logica pura**: classificazione, aggregazione,
raggruppamento. Non coprono l'interfaccia — e non devono: le due app sono
diverse di proposito (C41, C49, C52), e un confronto pixel a pixel andrebbe
contro l'obiettivo. Il confine è netto: **si condivide ciò che deve essere
identico** (valori e comportamenti di dominio), si lascia divergere ciò che
deve adattarsi alla piattaforma.

## Concetti chiave

- **Testare l'equivalenza batte generare il codice**: la verifica è continua,
  la traduzione è una volta sola.
- **Un caso di prova è una specifica leggibile**, un albero sintattico no.
- **Date senza fuso = fixture portabili**, quando la logica ragiona per giorni
  locali.
- **Rompere di proposito** è l'unico modo di sapere se una guardia protegge.
- **Condividere ciò che deve coincidere**, lasciar divergere il resto.

## Per approfondire

- [Golden / approval testing](https://approvaltests.com/)
- C42 — la stessa disciplina applicata alle asserzioni di tipo
- C48, C54, C56 — i tre port che queste fixture tengono allineati
- C60 — l'altra metà della pipeline: i design token
