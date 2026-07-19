# C44 — Refresh trasparente: una sola promessa per tutti

## Cosa è stato fatto

- **`webapp/src/lib/auth/refresh.ts`**: `ensureFreshToken()` con **promessa
  condivisa** fra le chiamate concorrenti, `isAccessTokenStale()` con margine
  di 30 secondi, e il registro di ascoltatori `onSessionExpired()`.
- **`webapp/src/lib/api/client.ts`**: `apiFetch` ora rinnova il token *prima*
  di partire se è scaduto, e riprova **una volta sola** dopo un 401.
- **`webapp/src/lib/api/config.ts`**: `API_BASE_URL` e `apiUrl()` estratti in
  un modulo comune, perché client e refresh non possono importarsi a vicenda.
- **`webapp/src/lib/auth/refresh.test.ts`**: otto casi, incluso quello dei due
  401 in parallelo.

## Perché

Il backend **ruota** i refresh token: `AuthService.refresh` revoca quello
presentato e ne emette uno nuovo (C08). È una buona difesa — un token rubato
vale un solo uso — ma impone un vincolo preciso al client: **il refresh deve
essere serializzato**.

Lo scenario che rompe tutto è banale e frequentissimo. La pagina dei task
carica in parallelo task, liste e tag; l'access token è appena scaduto; tutte
e tre tornano 401 quasi nello stesso istante. Se ognuna chiama il refresh per
conto proprio:

1. la prima presenta `refresh-1`, il backend lo revoca ed emette `refresh-2`;
2. la seconda presenta ancora `refresh-1`, che ora è revocato → 401;
3. l'utente viene buttato fuori mentre la sua sessione era perfettamente valida.

Nel client Flutter il problema è risolto da `QueuedInterceptor`, che accoda gli
errori e ne processa uno alla volta (C15). Su `fetch` non esiste una coda
pronta, quindi la serializzazione va scritta — ed è tre righe, se si sceglie la
struttura giusta.

Alternative valutate:

- **Un mutex/semaforo esplicito** — scartata: più codice per ottenere lo stesso
  effetto che dà una promessa condivisa, che *è già* una primitiva di
  sincronizzazione.
- **Una coda di richieste in attesa** (come `QueuedInterceptor`) — scartata:
  serializzerebbe anche le richieste normali, non solo il refresh, rallentando
  il caricamento in parallelo senza alcun beneficio.
- **Timer che rinnova ogni 14 minuti** — scartata: non copre il caso del
  computer tornato dalla sospensione, non sa niente delle altre schede, e
  continua a rinnovare token anche quando l'utente non sta usando l'app.

## Come funziona

Il nucleo è una variabile a livello di modulo:

```ts
let inflightRefresh: Promise<Session> | null = null

export function ensureFreshToken(): Promise<Session> {
  inflightRefresh ??= (/* … chiamata di rete … */).finally(() => {
    inflightRefresh = null
  })
  return inflightRefresh
}
```

`??=` assegna **solo se** la variabile è nulla. La prima chiamata fa partire la
richiesta e memorizza la promessa; le successive, finché quella è in volo,
ricevono *la stessa* promessa e si mettono in attesa dietro di essa. Il
`finally` la azzera quando finisce, così il prossimo refresh sarà nuovo. Nessun
lock, nessuna coda: una promessa in JavaScript è già un valore che più
consumatori possono attendere.

Il modulo è a stato globale, e qui è giusto: la condivisione deve valere per
**tutta la scheda**, non per una singola pagina o componente. Il refresh non ha
niente a che vedere con l'albero React.

**Due momenti in cui si rinnova**, non uno:

- *Prima* della richiesta, se `expiresAt` è passato o mancano meno di 30
  secondi. Evita un giro a vuoto quando sappiamo già che il token è morto.
- *Dopo* un 401, perché sapere non basta: l'orologio del client può essere
  sfasato, e il server ha comunque l'ultima parola.

Il margine di 30 secondi copre il tempo di volo della richiesta: un token che
scade fra 5 secondi è "già scaduto" ai fini pratici.

**Un solo tentativo di replay.** Se anche la richiesta ripetuta torna 401, il
problema non è il token (per esempio: la risorsa appartiene a un altro utente,
o il backend ha revocato tutto). Riprovare sarebbe un ciclo infinito
mascherato da resilienza.

**La richiesta di refresh è "nuda"**: la costruisce `fetch` direttamente,
senza passare da `apiFetch`. Se passasse di lì, un 401 sul refresh
innescherebbe un altro refresh, che innescherebbe un altro refresh. È lo stesso
motivo per cui l'interceptor Flutter usa un `Dio` separato senza interceptor.

**La fine della sessione è un evento, non un `throw` e basta.** Quando il
refresh fallisce, `sessionEnded()` cancella lo storage, avvisa gli ascoltatori
e restituisce l'errore. In C45 lo store di autenticazione si registrerà lì per
svuotare la cache e mandare l'utente al login: la logica di rete non ha bisogno
di conoscere il router.

## Il ciclo TDD

Otto test, tutti rossi prima dell'implementazione:

1. su 401 rinnova e ripete, con la sequenza esatta degli header
   (`vecchio-access`, poi nessuno per il refresh, poi `nuovo-access`);
2. salva la coppia **ruotata** — il vecchio refresh token è bruciato;
3. **due 401 in parallelo → un solo refresh, entrambe le richieste ripetute**;
4. refresh fallito → `SessionExpiredError`, storage pulito, ascoltatore avvisato;
5. senza sessione un 401 resta un 401 (nessun refresh da tentare);
6. sulle rotte `/auth/*` non si tenta il refresh;
7. il replay avviene una volta sola: un secondo 401 propaga;
8. token quasi scaduto → rinnovo preventivo, senza aspettare il 401.

Il terzo è il test che giustifica l'intero commit. Trattiene di proposito la
risposta del refresh con una promessa risolta a mano, aspetta che entrambe le
richieste siano arrivate al 401, verifica che le chiamate a `/auth/refresh`
siano **una sola**, poi sblocca e controlla che tutte e due le richieste
originali siano state ripetute con il token nuovo. Senza la promessa condivisa
questo test fallisce con due refresh — cioè con l'utente buttato fuori.

## Concetti chiave

- **Una promessa è già un lock**: condividere la promessa in volo è il modo
  idiomatico di deduplicare un'operazione asincrona in JavaScript.
- **La rotazione dei token è un contratto a due**: il server la implementa, il
  client deve rispettarla, o la sicurezza in più diventa un bug.
- **Chiedere perdono e chiedere permesso**: controllare la scadenza *e*
  gestire il 401 — il primo è ottimizzazione, il secondo è correttezza.
- **Ricorsione mascherata**: qualunque gestore di errori che ripassa dal
  percorso che ha generato l'errore va isolato.
- **Eventi invece di dipendenze**: la rete annuncia "sessione finita", non
  decide cosa mostrare.

## Per approfondire

- [MDN — `Promise` e sincronizzazione](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Promise)
- [MDN — operatore `??=`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Operators/Nullish_coalescing_assignment)
- [OAuth 2.0 — refresh token rotation](https://datatracker.ietf.org/doc/html/rfc9700#name-refresh-token-protection)
- C08 (`C08-login-refresh-rotation.md`) e C15 (`C15-dio-auth-interceptor.md`)
