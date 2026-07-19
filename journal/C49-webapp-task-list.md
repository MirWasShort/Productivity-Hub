# C49 — La lista dei task: card, sezioni e aggiunta rapida

## Cosa è stato fatto

- **`webapp/src/features/tasks/task-list-page.tsx`**: la pagina vera —
  scheletri durante il caricamento, messaggio d'errore, due stati vuoti
  distinti, sezioni per scadenza con badge del conteggio.
- **`webapp/src/features/tasks/components/task-card.tsx`**: casella di spunta,
  titolo barrato quando fatto, descrizione su una riga, scadenza (rossa con
  icona di avviso se in ritardo), pillole dei tag, pillola della priorità e
  pulsante di eliminazione con conferma.
- **`webapp/src/features/tasks/components/{priority-pill,tag-pill,quick-add}.tsx`**
  e **`labels.ts`** con le etichette italiane degli enum.
- **`webapp/src/components/layout/empty-state.tsx`**.
- **`webapp/src/test/render-app.tsx`**: helper che monta l'app vera (rotte,
  guard, provider) a un indirizzo scelto; i test di flusso ora lo condividono.
- Test: 7 sulla pagina.

## Perché

**Lo swipe non si traduce.** Sul telefono si scorre la card per eliminarla; con
un mouse quel gesto non esiste. Il sostituto è un pulsante che compare al
passaggio del mouse — discreto finché non serve — con `focus-visible:opacity-100`
perché chi naviga da tastiera deve poterlo raggiungere lo stesso. E una
conferma prima di procedere: sul telefono lo swipe è un gesto deliberato e la
cancellazione è annullabile con "Annulla" nello snackbar; un click accidentale
no.

**Due stati vuoti, non uno.** "Non hai ancora task" e "nessun task
corrisponde ai filtri" sembrano lo stesso schermo vuoto, ma richiedono azioni
opposte: nel primo caso creane uno, nel secondo togli un filtro. Il client
Flutter fa la stessa distinzione (C24), ed è una di quelle differenze che
l'utente non nota quando c'è e che lo blocca quando manca.

**Le sezioni solo con l'ordinamento predefinito.** Se l'utente ha chiesto
"titolo A-Z", ha esplicitamente scelto un criterio diverso dall'urgenza:
raggrupparlo lo stesso per scadenza vanificherebbe la sua richiesta. La
condizione è `isDefaultFilter(filter)`, la stessa regola di C27.

## Come funziona

**Un solo "adesso" per tutta la lista.** `now` è calcolato una volta e passato
a ogni card. Se ogni card chiamasse `new Date()` per conto suo, due card
renderizzate a cavallo della mezzanotte — o semplicemente a millisecondi di
distanza da una scadenza — potrebbero classificare la stessa ora in modo
diverso: una "in ritardo", l'altra "oggi". Il `useMemo` dipende da `tasks`, non
è vuoto: si aggiorna quando arrivano dati nuovi, ma non a ogni render, altrimenti
le sezioni si riorganizzerebbero sotto le mani dell'utente mentre interagisce.

**I colori dei tag sono dati, non classi.** Tailwind genera le classi in fase
di build a partire dal sorgente: `bg-[${tag.color}]` non può funzionare, perché
il colore si conosce solo a runtime. Le pillole dei tag usano quindi `style`
inline con `withAlpha()` per sfondo al 15% e bordo al 50% — gli stessi valori
del client Flutter. Le pillole della **priorità**, invece, sono classi vere
(`bg-priority-high`), perché i valori possibili sono tre e noti in anticipo:
così seguono il tema chiaro/scuro senza calcoli.

**Etichette accessibili che dicono l'azione, non lo stato.** La casella di
spunta si annuncia come `Completa "Comprare il latte"` o `Segna "…" da fare`;
il pulsante di eliminazione come `Elimina "Comprare il latte"`. Con dieci task
a schermo, dieci pulsanti chiamati tutti "Elimina" sarebbero inutilizzabili
per uno screen reader — e infatti i test selezionano proprio per quel nome.

## Il ciclo TDD

Sette test, scritti prima della pagina:

1. i task finiscono nelle sezioni giuste, con il conteggio accanto al titolo;
2. la card mostra priorità, tag e la scadenza in ritardo;
3. **spuntare la casella manda una PUT con il task completo** (titolo e
   descrizione inclusi) e solo lo stato cambiato;
4. l'aggiunta rapida invia il solo titolo e svuota il campo;
5. l'eliminazione chiede conferma e solo dopo manda la DELETE;
6. senza task compare la spiegazione di come iniziare;
7. un 500 produce un messaggio, non una schermata bianca.

Il terzo è quello che protegge dai dati persi: se `toUpdateRequest` smettesse
di rimandare la descrizione, la PUT la cancellerebbe e nessuno se ne
accorgerebbe finché un utente non perdesse del testo.

**Un errore nei test, non nel codice.** Tre test cercavano la richiesta
sbagliata: guardavano l'*ultima* chiamata a `fetch`, ma dopo ogni mutazione
l'invalidazione fa ripartire la GET della lista, che arriva per ultima.
L'implementazione era corretta; l'assunzione "ultima chiamata = quella che mi
interessa" no. Ora un helper cerca la richiesta **per metodo**.

Verifica contro il backend vero: registrato un utente, creati tre task con
scadenza a −2 giorni, +1 giorno e senza scadenza, riletti dall'API e
riclassificati — "In ritardo", "Domani", "Senza scadenza", come previsto.

## Concetti chiave

- **I gesti non si traducono, si sostituiscono**: lo swipe diventa un pulsante
  che appare, non un'imitazione dello scorrimento.
- **Uno stato vuoto è un messaggio**, e messaggi diversi servono a situazioni
  diverse.
- **Un solo orologio per una schermata**: il tempo condiviso evita
  classificazioni incoerenti nella stessa vista.
- **Classi statiche vs stili dinamici**: Tailwind conosce solo ciò che c'è nel
  sorgente; i valori scelti dall'utente vanno inline.
- **Le etichette accessibili identificano l'oggetto**, non solo l'azione.

## Per approfondire

- [Tailwind — classi generate staticamente](https://tailwindcss.com/docs/detecting-classes-in-source-files)
- [WAI-ARIA — nomi accessibili](https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/)
- C24 (`C24-task-card-empty-state.md`) e C19 (`C19-task-list-screen.md`)
