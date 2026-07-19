# C50 — Barra dei filtri: due bug trovati dai test, uno vero

## Cosa è stato fatto

- **`webapp/src/features/tasks/components/filter-bar.tsx`**: ricerca con
  attesa di 300ms e pulsante per cancellarla, menu di ordinamento con le
  quattro opzioni del client Flutter, chip a selezione singola per stato e
  "Alta priorità".
- **`webapp/src/features/tasks/task-list-page.tsx`**: il filtro è ora stato
  della pagina; con un ordinamento diverso da quello predefinito la lista
  diventa piatta, senza sezioni.
- **`webapp/src/features/tasks/filter-bar.test.tsx`**: sette test.

## Perché

**L'attesa prima di interrogare.** Digitare "latte" sono cinque tasti: senza
attesa sarebbero cinque richieste, di cui quattro già inutili quando arrivano.
I 300ms sono gli stessi del client Flutter (C26): abbastanza da coprire la
digitazione continua, abbastanza pochi da non sembrare lento.

**Chip a selezione singola.** Ricliccare il chip attivo lo spegne, e sceglierne
un altro sostituisce il primo. È il comportamento del `FilterChip` Flutter, ed
è dettato dal backend: `GET /tasks` accetta **un** valore per `status` e uno
per `priority`, non una lista. Un'interfaccia che lasciasse selezionare due
stati prometterebbe qualcosa che l'API non sa fare.

**Lista piatta con ordinamento diverso.** Le sezioni per scadenza sono una
lettura per urgenza; se l'utente chiede "Titolo A-Z" ha chiesto un'altra
lettura, e sovrapporre le due non aiuta nessuno.

## Come funziona

**Testo locale, filtro condiviso.** Il campo di ricerca tiene il proprio stato
(`term`) e reagisce a ogni tasto, mentre il filtro — che è ciò che fa partire
la richiesta — viene aggiornato solo allo scadere dell'attesa. Sono due
frequenze diverse per due scopi diversi: la reattività visiva e il costo di
rete.

### Il bug vero: la chiusura del debounce

La prima versione era il classico effetto con `deps: [term]`:

```tsx
useEffect(() => {
  const timer = setTimeout(() => onChange(withSearch(filter, term)), 300)
  return () => clearTimeout(timer)
}, [term])
```

Due difetti, entrambi capaci di **cancellare le scelte dell'utente**:

1. l'effetto gira anche **al montaggio**. Se nei primi 300 millisecondi
   l'utente clicca un chip, il timer iniziale scade subito dopo e chiama
   `onChange` con il filtro *catturato al montaggio*, cioè quello vuoto: il
   chip appena acceso si spegne da solo;
2. anche più tardi, `filter` dentro l'effetto è quello del render in cui il
   testo è cambiato. Se fra il tasto e lo scadere dell'attesa cambia
   qualcos'altro, la scrittura ritardata lo sovrascrive con un valore vecchio.

La correzione è duplice: il filtro si legge da un `useRef` sempre aggiornato
(così al momento della scrittura si parte dallo stato *attuale*), e l'effetto
esce subito se il testo corrisponde già al filtro — che è il caso del
montaggio. Il pattern generale: **un aggiornamento ritardato deve leggere lo
stato al momento in cui scrive, non al momento in cui è stato programmato.**

### Il bug finto: la Response riusata

Due test fallivano in modo incomprensibile — chip premuto, parametri corretti,
ma la pagina mostrava lo stato vuoto sbagliato. Isolando il caso, funzionava.

Colpa del mock: `mockResolvedValue(jsonResponse(...))` crea **un solo** oggetto
`Response` e lo restituisce a ogni chiamata. Ma il corpo di una `Response` è
uno stream leggibile una volta sola (lo stesso motivo per cui in C43 serviva
`clone()`): dalla seconda richiesta in poi la lettura falliva, la query andava
in errore e la pagina mostrava tutt'altro. Ora il mock costruisce una risposta
nuova a ogni chiamata.

Vale la pena distinguere i due casi: il primo era un bug del codice che i test
hanno trovato prima degli utenti; il secondo era un bug dei test, che imitavano
male la realtà. Entrambi si sono manifestati nello stesso modo — un'asserzione
rossa — e solo leggendo cosa succedeva si capiva quale fosse quale.

## Il ciclo TDD

Sette test: attesa della ricerca (cinque caratteri → **una** richiesta),
cancellazione che toglie il parametro invece di mandarlo vuoto, chip che filtra
e si spegne ricliccato, due chip che si escludono, menu che cambia campo e
direzione insieme aggiornando la propria etichetta, sezioni che spariscono con
l'ordinamento alfabetico, stato vuoto che parla di filtri quando i filtri ci
sono.

Il primo conta le chiamate a `fetch`, non solo il risultato: senza quel
conteggio, un debounce rotto passerebbe il test (il parametro finale sarebbe
comunque `latte`) mandando cinque richieste.

## Concetti chiave

- **Un aggiornamento ritardato legge lo stato quando scrive**, non quando
  viene programmato: da qui il ref.
- **Gli effetti girano anche al montaggio**: quasi sempre va gestito
  esplicitamente.
- **L'interfaccia non deve promettere ciò che l'API non fa**: selezione singola
  perché il backend accetta un valore solo.
- **I mock devono imitare i vincoli reali**: una `Response` riusata non esiste
  in natura.
- **Contare le chiamate, non solo guardare il risultato**, quando ciò che si
  vuole verificare è *quante volte* qualcosa accade.

## Per approfondire

- [React — effetti e valori reattivi](https://react.dev/learn/removing-effect-dependencies)
- [MDN — `Response.clone()` e stream a lettura singola](https://developer.mozilla.org/docs/Web/API/Response/clone)
- C26 (`C26-frontend-filter-bar.md`) — la stessa barra in Flutter
