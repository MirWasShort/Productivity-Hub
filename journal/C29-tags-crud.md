# C29 — CRUD dei tag (V5): unicità case-insensitive

## Cosa è stato fatto

- **`V5__create_tag_table.sql`**: `tags` (name ≤50, color hex opzionale)
  con **`UNIQUE INDEX (user_id, lower(name))`** — "Urgente" e "urgente"
  sono lo stesso tag, per decreto del database.
- Slice completo sul solito stampo: record `Tag`, `TagUseCases`,
  `TagRepositoryPort` (con `existsByUserIdAndName` case-insensitive),
  `TagService`, trio JPA (query JPQL `lower(name) = lower(:name)`),
  `TagController` su `/api/v1/tags`.
- `TagAlreadyExistsException` → **409** nel handler globale (che ora
  gestisce i conflitti come categoria: email e tag duplicati insieme).
- 13 test scritti prima, tra cui: duplicato respinto al create E al
  rename (ma rinominare un tag cambiandone solo il *case* è permesso —
  il check si salta se il nome nuovo è lo stesso ignorando il case), e
  l'IT che dimostra il vincolo **a livello database** (due insert
  concorrenti sfuggite al check applicativo → `DataIntegrityViolation`).

## Perché

**Perché l'unicità è case-insensitive?** Un utente che ha "Lavoro" e
digita "lavoro" non vuole un secondo tag: vuole quello che ha già. La
distinzione per maiuscole produrrebbe tag-doppioni che inquinano filtri
e statistiche. L'indice funzionale `lower(name)` fa rispettare la regola
dove nessuna race condition può aggirarla — è C04 (difesa in profondità)
applicato a un vincolo *funzionale*, non su colonna semplice.

**Perché il rename controlla il duplicato solo se il nome cambia
davvero?** `update("Casa" → "CASA")` non è una collisione: è lo stesso
tag che cambia veste. Senza il check `equalsIgnoreCase`, rinominare un
tag correggendone il case verrebbe respinto *dal suo stesso nome* — un
falso positivo classico dei vincoli di unicità.

**Perché 409 e non 400?** Il body è ben formato e valido: è lo *stato*
del sistema a confliggere con la richiesta. Conflict è il codice
semanticamente giusto, e il frontend può reagire in modo specifico
("questo tag esiste già") invece che con un generico errore di form.

## Come funziona

L'indice funzionale: Postgres indicizza il *risultato* di `lower(name)`,
non la colonna — il vincolo di unicità vale sull'espressione. La query
di esistenza usa la stessa espressione, quindi sfrutta l'indice. Nota:
`existsBy...IgnoreCase` derivato da Spring Data esiste, ma la JPQL
esplicita documenta l'allineamento con l'indice.

## Il ciclo TDD in questo commit

Rosso (13 test) → verde al primo run completo → refactor: il handler dei
conflitti generalizzato invece di duplicato. Quinto slice sullo stampo:
la velocità è il dividendo dell'architettura ripetibile.

## Concetti chiave

- **Vincoli funzionali**: unique su `lower(name)`, non sulla colonna.
- **Falso positivo da self-collision**: il rename che cambia solo il
  case non è un duplicato.
- **409 = conflitto di stato**, 400 = richiesta malformata.

## Per approfondire

- [PostgreSQL — Indexes on Expressions](https://www.postgresql.org/docs/current/indexes-expressional.html)
- [RFC 9110 — 409 Conflict](https://httpwg.org/specs/rfc9110.html#status.409)
- ROADMAP: Fase 6, Settimana 26 (Backend — Tags)
