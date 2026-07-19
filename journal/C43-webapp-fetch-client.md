# C43 — Client HTTP, errori tipizzati e sessione su localStorage

## Cosa è stato fatto

- **`webapp/src/lib/api/client.ts`**: `apiFetch()`, punto d'ingresso unico
  verso il backend. Compone l'URL sotto `/api/v1`, serializza i parametri di
  query saltando quelli non valorizzati, manda e riceve JSON, allega
  `Authorization: Bearer` quando c'è una sessione, gestisce il 204 senza corpo.
  Diviso in `buildRequest` / `sendRequest` / `apiFetch`.
- **`webapp/src/lib/api/errors.ts`**: `ApiError` (stato, corpo, `fieldErrors`,
  `isUnauthorized` / `isNotFound` / `isConflict`), `NetworkError`,
  `SessionExpiredError`.
- **`webapp/src/lib/auth/token-storage.ts`**: lettura, scrittura e cancellazione
  della sessione in `localStorage`, con parsing difensivo e
  `onSessionChangedElsewhere()` per accorgersi di login/logout in altre schede.
- Test: 10 casi sul client, 6 sullo storage.

## Perché

**`fetch` invece di axios.** L'unico vero motivo per portarsi axios sarebbe
avere gli interceptor. Ma l'interceptor che ci serve — 401 → refresh → replay,
con i refresh concorrenti serializzati — è talmente specifico che andrebbe
comunque scritto a mano dentro axios (è quello che fa `auth_interceptor.dart`
con `QueuedInterceptor` in Flutter). Scriverlo sopra `fetch` costa le stesse
righe, senza una dipendenza in mezzo e senza dover capire in quale fase del
ciclo di vita di axios si sta operando.

**Errori come classi, non come stringhe.** Il backend risponde sempre con lo
stesso `ErrorResponse`, `fieldErrors` compreso. Estrarlo una volta sola qui
significa che le schermate non parlano mai di HTTP: un form guarda
`error.fieldErrors`, una pagina guarda `error.isNotFound`. È la traduzione che
in Flutter fa `Failure.fromDio` (C14).

`NetworkError` è separato da `ApiError` per una ragione pratica: "il server ha
risposto 500" e "il server non ha risposto" richiedono messaggi diversi e
politiche di retry diverse. `fetch` li confonde entrambi in un `TypeError`, e
distinguerli dopo è impossibile.

**localStorage, con il compromesso dichiarato.** Il backend non ha cookie di
sessione (`allowCredentials` è false, non esiste `/auth/logout`), quindi il
token dev'essere leggibile da JavaScript. La contropartita è nota: un XSS lo
ruberebbe. Le alternative valutate:

- **`sessionStorage`** — scartata: la sessione morirebbe a ogni scheda chiusa,
  peggiorando l'esperienza senza risolvere l'XSS (è ugualmente leggibile da JS).
- **Solo in memoria** — scartata: un refresh della pagina obbligherebbe a
  rifare il login, dato che non c'è un cookie di refresh da cui ripartire.
- **Cookie httpOnly** — la soluzione giusta, ma richiede modifiche al backend
  (CORS con credenziali, endpoint di logout, protezione CSRF). Annotata come
  intervento futuro; oggi sarebbe un cambio di contratto per un solo client.

## Come funziona

**Perché `Request` invece di `fetch(url, init)`.** `buildRequest` costruisce un
oggetto `Request` completo e `sendRequest` lo esegue. Costa una riga in più e
dà due cose: i test possono ispezionare URL e header dell'oggetto reale invece
di frugare negli argomenti passati al mock, e soprattutto in C44 il replay
dopo il refresh potrà **riusare la stessa richiesta** cambiandone solo
l'header, invece di ricostruirla da capo dai parametri originali.

**`url.searchParams` invece di concatenare stringhe**: gestisce da solo
l'encoding (una ricerca con `&` o uno spazio non rompe la query) e il caso
"nessun parametro" (niente `?` penzolante). Il filtro `value != null` è la
traduzione diretta della convenzione del `TaskFilter` Flutter, dove `null`
significa "questa dimensione non è filtrata".

**`response.clone()` prima di leggere il corpo di errore**: il body di una
`Response` è uno stream leggibile **una volta sola**. Senza il clone, un
tentativo fallito di `json()` consumerebbe lo stream e renderebbe impossibile
qualunque lettura successiva. Con il clone, se il corpo non è JSON (una pagina
HTML di un proxy, un 502 del gateway) si ripiega su un messaggio generico
invece di lanciare un errore di parsing che nasconderebbe quello vero.

**Il parsing difensivo della sessione.** `readSession()` non si limita a
`JSON.parse`: verifica che i quattro campi attesi ci siano. Il contenuto di
`localStorage` è dati esterni — può venire da una versione precedente
dell'app, da un'altra scheda, o da qualcuno che ci ha messo le mani. Un
`JSON.parse` che esplode all'avvio significa schermata bianca; qui una
sessione illeggibile equivale semplicemente a "non sei loggato".

**L'evento `storage`** scatta solo nelle *altre* schede, mai in quella che ha
scritto. È esattamente ciò che serve per allineare le schede aperte: chi fa
logout in una vedrà le altre reagire, e il listener ignora le chiavi che non
sono la nostra (per esempio `ph.theme`).

## Il ciclo TDD

1. **Rosso** — `token-storage.test.ts`: sessione assente, andata e ritorno,
   cancellazione, JSON corrotto, oggetto con i campi sbagliati, evento
   `storage` (che deve scattare due volte e ignorare le altre chiavi).
2. **Verde** — `token-storage.ts`.
3. **Rosso** — `client.test.ts`: composizione dell'URL, parametri saltati,
   token allegato e non allegato, corpo JSON, 204 vuoto, `ApiError` con
   `fieldErrors`, corpo di errore illeggibile, rete assente, codici 401/404/409.
4. **Verde** — `errors.ts` e `client.ts`.

I test montano un `fetch` finto con `vi.stubGlobal` e ispezionano l'oggetto
`Request` che il client ha costruito. Nessun server, nessuna rete: quello che
si sta verificando è la **traduzione** fra intenzione ("prendi i task da fare")
e protocollo, che è la parte dove si annidano i bug.

## Concetti chiave

- **Un solo punto d'ingresso verso la rete**: se ce n'è uno, ci si può
  agganciare (refresh, log, retry) una volta sola.
- **Il body di una Response si legge una volta**: `clone()` prima di provarci.
- **Errori di trasporto ≠ errori applicativi**: vanno distinti alla fonte,
  dopo non si può più.
- **I dati persistiti sono input non fidato**, anche quando li ha scritti la
  tua stessa app.
- **Un compromesso dichiarato non è un errore**: localStorage qui è una scelta
  motivata dal contratto del backend, scritta insieme alle sue conseguenze.

## Per approfondire

- [MDN — Fetch API e oggetti `Request`](https://developer.mozilla.org/docs/Web/API/Fetch_API)
- [MDN — evento `storage`](https://developer.mozilla.org/docs/Web/API/Window/storage_event)
- [OWASP — dove tenere i token JWT](https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html#local-storage)
- C14 (`C14-core-failures-storage.md`) e C15 (`C15-dio-auth-interceptor.md`)
