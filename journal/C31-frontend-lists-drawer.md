# C31 — Feature liste: drawer e CRUD dal frontend

## Cosa è stato fatto

- **Feature `features/list/`** speculare a task: entità `TodoList`,
  `ListRepository`, modello freezed `TodoListModel`, datasource,
  `ListRepositoryImpl`, `TodoListsNotifier` (`AsyncNotifier<List<TodoList>>`
  con create/rename/delete).
- **Drawer** (`AppDrawer` in `core/widgets/`): "Tutte le attività" +
  le liste dell'utente (pallino colorato, `Key('drawer_list_<id>')`),
  ognuna che imposta `taskFilterProvider.listId`; voce "Nuova lista"
  (dialog con **8 swatch preset**, no color picker), toggle tema, logout.
  Il titolo dell'appbar della lista task riflette la lista attiva.
- **Estensione di `Task`**: entità e `TaskModel` guadagnano `listId` e
  `List<Tag> tags` (nasce anche la `Tag` entity + `TagModel`, usate qui e
  nella feature tag di C32); datasource/repository/notifier inviano
  `listId`/`tagIds` in create e update. Codegen rigenerato.
- 9 test nuovi (repo, notifier, drawer: mostra liste, selezione imposta
  il filtro, dialog crea) + adattamento di tutti i call-site di
  create/update ai nuovi parametri.

## Perché

**Perché il drawer sulla schermata task e non sulla shell?** Flutter ha
un attrito noto con `Scaffold.drawer` dentro una `StatefulShellRoute`: il
Drawer starebbe sullo Scaffold *esterno*, ma l'`AppBar` delle tab è su
Scaffold *interni* — l'hamburger non troverebbe il drawer. Invece di
combattere il framework, ho messo il drawer dove serve davvero: la tab
Task, l'unica che filtra per lista. Calendario e dashboard non ne hanno
bisogno. La soluzione più semplice che rispetta il vincolo è spesso
quella giusta.

**Perché la lista selezionata vive in `TaskFilter.listId` e non in un
provider a parte?** Filtrare per lista *è* un filtro. Metterlo nel
`TaskFilter` (C26) significa che il meccanismo di reload automatico è già
lì: selezioni una lista dal drawer → `setListId` → `TaskListNotifier`
si ricarica da solo, esattamente come per una chip di stato. Un provider
separato avrebbe duplicato quel cablaggio. Unica fonte di verità per
"cosa sto guardando".

**Perché 8 swatch e non un color picker libero?** Taglio dichiarato del
piano. Un picker HSV è tanto codice per un valore che nessuno regola con
precisione: 8 colori distinti coprono l'organizzazione personale e danno
un risultato *coerente* (nessuna lista beige illeggibile scelta per
sbaglio). Il server accetta qualunque esadecimale (C28), quindi il
vincolo resta solo lato UI e può allargarsi senza toccare il backend.

**La cascata di modifiche ai test (istruttiva).** Estendere `Task` con
`listId`/`tags` ha rotto ~6 test: il round-trip del modello (nuovi campi
nel JSON), e ogni stub di `create`/`update` (firme allargate). È il
costo di un cambio di contratto trasversale — e la ragione per cui i
test *vanno tenuti verdi a ogni commit*: la cascata è gestibile quando
è di un commit, ingestibile quando si accumula. Una trappola incontrata:
`List` in Dart usa uguaglianza per identità, quindi negli stub mocktail
`tagIds: const <String>[]` va scritto *const* per combaciare col default
canonico — un `[]` non-const non matcherebbe.

## Come funziona

- `TodoListsNotifier` aggiorna lo stato per sostituzione immutabile (come
  `TaskListNotifier`): create aggiunge in coda, delete filtra via.
- Il drawer usa `AsyncValue.when` sulle liste: loading/error/data gestiti,
  come ogni schermata che carica da rete.
- L'entità `Tag` ha `==`/`hashCode` strutturali: servirà in C32 per le
  `FilterChip` multi-select (selezione = confronto per valore).

## Il ciclo TDD in questo commit

Rosso (feature list + estensione Task) → verde con codegen → refactor:
il drawer estratto come `AppDrawer` pubblico, riusabile, invece che
inline nella schermata.

## Concetti chiave

- **La soluzione che rispetta il framework**: drawer dove i nested
  Scaffold non danno guerra.
- **Un filtro è un filtro**: la lista selezionata sta nel `TaskFilter`,
  non in un provider gemello.
- **Cambio di contratto trasversale**: i test verdi rendono la cascata
  gestibile un commit alla volta.
- **Vincoli UI vs vincoli server**: gli 8 swatch sono una scelta del
  client, il server resta permissivo.

## Per approfondire

- [Flutter — nested navigation e Scaffold](https://docs.flutter.dev/ui/navigation)
- [Material 3 — Navigation drawer](https://m3.material.io/components/navigation-drawer/overview)
- ROADMAP: Fase 6, Settimana 28 (Frontend — Lists & Tags UI)
