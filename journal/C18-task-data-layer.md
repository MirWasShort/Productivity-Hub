# C18 — Task data layer

## Cosa è stato fatto

La feature task ricalca la struttura di C16, consolidando il pattern:

- **Domain**: entità `Task` con `copyWith` scritto a mano e gli enum
  `TaskStatus`/`TaskPriority` (nomi Dart `inProgress`, non i nomi wire);
  interfaccia `TaskRepository` (list/getById/create/update/delete).
- **Data**: `TaskModel` freezed speculare al `TaskResponse` del backend,
  con la mappatura esplicita enum ↔ stringa wire (`IN_PROGRESS` ↔
  `TaskStatus.inProgress`) via `@JsonKey(fromJson/toJson)`;
  `TaskRemoteDataSource` (le 5 chiamate, la list legge `items` dalla
  `PageResponse`); `TaskRepositoryImpl` con il guard-rail unico
  `DioException → Failure`.
- 10 test scritti prima: round-trip JSON (inclusi `null` su description
  e dueDate), mapping a entità, tutte le operazioni del repository con
  datasource mockato, traduzione errori (500 → `ServerFailure`, 404 →
  `NotFoundFailure`).

## Perché

**Perché la mappatura enum è esplicita e non affidata ai nomi?**
json_serializable saprebbe serializzare gli enum da solo, ma userebbe i
nomi Dart (`inProgress`) mentre il backend parla `IN_PROGRESS`. La mappa
esplicita rende il contratto *visibile e testato*: se il backend
aggiungesse uno stato, il `firstWhere` fallirebbe rumorosamente nel test
di round-trip, non silenziosamente in produzione.

**Perché `update(Task)` prende l'entità intera mentre `create` prende i
campi?** Alla creazione il task non esiste: non c'è entità da passare,
solo i dati di partenza. All'update l'entità esiste e il pattern è
"prendi il task, `copyWith` delle modifiche, passalo al repository" — la
UI di C20 farà esattamente questo. Ogni firma racconta il proprio caso
d'uso.

**Perché la paginazione qui è congelata (`page=0&size=50`)?** Taglio
dichiarato del piano: il backend la supporta (C09, testata), ma la UI
con infinite scroll è fuori scope. Il repository restituisce "la lista"
e nasconde la pagina: quando servirà la paginazione vera, cambierà solo
questo layer — la firma `list()` del boundary può evolversi senza toccare
le schermate.

**Perché `_guard`?** Cinque metodi, la stessa gestione errori. In C16
erano due chiamate e il template method era `_authenticate`; qui la
versione generica `Future<T> _guard<T>(...)` elimina cinque try/catch
identici. Stesso refactoring, un gradino più astratto.

## Come funziona

- Le date attraversano il confine come stringhe ISO-8601 UTC
  (`toUtc().toIso8601String()` in uscita, `DateTime.parse` in entrata,
  gestito da json_serializable). Il backend usa `Instant` (C09): UTC da
  entrambe le parti, niente ambiguità di fuso.
- La list del datasource smonta la `PageResponse` del backend
  (`data['items']`) e restituisce già `List<TaskModel>`: la forma della
  paginazione non risale oltre il datasource.
- `copyWith` sull'entità: i campi non passati restano invariati — è il
  meccanismo con cui la UI esprimerà "questo task, ma DONE".

## Il ciclo TDD in questo commit

1. **Rosso** — 10 test su classi inesistenti.
2. **Verde** — entità, modello (+codegen), datasource, repository al
   primo run completo.
3. **Refactor** — il guard-rail generico `_guard<T>`.

## Concetti chiave

- **Contratto wire esplicito**: le stringhe dell'API sono un dettaglio
  del layer data, mappato e testato.
- **Firme che raccontano il caso d'uso**: create ≠ update.
- **Tagli visibili nel layer giusto**: la paginazione congelata vive nel
  repository, non sparsa nelle schermate.
- **UTC ovunque**: le date attraversano i confini solo in ISO-8601 UTC.

## Per approfondire

- [json_serializable — JsonKey e custom converters](https://pub.dev/packages/json_serializable#custom-types-and-custom-encoding)
- [Effective Dart — Design](https://dart.dev/effective-dart/design) (firme e naming)
- ROADMAP: Fase 5, Settimana 23 (Task CRUD — Data Layer)
