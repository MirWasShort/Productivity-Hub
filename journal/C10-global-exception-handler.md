# C10 — Global exception handler: un solo formato di errore

## Cosa è stato fatto

- `GlobalExceptionHandlerTest`: 2 test scritti prima — la validazione
  fallita deve restituire 400 con la mappa `fieldErrors` (campo →
  messaggio), e un'eccezione imprevista deve produrre un 500 col body
  standard **senza rivelare dettagli interni**.
- `GlobalExceptionHandler` completato. Mappa finale:

  | Eccezione | HTTP |
  |---|---|
  | `MethodArgumentNotValidException` (Bean Validation) | 400 + `fieldErrors` |
  | `HttpMessageNotReadableException` (JSON malformato/enum invalido) | 400 |
  | `ResourceNotFoundException` | 404 |
  | `EmailAlreadyExistsException` | 409 |
  | `InvalidCredentialsException` / `InvalidRefreshTokenException` | 401 |
  | qualunque altra `Exception` | 500 (loggata server-side) |

  Tutte le risposte usano lo stesso `ErrorResponse {timestamp, status,
  error, message, path, fieldErrors?}` introdotto in C06.

## Perché

**Perché un formato unico?** Il client (il frontend Flutter che arriverà)
deve poter scrivere *un solo* parser di errori. Se il 400 di validazione ha
una forma, il 404 un'altra e il 500 una terza, ogni chiamata diventa un
caso speciale. Il contratto unico è una gentilezza verso chiunque consumi
l'API — inclusa la versione futura di te stesso.

**Perché il 500 dice solo "An unexpected error occurred"?** Lo stack trace
in una risposta HTTP è un regalo agli attaccanti (nomi di classi, versioni,
percorsi) e non aiuta l'utente. Il dettaglio completo va nei **log** — la
riga `log.error(...)` con l'eccezione intera — dove serve a chi fa debug.
Messaggio generico fuori, verità completa dentro.

**Perché serve il handler per `HttpMessageNotReadableException`?**
Scoperto durante il verde: il fallback su `Exception` cattura *tutto*,
anche il JSON malformato che prima Spring gestiva da solo come 400. Senza
il handler dedicato, inviare `"status": "NOT_A_STATUS"` sarebbe diventato
un 500 — sbagliato: è un errore del client, non del server. Regola: quando
aggiungi un fallback generico, controlla cosa stai *togliendo* ai
meccanismi di default (il test dell'enum invalido di C09 lo ha beccato
subito — è esattamente il valore di una suite che cresce a ogni commit).

**Perché `fieldErrors` è una mappa campo → messaggio?** Il frontend può
mostrare ogni errore accanto al suo campo del form invece di un generico
"dati non validi" in cima alla pagina.

## Come funziona

`@RestControllerAdvice` è un aspetto trasversale: intercetta le eccezioni
lanciate da *tutti* i controller. Spring sceglie il metodo `@ExceptionHandler`
più specifico per il tipo lanciato; il fallback su `Exception` scatta solo
se nessun altro matcha. Le eccezioni lanciate *prima* del controller (nella
filter chain di security) non passano di qui — per quelle c'è il
`JsonAuthenticationEntryPoint` di C06, che infatti produce lo stesso
`ErrorResponse`: due meccanismi, un solo contratto.

`MethodArgumentNotValidException` porta con sé il `BindingResult` con tutti
i campi falliti: il handler li travasa nella mappa (primo messaggio per
campo, ordine stabile con `LinkedHashMap`).

## Il ciclo TDD in questo commit

1. **Rosso** — i 2 test del contratto d'errore fallivano: niente
   `fieldErrors` nel 400 (body di default di Spring), e il 500 col
   messaggio dell'eccezione originale.
2. **Verde** — i tre handler nuovi; il test dell'enum invalido di C09 ha
   fatto da rete di sicurezza contro la regressione del fallback.
3. **Refactor** — l'handler consolida quanto nato sparso in C07/C08/C09:
   ora ogni status ha un solo punto di produzione.

## Concetti chiave

- **Error contract**: la forma degli errori è API tanto quanto i dati.
- **Information disclosure**: mai stack trace o messaggi interni al client;
  log dettagliati server-side.
- **Specificità degli handler**: Spring sceglie il più specifico; il
  fallback generico è l'ultima rete, e va aggiunto sapendo cosa intercetta.
- **La suite come rete di sicurezza**: il test di C09 ha impedito una
  regressione introdotta da C10 — i test pagano rate.

## Per approfondire

- [Spring — Exception handling in MVC](https://docs.spring.io/spring-framework/reference/web/webmvc/mvc-controller/ann-exceptionhandler.html)
- [RFC 9457 — Problem Details for HTTP APIs](https://datatracker.ietf.org/doc/html/rfc9457) (lo standard IETF per gli error body; il nostro formato è una variante semplificata)
- [OWASP — Improper Error Handling](https://owasp.org/www-community/Improper_Error_Handling)
- ROADMAP: Fase 2, Settimana 12 (Error Handling & Swagger), kata 2.4 (Exception Handler Kata)
