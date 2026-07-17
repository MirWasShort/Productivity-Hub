# C08 — Login e refresh token con rotazione

## Cosa è stato fatto

- **Migrazione `V2__create_refresh_token_table.sql`**: tabella
  `refresh_tokens` con `token_hash` (SHA-256, UNIQUE), `expires_at`,
  `revoked`, FK verso `users` con `ON DELETE CASCADE`.
- **Dominio `RefreshToken`**: record immutabile con `createNew`, `revoke()`
  (restituisce una copia revocata) e `isUsable()` (né scaduto né revocato).
- **`LoginUseCase` e `RefreshTokenUseCase`** (port in) implementati da
  `AuthService`; `AuthResult` ora include il refresh token, quindi anche
  `register` restituisce la coppia completa.
- **Persistenza**: `RefreshTokenJpaEntity` + repository + adapter per il
  nuovo `RefreshTokenRepositoryPort`.
- **Endpoint**: `POST /api/v1/auth/login` e `POST /api/v1/auth/refresh`;
  handler globale esteso: credenziali/refresh invalidi → 401 con
  `ErrorResponse`.
- Test: `AuthServiceTest` sale a 9 casi (login ok/password errata/email
  sconosciuta; refresh ok con rotazione/sconosciuto/scaduto/revocato),
  nuovo `RefreshTokenPersistenceAdapterIT`, `AuthControllerTest` copre i
  nuovi endpoint.
- Config: **il server ora ascolta su 8081** (`server.port`), perché 8080
  sulla macchina di sviluppo è occupato da un altro container.

## Perché

**Perché due token invece di uno?** L'access token (JWT, 15 minuti) viaggia
su ogni richiesta: se rubato, il danno dura poco. Il refresh token (7
giorni) viaggia *solo* verso `/auth/refresh` e serve a ottenere nuove
coppie senza ri-chiedere la password. Vita breve dove l'esposizione è alta,
vita lunga dove l'esposizione è minima.

**Perché il refresh token è opaco (random) e non un JWT?** Deve poter
essere *revocato*: la revoca richiede uno stato server-side, quindi tanto
vale una stringa random + riga in DB. Il vantaggio del JWT (validazione
senza stato) qui non serve — anzi, sarebbe un rischio: un JWT di 7 giorni
non revocabile è una chiave persa per una settimana.

**Perché in DB c'è solo l'hash SHA-256?** Stesso principio delle password:
se il database viene esfiltrato, l'attaccante trova hash inutilizzabili,
non credenziali pronte. A differenza delle password, qui basta SHA-256
"nudo" (niente BCrypt): il token è già una stringa random a 256 bit di
entropia, non indovinabile per costruzione — il salt e la lentezza servono
contro i dizionari, non contro il caso.

**Perché la rotazione?** A ogni refresh, il token presentato viene revocato
e ne nasce uno nuovo. Se un attaccante ruba un refresh token e lo usa, il
legittimo proprietario al suo prossimo refresh troverà il token già
"bruciato" → 401 → re-login. Il riuso di un token revocato è anche un
segnale di compromissione osservabile nei log. Verificato nello smoke test:
il secondo uso dello stesso refresh token risponde 401.

**Perché `InvalidCredentialsException` non distingue "email inesistente" da
"password sbagliata"?** Per non regalare informazioni: rispondere "email
sconosciuta" permette di enumerare gli utenti registrati. Un unico
messaggio generico per entrambi i casi.

## Come funziona

Login:
```
findByEmail → BCrypt matches → genera access JWT
→ genera 32 byte random (SecureRandom) → Base64 URL-safe = refresh "raw"
→ salva SHA-256(raw) in refresh_tokens → restituisce coppia (il raw non si salva MAI)
```

Refresh:
```
SHA-256(raw ricevuto) → findByTokenHash → isUsable? (né scaduto né revocato)
→ carica l'utente → revoca il token presentato → emette nuova coppia
```
Tutto in `@Transactional`: revoca e nuova emissione o avvengono entrambe o
nessuna.

Smoke test completo eseguito sull'app viva (bootRun + curl): register 201,
login 200 con coppia, `/api/v1/tasks` senza token 401, refresh 200 con
rotazione, riuso del vecchio refresh 401, login errato 401, email
duplicata 409.

## Il ciclo TDD in questo commit

1. **Rosso** — 7 nuovi test di `AuthServiceTest`, l'IT dell'adapter e 4
   test del controller scritti prima: rosso di compilazione.
2. **Verde** — migrazione, dominio, port, adapter, service, endpoint.
3. **Refactor** — `issueTokens` (introdotto in C07) è cresciuto per
   emettere la coppia: `register`, `login` e `refresh` condividono lo
   stesso percorso di emissione senza duplicazione.

## Concetti chiave

- **Access breve + refresh lungo**: minimizzare la finestra di danno.
- **Token opachi revocabili** vs JWT: la revoca richiede stato.
- **Hash dei segreti a riposo**: mai memorizzare credenziali in chiaro.
- **Rotazione**: ogni refresh consuma il token; il riuso è un allarme.
- **User enumeration**: gli errori di auth non devono rivelare cosa esiste.

## Per approfondire

- [OWASP — Session Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html)
- [OAuth 2.0 — Refresh Token Rotation](https://datatracker.ietf.org/doc/html/rfc9700#section-4.14) (best practice RFC 9700)
- [SecureRandom (Java)](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/security/SecureRandom.html)
- ROADMAP: Fase 3, Settimana 15 (Auth Endpoints, refresh token storage) e gli errori da evitare della Fase 3
