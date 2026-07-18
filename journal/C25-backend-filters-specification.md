# C25 — Filtri, ricerca e ordinamento con JPA Specification

## Cosa è stato fatto

- **`TaskQuery`** (record nel port `ListTasksUseCase`): i criteri di
  ricerca — status, priority, search, dueBefore/dueAfter, listId/tagId
  (riservati per la feature liste/tag), sortBy + direction — con enum
  **propri** (`TaskSortField`, `SortDirection`) e metodi "wither" per
  componere query nei test. Il port out diventa
  `search(userId, query, page, size)`.
- **`TaskSpecifications`** (adapter): traduce `TaskQuery` in una
  `Specification<TaskJpaEntity>` — predicati combinati in AND sopra il
  vincolo `userId`, ricerca case-insensitive su titolo *e* descrizione
  con **escape dei wildcard** (`%`, `_`, `\`), range di scadenza, e
  l'ORDER BY costruito **dentro** `toPredicate`.
- `TaskJpaRepository` estende `JpaSpecificationExecutor`; l'adapter passa
  un `PageRequest` volutamente non ordinato.
- Controller: 7 nuovi `@RequestParam` opzionali; enum invalido → 400 (nuovo
  handler per `MethodArgumentTypeMismatchException` — senza, il fallback
  di C10 lo avrebbe trasformato in 500).
- 12 test scritti prima: unit (la query attraversa il port), 9 IT
  (ogni filtro, combinazioni, escape, sort semantici), 2 slice web
  (binding completo con `ArgumentCaptor`, 400 su sortBy sconosciuto).

## Perché

**Perché un record criteri e non `Specification` nel port?** La regola
di C07 non si negozia: il layer application non importa Spring. Il port
parla `TaskQuery` (dominio puro); `Specification` esiste solo
nell'adapter. Domani un adapter Mongo tradurrebbe la stessa `TaskQuery`
in un filtro Mongo — il service non se ne accorgerebbe.

**Perché l'ORDER BY sta nella Specification e non nel `Pageable`?** Il
sort per priorità è il motivo: la colonna memorizza i *nomi* dell'enum
(scelta di C09, giusta per la robustezza), quindi `ORDER BY priority`
darebbe l'ordine alfabetico — HIGH < LOW < MEDIUM, un nonsenso
semantico. Serve un `CASE WHEN` che assegni i rank (HIGH=3, MEDIUM=2,
LOW=1), e il `Sort` del Pageable non sa esprimerlo. Il test
`should_sortPrioritySemantically` inchioda proprio "Alta, Media, Bassa".
Stesso discorso per `NULLS LAST` sulle scadenze: i task senza data
affondano in fondo, sempre.

**Perché l'escape dei wildcard nella ricerca?** Senza, cercare "100%"
troverebbe anche "100 euro": `%` è un jolly SQL. Peggio: un utente
potrebbe sondare i dati con pattern (`_` matcha un carattere qualunque).
`escapeLike` neutralizza `%`, `_` e `\` prima del `LIKE ... ESCAPE '\'`.
Piccolo dettaglio, classica fonte di bug-e-sorprese in produzione.

**La trappola del count query.** Spring Data esegue *due* query per una
pagina: quella dei dati e quella del conteggio totale. Un ORDER BY sulla
count query è illegale/inutile: la Specification lo aggiunge solo quando
`getResultType() != Long.class`. Senza quel check, metà dei test IT
sarebbe esplosa con errori criptici.

## Come funziona

- `Specification` è il pattern *composite* per i predicati JPA: ogni
  filtro attivo aggiunge un `Predicate`, `cb.and(...)` li combina. I
  filtri assenti semplicemente non producono predicati — una query con
  zero filtri degrada al solo scope utente.
- La ricerca: `lower(title) LIKE '%term%' OR lower(coalesce(description,
  '')) LIKE '%term%'` — il `coalesce` evita che il confronto con NULL
  mangi la riga.
- Contratto HTTP: `GET /api/v1/tasks?status=TODO&priority=HIGH&search=
  spesa&dueBefore=...&sortBy=DUE_DATE&direction=ASC` — tutti opzionali e
  combinabili; il binding degli enum è fatto da Spring, l'errore di
  binding ora è un 400 col nome del parametro sbagliato.
- Tie-breaker stabile: qualunque sort si chiude con `createdAt DESC` —
  a parità di chiave l'ordine non balla tra una richiesta e l'altra.

## Il ciclo TDD in questo commit

1. **Rosso** — 12 test sulla nuova firma e sui comportamenti (compile
   error sul port inesistente).
2. **Verde** — port + specification + adapter + controller + handler;
   due iterazioni sui generics di `selectCase` (l'API Criteria ha
   un'inferenza di tipo capricciosa: serviva il type witness esplicito
   `<TaskPriority, Integer>`).
3. **Refactor** — i "wither" su `TaskQuery` sono nati per leggibilità
   dei test e sono rimasti come API di composizione.

## Concetti chiave

- **Criteri nel dominio, traduzione nell'adapter**: il filtro è un
  concetto di business, la Specification un dettaglio JPA.
- **Sort semantico ≠ sort naturale**: gli enum-as-string ordinano
  alfabeticamente; il rank esplicito è il rimedio.
- **Escape dei LIKE**: l'input dell'utente non è mai un pattern.
- **La count query è una query diversa**: ciò che vale per i dati non
  vale per il conteggio.

## Per approfondire

- [Spring Data JPA — Specifications](https://docs.spring.io/spring-data/jpa/reference/jpa/specifications.html)
- [Jakarta Persistence — Criteria API](https://jakarta.ee/specifications/persistence/3.1/jakarta-persistence-spec-3.1#a6925)
- [OWASP — SQL Wildcard injection](https://owasp.org/www-community/attacks/SQL_Injection) (il cugino dei LIKE non escapati)
- ROADMAP: Fase 6, Settimana 27 (Backend — Filtering & Search), kata 6.1 (JPA Specification Kata)
