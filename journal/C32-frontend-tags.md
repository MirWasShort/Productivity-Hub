# C32 — Tag: gestione, multi-select nell'editor e filtro

## Cosa è stato fatto

- **Feature `features/tag/`**: `TagRepository`/impl, datasource,
  `TagsNotifier` (`AsyncNotifier<List<Tag>>`), e la
  **`TagManagementScreen`** (rotta `/tags`, dal drawer) — elenco tag con
  eliminazione e FAB per crearne (dialog riusato dalla feature liste).
- **Editor task**: sezione tag con `FilterChip` multi-select
  (`Key('task_tags')`, `task_tag_<id>`) pre-selezionata dai tag del task;
  aggiunto anche un **dropdown lista** (`task_list`), così i task
  entrano davvero in una lista. Al salvataggio partono `listId` e
  `tagIds`.
- **Card**: mini-chip colorati per i tag del task.
- **Filtro per tag**: `TaskFilter` guadagna `tagId`; nella filter bar una
  `FilterChip` per ogni tag (`filter_tag_<id>`) che filtra la lista; il
  datasource invia `tagId`.
- 8+ test nuovi (repo, notifier, management screen, chip nell'editor che
  invia il tag selezionato), tutti scritti prima.

## Perché

**Perché il dropdown lista nell'editor, se il piano lo elencava tra i
"forse"?** Senza, le liste sarebbero decorative: il drawer filtra per
lista ma nessun task potrebbe *entrarci*. Un dropdown è 15 righe e rende
la feature liste completa end-to-end. A volte un piccolo pezzo mancante
rende inutile un blocco intero: vale la pena aggiungerlo.

**Perché il filtro tag è single-select (un tag alla volta)?** Taglio
dichiarato: il multi-tag (task con TUTTI questi tag) richiede logica di
intersezione lato server e UI più complessa. Un tag alla volta copre il
caso d'uso dominante ("mostrami gli urgenti") con una chip che si
accende. Coerente con status/priority, anch'essi single-select.

**Perché la management screen riusa il dialog delle liste?** Tag e liste
hanno la stessa forma (nome + colore da 8 swatch). `ListEditorDialog`
restituisce `(name, color)`: riusarlo per i tag evita un secondo dialog
gemello. Il nome del tipo (`ListEditorResult`) è un po' improprio per i
tag, ma la duplicazione sarebbe peggio della lieve imprecisione
semantica — annotata nel codice.

**La lezione della viewport nei test.** Aggiungere dropdown lista + tag
selector ha allungato la form: il pulsante Salva è finito sotto il fondo
schermo nel test, e `tap` "would not hit test". Dopo tentativi con
`ensureVisible`/`dragUntilVisible` (fragili), la soluzione pulita è stata
allargare la *viewport* di test (`tester.view.physicalSize = 1000x2400`)
così tutto entra senza scroll. Regola: quando un widget test litiga con
lo scroll, spesso è più onesto dare al test uno schermo grande che
simulare gesti di scorrimento fragili.

## Come funziona

- L'editor legge `tagsProvider`/`todoListsProvider` con `ref.watch`: le
  chip e il dropdown si popolano da soli quando i dati arrivano. La
  selezione tag è un `Set<String>` locale (stato del form), convertito in
  `tagIds`/`tags` al salvataggio.
- Il filtro tag passa da `TaskFilter.tagId` → datasource → param `tagId`
  → la Specification di C30 (join su `tags` + distinct). Filtro
  server-side, come tutti gli altri.
- La card mostra i tag come contenitori colorati (colore dal tag,
  leggibile in dark grazie all'alpha bassa) — coerenti coi badge
  priorità.

## Il ciclo TDD in questo commit

Rosso (feature tag + integrazioni) → verde con l'aggiunta degli override
dei provider tag/lista nei test dell'editor e della filter bar (nuove
dipendenze da mockare) → refactor: la viewport alta al posto dei gesti di
scroll.

## Concetti chiave

- **Completare il blocco, non solo il commit**: il dropdown lista rende
  utili le liste di C31.
- **Riuso pragmatico con nota**: un dialog per liste e tag, l'imprecisione
  semantica documentata batte la duplicazione.
- **Viewport grande nei test**: più onesto dei gesti di scroll fragili.
- **Ogni filtro passa dal server**: anche il tag.

## Per approfondire

- [Material 3 — Filter chips (multi-select)](https://m3.material.io/components/chips/guidelines#filter-chips)
- [flutter_test — controlling the test viewport](https://api.flutter.dev/flutter/flutter_test/TestFlutterView-class.html)
- ROADMAP: Fase 6, Settimane 28-29 (Tags UI, filtro per tag)
