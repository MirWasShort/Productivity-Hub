# C34 — Endpoint analytics (V8 completed_at)

## Cosa è stato fatto

- **`V8__add_completed_at_to_task.sql`**: colonna `completed_at` + backfill
  dei DONE esistenti con `updated_at` come proxy.
- **Dominio**: `Task` guadagna `completedAt`; `update` lo **timbra**
  entrando in DONE e lo **azzera** uscendone (un task già DONE mantiene
  l'istante originale). Logica pura, unit-testata prima.
- **Port**: `GetAnalyticsUseCase` (summary, completions) e
  `AnalyticsQueryPort` (record framework-free `AnalyticsSummary`,
  `DailyCount`); `AnalyticsService`; **`AnalyticsPersistenceAdapter`** con
  query aggregate via `EntityManager`; `AnalyticsController`
  (`/api/v1/analytics/summary` e `/completions?days=N`).
- Test: 2 unit di dominio (transizione DONE), IT sull'adapter (totali,
  completati, overdue, per priorità, completamenti/giorno, tutti scoped),
  slice controller.

## Perché

**Perché `completedAt` nel dominio e non calcolato al volo?** "Completati
questa settimana" ha bisogno di sapere *quando* un task è diventato DONE.
`updated_at` non basta: cambia a ogni modifica. Serve un timestamp
dedicato, e la regola di quando timbrarlo/azzerarlo è **logica di
dominio** (transizione di stato), non SQL. Metterla nel record `Task.update`
la rende unit-testabile senza database — i due test di transizione girano
in millisecondi. La ROADMAP lo chiede esplicitamente (Fase 8).

**Perché il backfill nella migrazione?** I task già DONE prima di questa
colonna non hanno un istante di completamento. Impostarlo a `updated_at`
è un'approssimazione onesta (l'ultima modifica di un DONE *probabilmente*
è stata il completamento). Meglio un dato approssimato ma presente che
un buco che falserebbe i grafici storici. È una scelta documentata nel
commento SQL.

**Perché `EntityManager` e non query derivate di Spring Data?** Gli
aggregati (`group by status`, `count where overdue`, completamenti per
giorno) non si esprimono bene con i metodi derivati. Le query JPQL/native
esplicite sono più leggibili di un nome di metodo lungo trenta parole. Il
raggruppamento per giorno usa una **query nativa** (`completed_at::date`)
perché il troncamento a giorno-calendario è specifico di Postgres — ed è
proprio il tipo di cosa per cui la query nativa esiste.

**La definizione di overdue, di nuovo unica.** `dueDate < now AND status
!= DONE`: la stessa identica formula del raggruppamento frontend (C27).
Un utente che vede "3 in ritardo" nella dashboard e "3 in ritardo" nella
lista deve vedere gli stessi 3. Una regola, due implementazioni che
combaciano per costruzione.

## Come funziona

- `summary` esegue conteggi mirati (total, completed, overdue, dueToday)
  + due `group by` (status, priority) inizializzati a zero per tutte le
  costanti, così la mappa è completa anche se una categoria è vuota.
- `completionsSince` restituisce righe sparse (solo i giorni con
  completamenti); il service calcola `from`/`to`, il client (C35)
  riempie di zeri i giorni mancanti.
- Insidia risolta: Hibernate 7 può restituire la colonna `date` come
  `java.sql.Date` *o* `java.time.LocalDate` a seconda del driver — il
  `toLocalDate` gestisce entrambi invece di assumere un tipo (un cast
  rigido ha fatto fallire l'IT al primo giro).

## Il ciclo TDD in questo commit

Rosso (2 unit di dominio + IT + slice) → verde con V8, dominio, port,
adapter, controller; una iterazione sul tipo della data nativa.

## Concetti chiave

- **Timestamp di dominio**: quando succede qualcosa è un fatto di
  business, timbrato dalla transizione di stato.
- **Backfill onesto**: un dato approssimato ma presente batte un buco.
- **Query native dove servono**: il giorno-calendario è specifico del DB.
- **Una regola, implementazioni che combaciano**: overdue identico tra
  dashboard e lista.

## Per approfondire

- [Jakarta Persistence — aggregate & group by queries](https://jakarta.ee/specifications/persistence/3.1/)
- [PostgreSQL — date/time functions](https://www.postgresql.org/docs/current/functions-datetime.html)
- [Flyway — data migrations (backfill)](https://documentation.red-gate.com/fd)
- ROADMAP: Fase 8, Settimana 37 (Analytics Dashboard — backend)
