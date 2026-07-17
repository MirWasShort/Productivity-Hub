# C05 — JwtTokenProvider: generare e validare i token

## Cosa è stato fatto

- `JwtTokenProviderTest`: 5 unit test scritti prima dell'implementazione —
  round-trip (genera → valida → estrai userId), token scaduto rifiutato,
  firma manomessa rifiutata, token firmato con un'altra chiave rifiutato,
  input spazzatura rifiutato.
- `JwtProperties`: record `@ConfigurationProperties(prefix = "app.jwt")` che
  lega `secret`, `access-token-ttl`, `refresh-token-ttl` da
  `application.yml` (Spring converte "15m"/"7d" in `Duration` da solo).
  Abilitato con `@ConfigurationPropertiesScan` sull'application class.
- `JwtTokenProvider`: genera access token firmati HMAC-SHA256 e li valida,
  con la libreria **jjwt 0.13**.

## Perché

**Cos'è un JWT e perché lo usiamo?** Un JSON Web Token è composto da tre
parti Base64: `header.payload.firma`. Il payload contiene i *claims* (chi
sei: `sub` = userId, quando scade: `exp`); la firma è un HMAC del contenuto
con il segreto del server. Chiunque può *leggere* un JWT (non è cifrato!),
ma solo chi ha il segreto può *produrne* uno valido. Il server quindi non
deve tenere sessioni in memoria: la validità è verificabile dal token
stesso — è questo che rende l'API *stateless* e scalabile orizzontalmente.

**Perché il provider è una classe nostra e non "usiamo Spring Security e
basta"?** Spring Security gestisce il *filtro* delle richieste (C06), ma la
generazione/validazione del token è logica nostra. Isolarla in una classe
con costruttore esplicito (`new JwtTokenProvider(properties)`) la rende
testabile con unit test puri: niente contesto Spring, i 5 test girano in
millisecondi.

**Perché il test del token scaduto usa un TTL negativo?** Per testare la
scadenza senza `Thread.sleep()`: un provider costruito con TTL -5 minuti
genera token già scaduti. I test che dormono sono lenti e fragili; i test
che controllano il tempo sono deterministici.

**Perché il segreto deve essere ≥ 32 byte?** HMAC-SHA256 richiede una
chiave di almeno 256 bit; jjwt lancia `WeakKeyException` se è più corta —
meglio un crash all'avvio che una firma debole in produzione.

## Come funziona

API jjwt 0.13 (attenzione: molti tutorial in rete mostrano l'API 0.9/0.11,
che non compila più):

```java
// generazione
Jwts.builder()
    .subject(userId.toString())        // claim "sub"
    .claim("email", email)
    .issuedAt(...)                     // claim "iat"
    .expiration(...)                   // claim "exp"
    .signWith(key)                     // HMAC-SHA256 con SecretKey
    .compact();

// validazione + parsing
Jwts.parser().verifyWith(key).build()
    .parseSignedClaims(token)          // lancia JwtException se invalido/scaduto
    .getPayload();
```

`validateToken` traduce le eccezioni in `boolean`: il chiamante (il filtro
di sicurezza) non deve conoscere la tassonomia delle `JwtException`.

La chiave nasce con `Keys.hmacShaKeyFor(secret.getBytes(UTF_8))` — una
`SecretKey` costruita una sola volta nel costruttore, non a ogni richiesta.

## Il ciclo TDD in questo commit

1. **Rosso** — i 5 test non compilano (`JwtProperties` e `JwtTokenProvider`
   non esistono).
2. **Verde** — implementazione minima: builder jjwt, parser, catch delle
   eccezioni. Tutti e 5 passano al primo run.
3. **Refactor** — il parsing è stato estratto nel privato `parseClaims`
   per non duplicarlo tra `validateToken` ed `extractUserId`.

## Concetti chiave

- **JWT = leggibile ma non falsificabile**: mai metterci dati sensibili;
  la firma garantisce integrità, non riservatezza.
- **Stateless auth**: il server non memorizza sessioni; il token porta con
  sé le prove.
- **@ConfigurationProperties + record**: configurazione tipizzata e
  immutabile invece di `@Value` sparsi.
- **Controllare il tempo nei test**: TTL negativo > `Thread.sleep`.

## Per approfondire

- [jwt.io](https://jwt.io) — decodifica un token e guarda dentro (kata 3.2 della ROADMAP)
- [RFC 7519 — JSON Web Token](https://datatracker.ietf.org/doc/html/rfc7519)
- [jjwt README](https://github.com/jwtk/jjwt) — l'API 0.12+ documentata
- [Spring Boot — Type-safe Configuration Properties](https://docs.spring.io/spring-boot/reference/features/external-config.html#features.external-config.typesafe-configuration-properties)
- ROADMAP: Fase 3, Settimana 14 (JWT Implementation), kata 3.2 (JWT Playground)
