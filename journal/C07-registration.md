# C07 — Registrazione utente: il primo use case completo

## Cosa è stato fatto

Il primo flusso verticale completo (HTTP → use case → dominio → DB):

- **Port in** `RegisterUseCase` con il suo `RegisterCommand` — l'interfaccia
  che il mondo esterno usa per invocare l'applicazione — e il risultato
  `AuthResult` (accessToken, scadenza, utente).
- **Due nuovi port out**: `PasswordHasherPort` (hash/verifica password) e
  `AccessTokenPort` (emissione access token). Adapter:
  `BCryptPasswordHasherAdapter` (avvolge il `PasswordEncoder` di Spring) e
  `JwtTokenProvider` che ora *implementa* `AccessTokenPort`.
- **`AuthService`** (layer application): controlla l'unicità dell'email,
  hasha la password, salva l'utente, emette il token.
- **`AuthController`**: `POST /api/v1/auth/register` → 201 con
  `AuthResponse {accessToken, expiresIn, user}`; DTO `RegisterRequest`
  validato con Bean Validation (`@Email`, password ≥ 8 caratteri).
- **`GlobalExceptionHandler`** (prima versione): traduce
  `EmailAlreadyExistsException` in 409 con l'`ErrorResponse` standard.
- Test: 2 unit test su `AuthService` (mock dei port) + 4 test
  `@WebMvcTest` sul controller (201, 400×2, 409).

Nota: in questo commit `register` restituisce **solo l'access token** — il
refresh token arriva nel prossimo commit insieme alla sua tabella. Meglio
un contratto piccolo e vero che un campo `refreshToken: null`.

## Perché

**Perché `PasswordHasherPort` invece di usare `PasswordEncoder` di Spring
direttamente nel service?** Il layer application non deve importare Spring
Security. Sembra pignoleria, ma è ciò che rende `AuthServiceTest` un unit
test *puro*: due mock, zero contesto Spring, esecuzione in millisecondi.
La regola pratica dell'esagonale: *le dipendenze puntano sempre verso il
centro* (adapter → application → domain, mai il contrario).

**Perché il command object (`RegisterCommand`) invece di passare il DTO
del controller al service?** Il DTO web (`RegisterRequest`, con le
annotazioni di validazione HTTP) appartiene all'adapter; il command
appartiene al port. Se domani arrivasse un adapter CLI o gRPC, costruirebbe
lo stesso command senza sapere nulla di JSON o Bean Validation.

**Perché il check `existsByEmail` se c'è già il vincolo UNIQUE (C04)?**
Il check dà un errore *semantico* (409 "email già registrata"); il vincolo
DB resta la garanzia contro le race condition. Due livelli, due scopi.

**Perché la validazione della password sta nel DTO e non nel dominio?**
Lunghezza minima è una regola d'ingresso (interfaccia), non un'invariante
di dominio — il dominio riceve una password *già hashata*. Regole più
ricche (complessità, blacklist) andrebbero in un value object; per ora
`@Size(min = 8)` è la soglia pragmatica.

## Come funziona

Il viaggio di una `POST /api/v1/auth/register`:

1. Spring MVC deserializza il JSON in `RegisterRequest` e applica le
   annotazioni di validazione (`@Valid`): se fallisce → 400 automatico,
   il controller non viene mai chiamato.
2. Il controller costruisce il `RegisterCommand` e invoca il port
   `RegisterUseCase` (che a runtime è `AuthService` — l'unico che sa
   quale implementazione c'è dietro è il container Spring).
3. `AuthService`: `existsByEmail` → `hash` → `User.createNew` → `save` →
   `generateAccessToken`. Tutto dentro `@Transactional`: se qualcosa
   esplode dopo la save, rollback.
4. Il controller traduce `AuthResult` in `AuthResponse` (DTO out) — le
   entity/oggetti di dominio non escono mai dall'API.

Nel test del controller, `@MockitoBean RegisterUseCase` sostituisce il
service vero: il test verifica *solo* il contratto HTTP (status, shape del
JSON, validazione), non la logica — quella è già coperta dagli unit test
del service. È il test pyramid in azione: tanti unit veloci, slice web per
i contratti, pochi integration test completi (arriveranno in C12).

## Il ciclo TDD in questo commit

1. **Rosso** — `AuthServiceTest` (2 test) e `AuthControllerTest` (4 test)
   scritti prima: nessuna delle classi esisteva, compilazione rossa.
2. **Verde** — port, service, adapter, controller, handler: 22 test verdi
   in totale nella suite.
3. **Refactor** — l'emissione del token è stata estratta nel privato
   `issueTokens(user)`: C08 la estenderà con il refresh token senza toccare
   `register`.

## Concetti chiave

- **Use case driven**: ogni operazione di business è un port in con il suo
  command — l'API dell'applicazione, indipendente da HTTP.
- **La regola delle dipendenze**: adapter → application → domain. Mai
  invertire.
- **DTO ≠ command ≠ dominio**: tre rappresentazioni, tre responsabilità
  (contratto HTTP / richiesta d'applicazione / invariante di business).
- **Test pyramid**: la logica si testa nel service (unit), il contratto
  nel controller (slice), il tutto-insieme negli IT (pochi).

## Per approfondire

- [Bean Validation (Jakarta)](https://beanvalidation.org/) e [Spring Validation](https://docs.spring.io/spring-framework/reference/core/validation/beanvalidation.html)
- [Get Your Hands Dirty on Clean Architecture — cap. "Implementing a Use Case"]
- [Martin Fowler — TestPyramid](https://martinfowler.com/bliki/TestPyramid.html)
- [Mockito](https://site.mockito.org/) — `mock`, `when`, `verify`, `ArgumentCaptor`
- ROADMAP: Fase 3, Settimana 15 (Auth Endpoints), kata 2.2 (Validation Kata)
