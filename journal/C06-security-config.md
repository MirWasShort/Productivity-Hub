# C06 — Spring Security: filter chain stateless con JWT

## Cosa è stato fatto

- `SecurityConfigIT`: 4 test d'integrazione scritti prima — `/health`
  pubblico, route protetta senza token → 401 **con body JSON standard**,
  token invalido → 401, token valido → supera l'autenticazione (404 perché
  il controller non esiste ancora: la richiesta è *passata*).
- `SecurityConfig`: la `SecurityFilterChain` — CSRF disabilitato, CORS
  abilitato, sessioni STATELESS, `permitAll` su `/api/v1/auth/**`,
  `/health`, actuator health, Swagger e le richieste OPTIONS; tutto il
  resto autenticato. Bean `BCryptPasswordEncoder`.
- `JwtAuthenticationFilter` (`OncePerRequestFilter`): estrae il Bearer
  token, lo valida col `JwtTokenProvider` di C05, popola il
  `SecurityContext` con lo userId.
- `JsonAuthenticationEntryPoint`: rimpiazza il 401 vuoto di default con il
  body `ErrorResponse {timestamp, status, error, message, path}` — nato qui
  il DTO che il global exception handler riutilizzerà (C10).

## Perché

**Perché CSRF disabilitato?** Il CSRF sfrutta i cookie di sessione inviati
automaticamente dal browser. Questa API non usa cookie né sessioni: il
token viaggia nell'header `Authorization`, che il browser non allega mai da
solo. La protezione CSRF qui non protegge nulla e romperebbe ogni POST.

**Perché sessioni STATELESS?** Coerenza con la scelta JWT (C05): nessuno
stato server-side per utente. Ogni richiesta si ri-autentica con il token.
Scalare orizzontalmente diventa banale: qualunque istanza può servire
qualunque richiesta.

**Perché il filtro non blocca mai la richiesta?** `JwtAuthenticationFilter`
fa solo: estrai → valida → popola il contesto. Se il token manca o è
invalido, *non* risponde 401 direttamente — lascia proseguire la richiesta
senza autenticazione, e saranno le regole di `authorizeHttpRequests` a
rifiutarla. Così la decisione di autorizzazione sta in un posto solo (la
chain), e il filtro resta banale. La ROADMAP lo dice esplicitamente:
"Making the JWT filter too complex" è un errore classico.

**Perché un AuthenticationEntryPoint custom?** Il default di Spring
Security risponde 401 con body vuoto. Il frontend (e chiunque usi l'API)
merita lo stesso formato di errore delle altre risposte: JSON con
timestamp, status, message e path.

**Perché BCrypt?** È un hash *lento per progetto* (cost factor
configurabile): rende il brute-force costoso. Genera e incorpora un salt
per ogni hash, quindi due utenti con la stessa password hanno hash diversi.
Mai MD5/SHA per le password: sono progettati per essere veloci — l'opposto
di ciò che serve.

## Come funziona

Una richiesta con `Authorization: Bearer <token>` attraversa:

1. La **filter chain** di Spring Security. Il nostro filtro è inserito
   prima di `UsernamePasswordAuthenticationFilter`.
2. `JwtAuthenticationFilter` valida il token e mette
   `UsernamePasswordAuthenticationToken(userId, ...)` nel
   `SecurityContextHolder` (un ThreadLocal legato alla richiesta).
3. L'authorization layer consulta le regole: `/api/v1/tasks` richiede
   `authenticated()` — c'è un'authentication nel contesto? Sì → prosegue
   verso il controller. No → `JsonAuthenticationEntryPoint` → 401 JSON.

Nei controller, lo userId autenticato si recupererà dal principal (C09).

**Insidia di Boot 4 incontrata sul serio**: due rotture reali durante il
verde —
- il bean `ObjectMapper` non è più quello di Jackson 2
  (`com.fasterxml.jackson`): Boot 4 usa **Jackson 3** (`tools.jackson`).
  L'import sbagliato produce `NoSuchBeanDefinitionException`.
- `@WebMvcTest` include nella slice anche i bean `Filter`: il
  `HealthControllerTest` di C03 si è rotto perché la slice ora prova a
  costruire `JwtAuthenticationFilter` senza avere `JwtTokenProvider`. Fix:
  `@MockitoBean JwtTokenProvider` nella slice (in Boot 4 `@MockBean` non
  esiste più, sostituito da `@MockitoBean` di spring-test).

Questo è il motivo per cui la ROADMAP avverte (Fase 3, settimana 13): "all
your existing tests will break — fix them". È successo esattamente questo.

## Il ciclo TDD in questo commit

1. **Rosso** — `SecurityConfigIT` contro la security di default: 3 test su
   4 falliscono (`/health` bloccato, 401 senza body JSON).
2. **Verde** — SecurityConfig + filtro + entry point; più i due fix Boot 4
   sopra. Suite completa: 16 test verdi.
3. **Refactor** — l'`ErrorResponse` è stato messo subito in
   `adapter/in/web/dto` (non nel package security): è il formato di errore
   di *tutta* l'API, la security ne è solo il primo utente.

## Concetti chiave

- **Filter chain**: la sicurezza di Spring è una catena di filtri servlet;
  capire l'ordine è capire Spring Security.
- **Autenticazione vs autorizzazione**: il filtro *autentica* (chi sei),
  le regole della chain *autorizzano* (cosa puoi fare).
- **Stateless**: niente sessioni server-side; il token è l'unica prova.
- **BCrypt**: hash lento + salt automatico = lo standard per le password.

## Per approfondire

- [Spring Security — Architecture](https://docs.spring.io/spring-security/reference/servlet/architecture.html) (la filter chain spiegata)
- [Spring Security — JWT/Resource server](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/jwt.html)
- [OWASP — Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html) (perché BCrypt)
- [OWASP — CSRF](https://owasp.org/www-community/attacks/csrf) (e perché non si applica alle API Bearer)
- ROADMAP: Fase 3, Settimana 13 (Spring Security Fundamentals), kata 3.1 e 3.3
