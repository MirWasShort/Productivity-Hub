# C04 — Dominio User e persistenza con Flyway

## Cosa è stato fatto

- **Prima migrazione Flyway**: `V1__create_user_table.sql` — tabella `users`
  con `id UUID PK`, `email UNIQUE`, `password_hash`, `display_name`,
  timestamp di audit.
- **Modello di dominio** `domain/model/User.java`: un `record` Java puro,
  zero import Spring/JPA, con factory `User.createNew(...)` che genera UUID
  e timestamp.
- **Port out** `application/port/out/UserRepositoryPort.java`: l'interfaccia
  che dice *cosa* serve all'applicazione (save, findByEmail, findById,
  existsByEmail) in termini di dominio.
- **Adapter di persistenza** in `adapter/out/persistence/`:
  `UserJpaEntity` (la classe annotata JPA), `UserJpaRepository` (Spring
  Data), `UserMapper` (dominio ↔ entity), `UserPersistenceAdapter`
  (implementa il port usando i tre precedenti).
- **Test d'integrazione** `UserPersistenceAdapterIT`: 5 test che passano
  per il port contro un PostgreSQL vero (Testcontainers), inclusa la
  violazione del vincolo UNIQUE sull'email.

## Perché

**Perché User esiste due volte (record di dominio + UserJpaEntity)?** È la
separazione centrale dell'esagonale. Il dominio non deve sapere che esiste
un database: niente annotazioni `@Entity`, niente costruttore vuoto imposto
da JPA, niente campi mutabili per far contento Hibernate. Il prezzo è un
mapper di 15 righe; il guadagno è che la logica di business si testa senza
Spring e il database si può cambiare senza toccare il dominio. La ROADMAP
elenca "usare le entity JPA ovunque" tra gli errori classici (Fase 2).

**Perché l'UUID lo genera l'applicazione e non il database?** Con
`User.createNew()` l'oggetto è completo *prima* di essere salvato: niente
"id nullo finché non fai save", niente round-trip per conoscere la chiave.
Con gli UUID (a differenza delle sequenze) non serve il DB per garantire
l'unicità.

**Perché il vincolo UNIQUE sta nel database e non solo nel codice?** Il
controllo applicativo ("esiste già questa email?") è soggetto a race
condition: due richieste simultanee passano entrambe il check. Il vincolo
nel DB è l'ultima linea di difesa che non può essere aggirata. Il codice
farà comunque il check per dare un errore gentile (C07), ma la garanzia
vera è del database.

**Perché il test lavora sul port e non sul repository Spring Data?**
Testare `UserPersistenceAdapter` attraverso `UserRepositoryPort` verifica
il contratto che il resto dell'applicazione userà davvero — mapper incluso.
Testare `UserJpaRepository` direttamente testerebbe Spring Data, che non è
codice nostro.

## Come funziona

- `@DataJpaTest` è uno slice test: carica solo JPA (entity, repository,
  transazioni), non i controller né i service. Ogni test gira in una
  transazione che viene **rollbackata** a fine test: i test non si sporcano
  a vicenda.
- Con `@Import(TestcontainersConfiguration.class)` il datasource dello slice
  punta al container PostgreSQL (via `@ServiceConnection`); all'avvio del
  contesto Flyway esegue `V1__create_user_table.sql` sul container. Il test
  della migrazione è quindi *implicito ma reale*: se l'SQL fosse rotto, ogni
  test qui fallirebbe.
- Il test del vincolo UNIQUE chiama `jpaRepository.flush()`: Hibernate
  ritarda le INSERT fino al flush/commit, quindi senza flush la violazione
  non emergerebbe dentro il test.
- Convenzione Flyway: `V<numero>__<descrizione>.sql`. Una migrazione
  eseguita è **immutabile** — mai modificarla, se ne crea una nuova
  (Flyway ne registra il checksum e rifiuta di ripartire se cambia).

## Il ciclo TDD in questo commit

1. **Rosso** — scritto `UserPersistenceAdapterIT`; la compilazione fallisce:
   non esistono né `User`, né il port, né l'adapter (e
   `TestcontainersConfiguration` era package-private: resa pubblica).
2. **Verde** — migrazione V1 + record di dominio + port + entity + mapper +
   adapter. Tutti e 5 i test passano al primo run completo.
3. **Refactor** — la conversione dominio↔entity è stata isolata da subito
   in `UserMapper` invece di spargerla nell'adapter.

## Concetti chiave

- **Port & Adapter**: il port (interfaccia, layer application) dichiara il
  bisogno; l'adapter (layer adapter) lo soddisfa con una tecnologia concreta.
- **Dominio framework-free**: i record Java sono perfetti per modelli
  immutabili senza dipendenze.
- **Slice test con rollback automatico**: `@DataJpaTest` = veloce, isolato,
  ripetibile.
- **Difesa in profondità sui vincoli**: il check applicativo dà errori
  gentili, il vincolo DB dà la garanzia.

## Per approfondire

- [Get Your Hands Dirty on Clean Architecture — Tom Hombergs] (il riferimento per hexagonal in Spring)
- [Spring Data JPA reference](https://docs.spring.io/spring-data/jpa/reference/)
- [Flyway naming & versioning](https://documentation.red-gate.com/fd/migrations-184127470.html)
- [JPA entity requirements](https://jakarta.ee/specifications/persistence/) (perché serve il costruttore no-arg)
- ROADMAP: Fase 1, Settimana 7 (Flyway & First Entity) e Settimana 8 (Hexagonal Architecture Setup), kata 2.1 (Mapper Kata)
