# C35 — Dashboard: statistiche con grafici

## Cosa è stato fatto

- Dipendenza **`fl_chart 1.2.0`**.
- **Feature `features/dashboard/`**: `AnalyticsSummary`/`DayCount`/
  `DashboardData` (dominio), `AnalyticsRepository` (le due chiamate in
  parallelo con `Future.wait`), `DashboardNotifier`
  (`AsyncNotifier<DashboardData>`), e la funzione pura `weeklyBuckets`
  (aggrega i completamenti giornalieri in 6 settimane, zero-fill).
- **`DashboardScreen`**: 4 stat card (Totali/Completati/In ritardo/Oggi),
  **bar chart** dei completamenti per settimana, **donut** per priorità,
  empty state se non c'è nulla, refresh.
- 6 test (parsing, `weeklyBuckets`, provider, widget: card + empty).

## Perché il design dei grafici (skill dataviz)

Prima di scrivere una riga di grafico ho consultato la skill `dataviz`,
che impone un ordine: **forma prima, colore per ultimo**.

**Forma.** Le 4 metriche di testa non sono un grafico ma *stat tile*
(numeri-eroe): un grafico per "quanti completati" sarebbe sovradisegno.
I completamenti nel tempo sono *magnitudine su tempo* → bar chart. La
ripartizione per priorità è *identità categoriale* → donut.

**Aggregazione, non fedeltà.** Il backend dà completamenti *giornalieri*
(fino a 42 valori). 42 barre sono illeggibili: `weeklyBuckets` li
raggruppa in **6 settimane**. Il grafico deve raccontare l'andamento, non
riprodurre ogni punto — meno barre, più storia.

**Colore per il lavoro che fa.** Il bar chart è **serie singola** →
*un solo hue* (`colorScheme.primary`), niente legenda (il titolo la nomina
già). Il donut è **categoriale a 3** → i colori seguono l'*entità*
priorità, presi dalla `PriorityColors` extension (C22) che è già tarata e
leggibile in light e dark. Riusare quei colori significa che una fetta
"Alta" del donut ha lo stesso rosso del badge "ALTA" sulle card: coerenza
per costruzione, e dark-mode corretto senza un flip automatico. La skill
vieta di scegliere i colori a occhio; qui il colore *segue un'entità già
validata*, non è inventato per il grafico.

**Identità mai solo col colore.** Il donut ha una **legenda** accanto
(pallino + "Alta (3)"): chi non distingue i colori legge comunque le
categorie e i valori. Le percentuali sono etichette dirette sulle fette.

**Marks.** Barre sottili (16px) con top arrotondato 4px ancorato alla
base, gap di 2px tra le fette del donut, griglia recessiva (solo
orizzontale, `outlineVariant`), assi senza bordo. Sono le mark spec della
skill applicate all'API fl_chart 1.x.

## Perché queste scelte di implementazione

**Perché `Future.wait` sulle due chiamate?** La dashboard ha bisogno di
*entrambi* i dati per renderizzare; lanciarle in parallelo dimezza il
tempo di attesa rispetto a sequenziale. Se una fallisce, l'intera fetch
fallisce (AsyncError → messaggio) — corretto: una dashboard a metà
sarebbe fuorviante.

**Perché `weeklyBuckets` è una funzione pura?** Stessa filosofia di C27:
la logica di bucketing temporale (confini di settimana da lunedì,
zero-fill) è piena di casi limite e va testata con un `now` iniettato,
non dentro il widget. Il grafico riceve 6 numeri già pronti.

**Perché API fl_chart 1.x e non i tutorial 0.x?** La 1.0 ha cambiato
diversi nomi (`AxisTitles`/`SideTitles`, `getTitlesWidget`). Ho scritto
contro i tipi 1.2.0 reali, non copiato snippet vecchi (la skill claude-api
e il buon senso: la versione conta).

## Il ciclo TDD in questo commit

Rosso (parsing + weeklyBuckets + provider + widget) → verde con feature e
grafici. Fix del test della shell: il dashboard reale ora fa fetch via
Dio, che nel test non si stabilizza (spinner infinito) → override di
`analyticsRepositoryProvider` con un fake che ritorna dati vuoti.

## Concetti chiave

- **Forma prima del colore**: stat tile per i numeri, bar per il tempo,
  donut per le categorie.
- **Aggregare per leggibilità**: 6 settimane, non 42 giorni.
- **Il colore segue l'entità**: priorità dal tema, coerente e dark-safe.
- **Identità mai solo col colore**: legenda + etichette sempre.

## Per approfondire

- [fl_chart](https://pub.dev/packages/fl_chart) (API 1.x)
- La skill `dataviz` di questo ambiente: forma → colore → validazione
- [Material 3 — Data visualization](https://m3.material.io/styles/color/the-color-system/color-roles)
- ROADMAP: Fase 8, Settimana 37 (Analytics Dashboard — frontend), kata 8.3 (Chart Kata)
