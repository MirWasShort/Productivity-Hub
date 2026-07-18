# C28 — CRUD delle liste (V4)

## Cosa è stato fatto

Il quarto vertical slice del backend, sul pattern ormai consolidato:

- **`V4__create_todo_list_table.sql`**: `todo_lists` — name (≤100),
  color `#RRGGBB` opzionale, `position` (in schema per il futuro
  riordino, oggi sempre 0), FK utente con CASCADE.
- **Dominio** `TodoList` (record puro con `createNew`/`update`),
  **port in `TodoListUseCases`** (list/create/update/delete + command),
  **port out**, **`TodoListService`** con lo stesso scoping dei task
  (lista altrui → 404, mai 403), **trio di persistenza**,
  **`ListController`** su `/api/v1/lists` (GET array ordinato per
  position, POST 201, PUT, DELETE 204) con validazione del colore
  (`@Pattern` esadecimale).
- 16 test scritti prima: 5 unit service (incluse le negazioni
  cross-user), 4 IT adapter, 7 slice controller (incluso il colore non
  esadecimale → 400).

## Perché

**Perché un'unica interfaccia `TodoListUseCases` invece di quattro
port?** Deviazione *dichiarata* dal pattern dei task (C09): là i cinque
port separati servivano il valore didattico della ROADMAP; qui sono
CRUD banali con le stesse regole di scoping — quattro interfacce da un
metodo l'una sarebbero cerimonia pura. La regola vera non è "un port
per metodo" ma "il port è il contratto che il chiamante merita": per le
liste il contratto naturale è uno. Saper riconoscere quando il pattern
va applicato e quando alleggerito È il pattern.

**Perché niente paginazione su GET /lists?** Le liste di un utente sono
una manciata per costruzione (è un'organizzazione personale, non un
feed). Paginare avrebbe costi (client più complesso) senza benefici.
La paginazione dei task esiste perché i task crescono senza limite.

**Perché il colore è validato con un `@Pattern` e non un enum?** Gli 8
swatch preset sono una scelta del *client* (C31): il server accetta
qualunque esadecimale valido, così il vincolo UI può evolvere senza
migrazione. Il server valida la *forma* (è un colore?), il client
sceglie la *palette*.

**`position` in schema ma non in API?** Il riordino drag&drop è nel
taglio dichiarato del piano. La colonna costa zero oggi ed evita una
migrazione domani; l'ordinamento `position, createdAt` è già quello che
il riordino userà.

## Come funziona

Nulla di nuovo — ed è il punto: quarto slice sullo stesso stampo
(migrazione → record → port → service → trio JPA → controller → 404
handler già esistente). Il tempo di implementazione crolla quando
l'architettura è ripetibile; i test del controller sono il copia-adatta
dello scaffold di C09 (slice con `SecurityConfig` importata e
`JwtTokenProvider` mockato — le insidie Boot 4 pagate una volta sola).

## Il ciclo TDD in questo commit

1. **Rosso** — 16 test, 82 errori di compilazione.
2. **Verde** — l'intero slice al primo run completo.
3. **Refactor** — `requireOwnList` speculare a `requireOwnTask`: la
   simmetria tra feature è essa stessa manutenibilità.

## Concetti chiave

- **Pattern con giudizio**: il port unico è una scelta, motivata e
  scritta.
- **Vincoli di forma sul server, scelte di palette sul client**.
- **Schema future-proof, API minimale**: `position` c'è, il riordino no.

## Per approfondire

- [Get Your Hands Dirty on Clean Architecture — cap. sulle interfacce dei port]
- ROADMAP: Fase 6, Settimana 26 (Backend — TodoList)
