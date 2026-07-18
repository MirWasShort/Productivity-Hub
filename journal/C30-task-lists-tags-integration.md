# C30 — Task in lista, tag sui task e filtri list/tag (V6, V7)

## Cosa è stato fatto

Il punto in cui liste e tag *entrano* nel task:

- **`V6__create_task_tag_table.sql`**: tabella di giunzione `task_tags`
  (PK composita `task_id, tag_id`, entrambe FK `ON DELETE CASCADE`).
- **`V7__add_list_id_to_task.sql`**: colonna `list_id` sui task, FK
  `ON DELETE SET NULL` + indice.
- Dominio: `Task` guadagna `listId` e `List<Tag> tags` (record con
  copia difensiva dei tag, factory `withListAndTags`).
- `TaskJpaEntity`: `@ManyToMany @JoinTable("task_tags")` verso i tag +
  colonna `list_id`; `TaskMapper` traduce nei due sensi.
- `TaskService`: create/update ora **validano la proprietà** di lista e
  tag referenziati — un tag o una lista di un altro utente → 404 (stessa
  regola dei task). `TaskSpecifications` estesa con filtro per `listId`
  (equality) e `tagId` (join su `tags` + `distinct`).
- DTO e controller: `listId` e `tagIds` in create/update,
  `listId`+`tags:[{id,name,color}]` nella response, param `listId`/`tagId`
  sulla list.
- **`hibernate.default_batch_fetch_size: 50`** in `application.yml`.
- Test estesi: service (risoluzione tag posseduti, tag/lista altrui →
  404), IT (salva/ricarica tag, filtro per tag e per lista), e i comandi
  aggiornati ovunque.

## Perché

**Perché `ON DELETE SET NULL` per la lista ma `CASCADE` per i tag?**
Sono relazioni di natura diversa. Cancellare una lista *non* deve
cancellare i suoi task: sono cose reali da fare, che sopravvivono
"senza lista" (il test manuale del blocco lo verifica). Cancellare un
tag invece deve solo togliere l'*associazione* (le righe di `task_tags`),
non il task — ed è ciò che fa `CASCADE` sulla giunzione. La semantica
del dominio si traduce direttamente nella clausola SQL.

**Perché la validazione di ownership su tag e lista?** Senza, un utente
malizioso potrebbe assegnare al proprio task la lista di un altro (o un
tag altrui) passandone l'UUID — un IDOR (Insecure Direct Object
Reference). Il service risolve ogni id *scoped per utente*: un id non
tuo semplicemente non si trova → 404. È lo stesso principio dello
scoping dei task (C09), esteso alle referenze.

**Il rischio N+1, evitato con giudizio.** Caricare una pagina di 20 task
con i loro tag può generare 1 query per la pagina + 20 per i tag (uno
per task): il classico N+1. La tentazione è un fetch-join
(`JOIN FETCH tags`), ma con una query **paginata** Hibernate non può
paginare in SQL una join che moltiplica le righe — ripiega sulla
paginazione *in memoria* (warning `HHH90003004`), caricando l'intera
tabella. La soluzione giusta è `default_batch_fetch_size: 50`: Hibernate
carica le collezioni di tag della pagina in **una** query
`WHERE task_id IN (...)`. 1+1 invece di 1+N, e la paginazione resta in
SQL. La ROADMAP avverte esplicitamente di questo (Fase 6, "N+1 queries").

**Perché il filtro per tag ha bisogno di `distinct`?** La join su una
relazione to-many duplica le righe del task se combaciasse più di un tag.
`criteriaQuery.distinct(true)` collassa i doppioni. Attivato solo quando
il filtro tag è presente, per non pagarne il costo altrimenti.

## Come funziona

- I tag nel task non sono *creati* dal mapper: le righe esistono già (via
  gli endpoint tag di C29), la giunzione ci punta soltanto. Il mapper
  costruisce riferimenti per id — inserire tag da qui creerebbe
  doppioni.
- L'ordine delle migrazioni conta: V6 può creare `task_tags` solo dopo
  che `tasks` (V3) e `tags` (V5) esistono; V7 aggiunge `list_id` dopo
  `todo_lists` (V4). La numerazione Flyway le sequenzia; su DB pulito
  V1→V7 applicano in ordine (verificato dagli IT Testcontainers).

## Il ciclo TDD in questo commit

Rosso (comandi e firme cambiati ovunque, tanti errori di compilazione) →
verde: migrazioni, dominio esteso, entity `@ManyToMany`, mapper,
validazione ownership, specification, DTO, batch fetch. Suite intera
verde al primo run completo dopo il cablaggio.

## Concetti chiave

- **La semantica del dominio nella clausola FK**: SET NULL vs CASCADE
  non è una preferenza, è cosa significa cancellare.
- **IDOR difeso per costruzione**: ogni referenza si risolve scoped.
- **N+1 con paginazione**: mai fetch-join; `batch_fetch_size` è la via.
- **Migrazioni ordinate**: le dipendenze tra tabelle dettano i numeri V.

## Per approfondire

- [Vlad Mihalcea — The best way to fix Hibernate MultipleBagFetchException / N+1](https://vladmihalcea.com/hibernate-multiplebagfetchexception/)
- [Hibernate — batch fetching](https://docs.jboss.org/hibernate/orm/current/userguide/html_single/Hibernate_User_Guide.html#fetching-batch)
- [OWASP — IDOR](https://owasp.org/www-community/attacks/Insecure_Direct_Object_Reference)
- [PostgreSQL — ON DELETE actions](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-FK)
- ROADMAP: Fase 6, Settimane 26-27 (many-to-many, filtri), kata 6.2 (Many-to-Many Kata)
