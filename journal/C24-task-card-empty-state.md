# C24 — Task card, empty state e il restyle che non rompe i test

## Cosa è stato fatto

- **`features/task/presentation/widgets/task_card.dart`**: la riga della
  lista è ora una **card M3 outlined** — checkbox circolare, titolo con
  strikethrough se DONE, descrizione a una riga, riga scadenza con icona
  (solo se presente), badge priorità colorato dalla `ThemeExtension` di
  C22. `InkWell` con ripple raccordato al raggio della card.
- **`core/widgets/empty_state.dart`**: empty state riusabile — icona in
  un cerchio di `primaryContainer`, titolo, sottotitolo. Nessun asset
  immagine: composizione di elementi del tema, dark-mode gratis.
- La lista usa i widget nuovi: sfondo del `Dismissible` diventato un
  contenitore `errorContainer` raccordato (non più il rettangolo rosso
  pieno), padding di lista con spazio per il FAB.
- 4 test scritti prima su `TaskCard` (titolo/descrizione/label priorità,
  riga scadenza presente/assente, strikethrough su DONE).

## Perché

**Perché una card e non il `ListTile`?** Il `ListTile` è ottimo per
elenchi di navigazione; per contenuto con 3-4 attributi eterogenei
(stato, titolo, scadenza, priorità) la card dà controllo tipografico e
gerarchia visiva: il titolo domina, i metadati si fanno piccoli, il
badge priorità è un accento e non un pulsante. L'outlined senza
elevazione è il registro M3 per liste dense — le ombre su 50 righe sono
rumore.

**Il vincolo vero del commit: 72 test verdi, di cui 68 preesistenti.**
Un restyle che rompe i test è un refactoring fallito. La disciplina:
ogni `Key` esistente (`tasks_empty`, `tasks_fab`, `quick_add_*`,
`ValueKey(task.id)` sul Dismissible) è migrata sul widget nuovo. I test
trovano per Key e comportamento, non per struttura: per questo la
sostituzione `ListTile`→`TaskCard` è stata indolore. È il motivo per cui
in C17-C19 si erano scelte Key stabili invece di `find.text` ovunque —
quella scelta paga oggi.

**Il fallback sulla ThemeExtension (lezione dal rosso).** Il primo run
è esploso con un null check: i vecchi test montano `MaterialApp` col
tema di default, che non ha `PriorityColors`. Due opzioni: cambiare i
test (no: il vincolo era non toccarli) o rendere il widget robusto —
`extension<PriorityColors>() ?? fallback per brightness`. Vale la regola
generale: un widget riusabile non deve *pretendere* un tema arricchito,
deve degradare con grazia.

**Perché l'empty state è un widget core e non inline?** Arriveranno
altri vuoti (calendario senza task, dashboard senza dati, ricerca senza
risultati): un componente con `icon/title/subtitle` li rende consistenti
per costruzione. Il design system non è solo colori: è componenti
condivisi.

## Come funziona

- Il badge priorità legge `backgroundOf/foregroundOf` dall'estensione:
  in dark mode arrivano automaticamente le coppie scure leggibili. Zero
  `Colors.*` nel widget — il vecchio `_TaskTile` (che li usava) è stato
  eliminato.
- `CardThemeData` di C22 governa forma, bordo e margini: la card nel
  widget è un semplice `Card(child: ...)` — l'aspetto abita nel tema,
  il widget descrive solo il contenuto.
- Lo sfondo del Dismissible replica margini e raggio della card, così lo
  swipe rivela una "carta rossa" della stessa forma, non un rettangolo
  sotto.

## Il ciclo TDD in questo commit

1. **Rosso** — 4 test su un widget inesistente; più il rosso imprevisto
   del null check sull'estensione (2 test vecchi), che ha prodotto il
   fallback.
2. **Verde** — TaskCard, EmptyState, lista ristrutturata, `_TaskTile`
   rimosso: 72/72.
3. **Refactor** — il commit *è* il refactoring; i test erano la rete.

## Concetti chiave

- **Restyle sotto test**: le Key stabili rendono l'estetica sostituibile
  senza toccare le verifiche di comportamento.
- **Widget che degradano con grazia**: mai un `!` su ciò che il tema
  potrebbe non avere.
- **L'aspetto nel tema, il contenuto nel widget**: la card non sa di
  essere outlined.
- **Componenti condivisi**: l'empty state è uno, ovunque.

## Per approfondire

- [Material 3 — Cards](https://m3.material.io/components/cards/overview)
- [Flutter — InkWell e Material ripple](https://api.flutter.dev/flutter/material/InkWell-class.html)
- [Empty states (Material guidance)](https://m2.material.io/design/communication/empty-states.html)
- ROADMAP: Fase 9 (Polish), qui anticipata al momento giusto: prima delle feature, non dopo
