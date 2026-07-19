# C57 — Dashboard: i colori delle pillole non vanno bene per i grafici

## Cosa è stato fatto

- **`webapp/src/features/dashboard/dashboard-page.tsx`**: quattro riquadri di
  riepilogo, grafico settimanale, ripartizione per priorità, pulsante
  "Aggiorna".
- **`webapp/src/features/dashboard/stat-card.tsx`**: il numero grande con la
  sua etichetta.
- **`webapp/src/features/dashboard/weekly-bar-chart.tsx`**: barre sottili a
  tinta unica, griglia recessiva, tooltip.
- **`webapp/src/features/dashboard/priority-donut.tsx`**: anello a tre fette
  con legenda che riporta etichetta, valore e percentuale.
- **`webapp/src/features/dashboard/chart-colors.ts`**: le rampe validate per
  tema chiaro e scuro.
- **`webapp/src/test/setup.ts`**: polyfill di `ResizeObserver`.
- Test: 6 sulla dashboard.

## Perché

**Il riepilogo non è un grafico.** Quattro numeri (totali, completati, in
ritardo, oggi) sono quattro numeri: scritti grandi si leggono in un istante,
mentre un istogramma a quattro barre chiederebbe di misurare le altezze per
ricavare informazioni che sono già scritte lì accanto. Quando la storia è un
numero, la forma giusta è il numero.

**L'anello per le priorità sì, ma con condizioni.** Un anello (o una torta) va
bene solo per il parte-sul-tutto a colpo d'occhio, con poche fette, e mai per
confrontare valori vicini. Tre priorità rientrano; la legenda riporta comunque
valori e percentuali, così chi vuole confrontare legge i numeri invece di
stimare gli spicchi.

### La scoperta: i colori delle pillole falliscono la validazione

I colori di priorità del design system (verde `#1B5E20`, ambra `#8A5A00`,
rosso `#B3251E`) sembravano la scelta ovvia per l'anello: sono già i colori
della priorità in tutta l'app. Passati al validatore della palette, però:

```
[FAIL] CVD separation     #B3251E ↔ #8A5A00  ΔE 0.7 (deutan)
[FAIL] Normal-vision floor #B3251E ↔ #8A5A00  ΔE 12.8 — sotto 15
```

Ambra e rosso **collassano** sotto deuteranopia (la forma più comune di
daltonismo: ΔE 0.7 significa praticamente lo stesso colore), e restano difficili
da distinguere anche a vista piena. Sulle pillole non è un problema — ognuna
porta il suo testo, `MEDIA` o `ALTA` — ma in un anello lo spicchio è **solo**
colore: chi non li distingue non può leggere il grafico.

La soluzione non è cercare tre tinte "più diverse", ma accorgersi che la
priorità è una scala **ordinata**: Bassa < Media < Alta. Le scale ordinate
vogliono una **rampa a una sola tinta** con luminosità crescente, così l'ordine
si vede nel colore invece di essere una convenzione da ricordare. Le due rampe
scelte — indigo del brand, tre passi — passano tutti i controlli sui rispettivi
sfondi:

| | Bassa | Media | Alta |
|---|---|---|---|
| chiaro | `#A8A4F0` | `#6E6BB8` | `#424178` |
| scuro | `#4E4C8A` | `#8481D6` | `#C3C0FF` |

Il tema scuro non è un'inversione automatica: è una seconda rampa, scelta e
validata contro la superficie scura (`#131318`). Un colore che ha contrasto
sufficiente sul bianco non ce l'ha per forza sul quasi-nero.

## Come funziona

**Colori dei grafici separati dai token dell'interfaccia.** `chart-colors.ts`
espone una funzione che legge il tema corrente e restituisce **valori**, non
classi: Recharts disegna in SVG e vuole colori veri. È anche il posto in cui è
scritto perché le rampe sono quelle e non altre.

**Barre**: una sola serie, quindi una sola tinta e nessuna legenda — il titolo
della sezione dice cosa sono. Estremo superiore arrotondato di 4px e ancorato
alla base, larghezza massima 28px, griglia solo orizzontale nel colore dei
bordi, assi senza linea. I dati devono essere la cosa più marcata del riquadro.

**Zero non è vuoto**: se non c'è nessun task da ripartire, al posto dell'anello
compare una frase. Un anello a somma zero non si disegna, e Recharts
disegnerebbe comunque qualcosa di privo di senso.

**Nota sull'ambiente di test**: Recharts si adatta al contenitore tramite
`ResizeObserver`, che jsdom non implementa. Il setup ne installa uno finto —
nei test le dimensioni sono zero comunque, basta che l'oggetto esista.

## Il ciclo TDD

Sei test: i quattro numeri di riepilogo; **la ripartizione mostra etichette e
percentuali**, non solo colori (è il test che garantisce l'accessibilità
dell'anello); la richiesta chiede 42 giorni; senza task compare la frase invece
dell'anello; "Aggiorna" fa ripartire le richieste; un errore viene detto.

Verifica contro il backend vero: creati tre task (uno scaduto ad alta priorità,
uno in scadenza oggi, uno completato) e riletti gli endpoint —
`total 3, completed 1, overdue 1, dueToday 1`, ripartizione `1/1/1`, e un
giorno con un completamento nella finestra di 42 giorni. I numeri della
dashboard corrispondono.

## Concetti chiave

- **La palette si valida, non si guarda**: due colori "diversi" possono essere
  identici per il 8% degli uomini.
- **Colore che porta identità da solo va validato; colore accanto a un'etichetta
  no**: lo stesso token può andare bene in un posto e non in un altro.
- **Scala ordinata → rampa a una tinta**: l'ordine si vede.
- **Il tema scuro si sceglie**, non si inverte.
- **Quando la storia è un numero, scrivilo grande.**

## Per approfondire

- [Recharts](https://recharts.org/)
- C35 (`C35-dashboard-charts.md`) — la stessa dashboard in Flutter, con i
  colori delle pillole nell'anello: da rivedere alla luce di questo commit
- C34 (`C34-backend-analytics.md`) — gli endpoint che alimentano tutto questo
