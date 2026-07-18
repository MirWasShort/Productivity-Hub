# C11 — OpenAPI/Swagger e CORS per il frontend web

## Cosa è stato fatto

- `CorsAndOpenApiIT`: 3 test prima del codice — la preflight `OPTIONS` da
  `http://localhost:5555` deve ricevere gli header CORS, la stessa da
  un'origine sconosciuta deve essere rifiutata (403), e `/v3/api-docs`
  deve essere pubblico.
- `CorsConfig`: bean `CorsConfigurationSource` con
  `allowedOriginPatterns("http://localhost:*")`, metodi CRUD+OPTIONS,
  tutti gli header, cache preflight 1h, **niente credenziali** (il token
  viaggia nell'header `Authorization`, non nei cookie).
- `OpenApiConfig`: documento OpenAPI con security scheme `bearer JWT` —
  in Swagger UI compare il pulsante **Authorize** dove incollare l'access
  token per provare gli endpoint protetti dal browser.

## Perché

**Cos'è il CORS e perché ci serve?** I browser applicano la Same-Origin
Policy: una pagina servita da `http://localhost:5555` (l'app Flutter web
in sviluppo) non può chiamare `http://localhost:8081` (l'API) a meno che
*il server* non dichiari esplicitamente di fidarsi di quell'origine. Lo fa
rispondendo alla richiesta *preflight* (`OPTIONS`) con header
`Access-Control-Allow-*`. Senza questa configurazione il frontend web
vedrebbe solo un opaco errore di rete — il CORS fallito **non arriva mai
al codice applicativo**, muore nel browser.

**Perché `allowedOriginPatterns` e non `allowedOrigins("*")`?** Il
wildcard totale spalanca l'API a qualunque sito. Il pattern
`http://localhost:*` limita alle origini di sviluppo locale (qualunque
porta, comodo perché Flutter web ne sceglie una a caso se non specificata).
In produzione si sostituirebbe col dominio reale del frontend. Il test
dell'origine "evil.example.com" → 403 documenta il confine.

**Perché niente `allowCredentials`?** Serve solo se l'auth viaggia in
cookie. La nostra viaggia nell'header `Authorization`, che il client
allega esplicitamente: superficie CSRF nulla e configurazione CORS più
semplice (con credenziali, il wildcard sarebbe vietato dallo standard).

**Perché Swagger?** Documentazione *viva*: generata dal codice, sempre
allineata agli endpoint reali, e interattiva — chiunque cloni il repo può
esplorare l'API da `/swagger-ui.html` senza leggere una riga di codice.
springdoc genera tutto dagli endpoint e dai DTO; l'unica configurazione
manuale è lo schema bearer per poter testare gli endpoint autenticati.

## Come funziona

La preflight: prima di una richiesta "non semplice" (POST con JSON, o
qualunque richiesta con `Authorization`), il browser invia da solo
`OPTIONS /api/v1/tasks` con `Origin` e `Access-Control-Request-Method`.
Il `CorsFilter` di Spring (attivato dal nostro bean via `http.cors()` in
`SecurityConfig`, C06) risponde con gli header di permesso e la richiesta
vera parte solo dopo. Per questo la `SecurityFilterChain` permette le
OPTIONS senza autenticazione: la preflight non porta mai il token.

`maxAge(3600)`: il browser può cachare il permesso per un'ora invece di
ripetere la preflight a ogni chiamata.

## Il ciclo TDD in questo commit

1. **Rosso** — senza `CorsConfigurationSource`, `http.cors(withDefaults())`
   non ha nulla da applicare: la preflight legittima falliva (403 anche
   per localhost).
2. **Verde** — i due bean di configurazione.
3. **Refactor** — niente da estrarre; il valore era rendere *testato* ciò
   che di solito si configura alla cieca e si debugga in produzione.

## Concetti chiave

- **Same-Origin Policy / CORS**: è il server a dichiarare di chi si fida;
  il browser fa rispettare la dichiarazione.
- **Preflight OPTIONS**: la richiesta-permesso automatica del browser; va
  permessa nella security chain.
- **CORS ≠ sicurezza dell'API**: protegge gli *utenti* dal cross-site
  scripting, non l'API da client ostili (curl ignora il CORS). L'API è
  protetta dal JWT.
- **Documentazione generata**: la doc che non può mentire perché nasce dal
  codice.

## Per approfondire

- [MDN — CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) (la spiegazione di riferimento)
- [Spring — CORS support](https://docs.spring.io/spring-framework/reference/web/webmvc-cors.html)
- [springdoc-openapi](https://springdoc.org/)
- [OpenAPI Specification](https://swagger.io/specification/)
- ROADMAP: Fase 2, Settimana 12 (Swagger) e Fase 3, Settimana 16 (Swagger + Bearer)
