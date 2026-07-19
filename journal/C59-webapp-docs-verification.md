# C59 — Documentazione e verifica: la webapp entra nel monorepo

## Cosa è stato fatto

- **`README.md`** e **`CLAUDE.md`** di radice: il progetto ha tre componenti,
  non due; comandi, architettura e stato aggiornati.
- **`webapp/README.md`**: stack, comandi, struttura e — soprattutto — l'elenco
  delle **differenze volute** rispetto al client Flutter.
- Verifica end-to-end contro il backend vero e contro la build di produzione
  servita da `vite preview`.

## Perché

Un monorepo con tre client si legge male se i documenti ne raccontano due. Ma
la parte che vale davvero è l'elenco delle divergenze: senza, la prossima
persona che apre le due app le trova diverse e non sa se sia una scelta o una
dimenticanza. Ogni riga di quell'elenco rimanda alla entry che la argomenta.

## La checklist di parità

Confronto schermata per schermata con il client Flutter:

| Funzione | Flutter | Webapp |
|---|---|---|
| Registrazione e login | ✅ | ✅ |
| Refresh trasparente del token | ✅ (`QueuedInterceptor`) | ✅ (promessa condivisa, C44) |
| Guard di sessione | ✅ | ✅ + ritorno alla pagina richiesta |
| Lista task con raggruppamento per scadenza | ✅ | ✅ (C48/C49) |
| Ricerca, ordinamento, chip di stato/priorità/tag | ✅ | ✅ (C50/C53) |
| Aggiunta rapida | ✅ (bottom sheet) | ✅ (campo in cima) |
| Dettaglio ed editor | ✅ | ✅ (C51) |
| Liste con colore, filtro, creazione, eliminazione | ✅ (drawer) | ✅ (barra laterale, C52) |
| Tag: creazione, eliminazione, filtro, multi-select | ✅ | ✅ + **rinomina** (C53) |
| Calendario mese / 2 settimane / settimana | ✅ | ✅ (C55) |
| Dashboard: 4 numeri, barre, ripartizione priorità | ✅ | ✅ (C57) |
| Tema chiaro/scuro persistito | ✅ | ✅ (C40) |
| Interfaccia in italiano | ✅ | ✅ |

Divergenze volute (tutte argomentate nelle rispettive entry):

- barra laterale unica al posto di barra inferiore + drawer (C41);
- lista selezionata nell'URL invece che in uno stato globale (C52);
- eliminazione su hover con conferma al posto dello swipe (C49);
- titolo della scheda, favicon, scorciatoia `/` (C58);
- rinomina dei tag, che in Flutter non è ancora esposta (C53);
- colori dei grafici diversi da quelli delle pillole (C57) — ed è l'unica
  divergenza che segnala un **problema aperto nel client Flutter**, dove
  l'anello usa colori che collassano sotto deuteranopia.

## La verifica

Non solo `npm test`: uno script che parla con il backend vero e con la build di
produzione.

1. registrazione di un utente nuovo;
2. creazione di lista e tag;
3. quattro task — scaduto ad alta priorità con lista e tag, in scadenza domani,
   fra cinque giorni, e uno completato;
4. **i cinque filtri**: per lista, per tag, ricerca testuale, per stato,
   ordinamento per titolo — ognuno restituisce esattamente ciò che deve;
5. analytics: `total 4, completed 1, overdue 1`, ripartizione `1/2/1`;
6. **rotazione del refresh token**: la nuova coppia arriva e il vecchio token
   risponde 401 — il comportamento su cui è costruita la serializzazione di C44;
7. la build servita da `vite preview` risponde sull'indice **e sui link
   profondi** (`/calendar` → 200), cioè il ripiego SPA funziona.

Il punto 7 merita una nota: una SPA con rotte lato client ha bisogno che il
server risponda `index.html` per qualunque percorso, altrimenti aprire un link
diretto dà 404. `vite preview` lo fa; **qualunque hosting di produzione dovrà
essere configurato allo stesso modo**, ed è la prima cosa da controllare al
primo deploy.

## Cosa resta aperto

- **CORS**: `CorsConfig.java` permette solo `http://localhost:*`. Prima di un
  deploy va esternalizzato in una proprietà sovrascrivibile da ambiente.
- **Nessun endpoint di logout**: entrambi i client scartano i token localmente.
  Un `/auth/logout` che revoca il refresh token è il passo successivo naturale.
- **Bundle da ~550 kB** (~170 kB compressi): accettabile, ma il primo
  intervento sensato è il caricamento differito delle rotte pesanti
  (dashboard e calendario portano Recharts e date-fns).
- **Il client Flutter va allineato** su rinomina dei tag e colori dell'anello.

## Concetti chiave

- **Documentare le divergenze**, non solo le funzioni: una differenza non
  spiegata sembra un bug.
- **Verificare la build, non solo il codice sorgente**: `dev` e `preview` non
  sono la stessa cosa.
- **Il ripiego SPA è configurazione di hosting**, e va verificato presto.
- **Una checklist di parità è un documento, non un ricordo.**

## Per approfondire

- [Vite — deploy di una SPA statica](https://vite.dev/guide/static-deploy)
- `webapp/README.md` — l'elenco vivo delle differenze
