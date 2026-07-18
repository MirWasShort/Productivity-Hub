# C15 — Dio client e interceptor di refresh automatico

## Cosa è stato fatto

- `core/network/auth_interceptor.dart`: `AuthInterceptor` (estende
  `QueuedInterceptor`) — allega il Bearer token a ogni richiesta; su 401
  tenta il refresh e **rigioca la richiesta fallita**; se il refresh
  fallisce (o non c'è refresh token) pulisce lo storage e segnala la
  scadenza della sessione.
- `core/network/api_client.dart`: `dioProvider` (baseUrl, timeout 10s,
  log in debug) + `sessionExpiredProvider` (un `Notifier<bool>` che il
  router osserverà in C17 per rimandare al login).
- 7 unit test scritti prima, con `Dio` e gli handler mockati via
  mocktail: Bearer allegato/assente, non-401 passa oltre, 401 da endpoint
  `/auth/` non innesca refresh, refresh riuscito (salva coppia + replay
  con nuovo token + `resolve`), refresh fallito (clear + expiry),
  refresh token mancante (idem, senza nemmeno chiamare il server).

## Perché

**Perché un interceptor e non "gestisco il 401 in ogni chiamata"?**
L'access token scade ogni 15 minuti *per progetto* (C05). Senza
interceptor, ogni repository dovrebbe implementare "se 401 → refresh →
riprova" — decine di duplicazioni del pezzo più delicato del client.
L'interceptor lo fa in un punto solo, e il resto dell'app vive
nell'illusione che i token non scadano mai.

**Perché `QueuedInterceptor`?** Scenario reale: la schermata parte e fa 3
richieste insieme; il token è appena scaduto; tutte e tre prendono 401.
Con un interceptor normale partirebbero 3 refresh concorrenti — e con la
rotazione di C08 il secondo e il terzo *fallirebbero* (il token è già
ruotato!), buttando fuori l'utente. `QueuedInterceptor` serializza: il
primo 401 fa il refresh, gli altri aspettano e ripartono col token nuovo.
Concorrenza risolta per costruzione, non con un mutex a mano.

**Perché il refresh usa un Dio separato e "nudo"?** Se la chiamata di
refresh passasse dal client intercettato e ricevesse 401, l'interceptor
intercetterebbe *anche quella*... e tenterebbe un refresh, che fallirebbe
con 401, che... ricorsione infinita. Il `refreshClient` senza interceptor
spezza il cerchio. Per lo stesso motivo i 401 provenienti da path
`/auth/` non innescano il refresh: "password sbagliata" al login non
significa "sessione scaduta".

**Perché `onSessionExpired` è un callback e non un riferimento al
router/notifier?** Il core network non deve conoscere la UI. Il callback
inverte la dipendenza: l'interceptor segnala, chi lo costruisce
(`dioProvider`) decide cosa significa — oggi flippare
`sessionExpiredProvider`, domani qualsiasi altra cosa.

## Come funziona

Il ciclo di vita di una richiesta con token scaduto:

```
GET /tasks (Bearer vecchio) ──> 401
  └─ onError: non è /auth/, c'è un refresh token
       └─ POST /auth/refresh (Dio nudo) ──> 200 {nuova coppia}
            └─ saveTokens + replay GET /tasks (Bearer nuovo) ──> 200
                 └─ handler.resolve(risposta)   ← il chiamante originale
                                                  riceve il 200, ignaro di tutto
```

`handler.resolve(response)` è la magia finale: trasforma quello che era
un errore in una risposta riuscita per il codice chiamante.

Nei test, `Dio`, `RequestInterceptorHandler` e `ErrorInterceptorHandler`
sono mockati: si testa la *logica* dell'interceptor (cosa chiama, con che
argomenti, in che casi) senza rete né server. `registerFallbackValue` è
il rito mocktail per i matcher su tipi non primitivi.

Chicca Dart moderna emersa dal linter: i **private named parameters**
(`required this._tokenStorage`) — il campo resta privato, il chiamante
usa `tokenStorage:`; niente più boilerplate `: _x = x`.

## Il ciclo TDD in questo commit

1. **Rosso** — 7 test che descrivono l'intera macchina a stati
   dell'interceptor, prima che esistesse.
2. **Verde** — implementazione + fix Riverpod 3 (`StateProvider` è
   legacy: sostituito con un `Notifier<bool>` — API attuale).
3. **Refactor** — la coppia clear+callback estratta in `_expireSession`;
   lint del linter applicati (initializing formals).

## Concetti chiave

- **Cross-cutting concern**: l'auth HTTP vive in un interceptor, non
  sparsa nelle chiamate.
- **Serializzazione della concorrenza**: `QueuedInterceptor` contro i
  refresh multipli (letale con la rotazione).
- **Ricorsione da interceptor**: il client che si auto-intercetta è il
  bug classico; il client nudo per il refresh è l'antidoto.
- **Inversione di dipendenza**: il core segnala eventi via callback, non
  conosce chi reagisce.

## Per approfondire

- [Dio — Interceptors e QueuedInterceptor](https://pub.dev/packages/dio#interceptors)
- [Riverpod 3 — Notifier](https://riverpod.dev/docs/providers/notifier_provider) (e perché StateProvider è legacy)
- [Dart — private named parameters](https://dart.dev/language/constructors#initializing-formal-parameters)
- ROADMAP: Fase 5, Settimana 21 (Dio Setup & interceptor con auto-refresh), kata 5.1 (Dio Interceptor Kata)
