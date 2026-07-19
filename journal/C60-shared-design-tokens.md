# C60 — Un solo file di token per due client

## Cosa è stato fatto

- **`tokens/tokens.json`**: la fonte di verità dei design token — seed, schema
  colori chiaro e scuro, spaziature, raggi, accenti di priorità, palette degli
  otto swatch, rampe dei grafici.
- **`tokens/generate.mjs`**: il generatore. Produce
  `frontend/lib/core/theme/generated_tokens.dart` e
  `webapp/src/styles/tokens.css`; con `--check` non scrive e fallisce se i
  file su disco sono disallineati.
- **Rifattorizzati i consumatori**: in Flutter `dimens.dart`,
  `priority_colors.dart`, `list_colors.dart` e il seed di `app_theme.dart`; in
  webapp `index.css`, `list-colors.ts` e `chart-colors.ts`.
- **`webapp/package.json`**: script `generate:tokens` e `check:tokens`.

## Perché

È qui che l'idea iniziale — *"un motore che genera la webapp dal Flutter"* —
prende la forma che funziona davvero.

Un transpiler Dart→TypeScript risolverebbe il problema sbagliato. Tradurre
codice è la parte facile e poco utile: il risultato sarebbero componenti React
che pensano come widget Flutter, cioè l'esatto contrario di "qualcosa ad hoc
per il web". Il problema vero è un altro, e si vedeva già in C40: gli stessi
**valori** — un indigo, un raggio da 16, sei accenti di priorità — scritti in
due posti, destinati a divergere alla prima modifica fatta di fretta.

Quello che ha senso condividere non è il codice: sono i **dati**. Un file JSON,
due generatori, due file generati. Il seed cambia in un posto e cambiano
entrambe le app.

Alternative valutate:

- **style-dictionary** — lo standard di fatto per i design token. Scartata per
  ora: le sue trasformazioni sono generiche e configurarle per emettere
  esattamente `Color(0xFF…)` per Dart e `@theme` per Tailwind v4 costa più
  delle novanta righe di generatore scritte qui, che sono anche più facili da
  leggere. Da riconsiderare se i formati diventano quattro invece di due.
- **Un pacchetto npm condiviso** — inutile: Flutter non legge npm.
- **Generare anche il `ThemeData` completo** — scartata: i temi contengono
  decisioni (elevazioni, forme, transizioni) che non sono dati, e vanno scritte
  nel linguaggio della piattaforma.

## Come funziona

**Che cosa viene generato per chi.** Flutter riceve costanti Dart; la webapp
riceve custom property CSS. Ma non tutto passa dai file generati: i valori che
sono **dati** e non stili — gli otto swatch, le rampe dei grafici — la webapp
li importa direttamente dal JSON (`resolveJsonModule`), mentre Flutter li
riceve compilati nel file Dart. Due strade per la stessa sorgente, ognuna
idiomatica per la sua piattaforma.

**Costanti piatte, non record.** Il primo tentativo generava un record Dart
(`PriorityTokens.light.lowBackground`). L'analizzatore lo ha rifiutato: Dart
non consente di leggere il campo di un record dentro un'espressione `const`, e
i temi devono restare costanti. Il generatore emette quindi
`PriorityTokens.lightLowBackground`. È il tipo di vincolo che si scopre solo
generando davvero, ed è un buon argomento contro l'idea di generare *codice*
invece che *valori*: più il generato è ricco, più conosce il linguaggio di
destinazione.

**`--check` per la CI.** Rigenera in memoria e confronta: se qualcuno modifica
un file generato a mano, o cambia il JSON senza rilanciare, il comando
fallisce indicando quale file è disallineato. È il meccanismo che impedisce
alla fonte di verità di diventare finzione.

## La verifica

1. **La suite Flutter resta verde**: 128 test passati dopo aver spostato tutti
   i colori del tema sui token generati.
2. **La suite webapp resta verde**: 154 test.
3. **La propagazione è reale**: cambiato uno swatch in `tokens.json`
   (`#0EA5E9` → `#00BCD4`), rilanciato il generatore, verificato che il nuovo
   valore compaia nel file Dart e che il JSON letto dalla webapp lo riporti.
   Poi ripristinato, rigenerato, e `--check` conferma l'allineamento.

Il punto 3 è la prova che la pipeline **funziona**, non che è stata scritta.

## Cosa resta separato, e perché

Il seed è nel JSON, ma i 24 colori dello schema chiaro/scuro sono valori
*derivati* da Material 3, oggi trascritti a mano (estratti eseguendo
`ColorScheme.fromSeed`, vedi C40). Cambiare il seed non li ricalcola: un
commento nel JSON lo dice esplicitamente. Chiudere anche quel cerchio
significherebbe eseguire l'algoritmo M3 nel generatore — fattibile, ma è una
seconda decisione, e per ora la nota onesta vale più dell'automazione parziale.

## Concetti chiave

- **Condividere i dati, non il codice**: i valori sono universali, le
  implementazioni no.
- **Un file generato senza un controllo di allineamento** torna a divergere:
  `--check` è ciò che rende la sorgente autorevole.
- **Più il generatore produce codice, più deve conoscere il linguaggio**: i
  record Dart lo hanno dimostrato subito.
- **Automazione parziale dichiarata** è meglio di automazione presunta.

## Per approfondire

- [Design tokens — W3C Community Group](https://tr.designtokens.org/format/)
- [style-dictionary](https://styledictionary.com/) — l'alternativa strutturata
- C22 e C40 — i due design system che ora condividono la stessa sorgente
