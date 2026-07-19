# C56 — Dati della dashboard: 42 giorni in 6 barre

## Cosa è stato fatto

- **`webapp/src/features/dashboard/weekly-completions.ts`**: port di
  `weekly_completions.dart` — aggrega i conteggi giornalieri in sei settimane.
- **`webapp/src/features/dashboard/{api,queries}.ts`**: `/analytics/summary` e
  `/analytics/completions?days=42`, sotto la chiave `['analytics']` che le
  mutazioni dei task già invalidano.
- **`webapp/src/features/dashboard/weekly-completions.test.ts`**: 6 test.

## Perché

**Perché aggregare nel client.** Il backend potrebbe restituire direttamente
sei totali settimanali, e sarebbe meno lavoro qui. Ma il confine di una
settimana dipende dal fuso di chi guarda: un completamento registrato alle
23:30 UTC di domenica appartiene alla settimana **successiva** per un utente
italiano. Il backend non sa dove si trova chi guarda; il client sì. È la stessa
divisione di responsabilità del raggruppamento per scadenza (C48) e della
chiave del calendario (C54): il server manda istanti, il client decide come si
chiama il giorno.

**Perché sei barre e non 42.** Quarantadue barre giornaliere su un grafico
largo qualche centinaio di pixel sono una spazzola grigia: si vede che
"qualcosa succede", non *cosa*. Sei barre settimanali mostrano un andamento
leggibile a colpo d'occhio. Stessa scelta di C35 lato Flutter.

## Come funziona

**L'ancora è il lunedì corrente.** Da lì si torna indietro di sette giorni alla
volta per costruire gli inizi delle sei settimane, dalla più vecchia alla più
recente. Ogni giorno ricevuto viene assegnato alla settimana che lo contiene;
quelli fuori finestra (il backend potrebbe mandarne di più) vengono scartati
invece di finire nel primo bucket disponibile.

**`parseISO` invece di `new Date(stringa)`.** Il backend manda date come
`"2026-07-13"`, senza ora. `new Date("2026-07-13")` le interpreta come
**mezzanotte UTC**, che in Italia è l'01:00 o le 02:00 del 13 — ma in altri fusi
è ancora il 12. `parseISO` di date-fns le legge come mezzanotte **locale**,
coerentemente con il taglio delle settimane che stiamo costruendo. Una
differenza di due ore che sposta un giorno di bucket, e che nessuno noterebbe
finché qualcuno non guarda il grafico dalle Americhe.

**Zero-filling.** Le settimane senza completamenti valgono zero, non spariscono:
un grafico con barre mancanti mentirebbe sull'andamento, comprimendo l'asse.

## Il ciclo TDD

Sei test con il tempo iniettato (mercoledì 15 luglio 2026, settimana che apre
lunedì 13): sei bucket sempre presenti con le etichette giuste; zero-filling;
somma dei giorni della stessa settimana; **assegnazione ai confini** — domenica
12 nella settimana precedente, lunedì 13 in quella corrente; scarto dei giorni
fuori finestra; parametro `weeks` diverso da sei.

Il test dei confini è quello che vale: è lì che si sbaglia, ed è invisibile a
occhio in un grafico.

## Concetti chiave

- **Chi conosce il fuso fa i conti**: l'aggregazione per giorno o settimana
  appartiene al client.
- **`new Date('YYYY-MM-DD')` è UTC**, `parseISO` è locale: la differenza è un
  giorno intero per metà del pianeta.
- **Zero esplicito ≠ dato assente**: nei grafici il buco è una bugia.
- **Aggregare per leggibilità** è una decisione di prodotto, non un dettaglio
  tecnico.

## Per approfondire

- [date-fns — `parseISO`](https://date-fns.org/docs/parseISO) e [`startOfWeek`](https://date-fns.org/docs/startOfWeek)
- C34 (`C34-backend-analytics.md`) e C35 (`C35-dashboard-charts.md`)
