# C20 — Schermate di creazione, modifica e dettaglio

## Cosa è stato fatto

- **`TaskEditScreen`**: una sola schermata per creare (`task == null`) e
  modificare (`task != null`) — titolo obbligatorio, descrizione,
  dropdown priorità, dropdown stato (solo in modifica: un task nuovo è
  TODO per definizione), date picker per la scadenza, bottone con
  spinner. In modifica i campi partono pre-compilati e il salvataggio usa
  `copyWith` sull'entità originale.
- **`TaskDetailScreen`**: tutti i campi del task (letti dallo stato della
  lista, non ri-scaricati), matita → edit, cestino → dialog di conferma →
  delete → ritorno alla lista.
- **Rotte annidate** in GoRouter: `/tasks/new`, `/tasks/:id`,
  `/tasks/:id/edit` — tutte automaticamente protette dal redirect di C17.
  Tap sulla riga → dettaglio; nel quick-add di C19 è comparso il bottone
  "più opzioni" che apre il form completo.
- 6 widget test scritti prima: modalità create (render, titolo vuoto non
  invia, valori digitati arrivano al repository) e modalità edit
  (pre-compilazione, l'update conserva id e campi non toccati —
  verificato con `captureAny` sull'entità inviata).

## Perché

**Perché una sola schermata per create ed edit?** I due form sono
identici al 90%: duplicarli significherebbe due posti da aggiornare per
ogni campo futuro. La differenza (titolo della pagina, stato visibile,
create vs update al salvataggio) è un `if` sul parametro. È il pattern
suggerito dalla stessa ROADMAP ("TaskEditScreen — used for both create
and edit").

**Perché il dettaglio legge dallo stato della lista invece di fare una
GET?** La lista è già in memoria e aggiornata; una seconda fetch
introdurrebbe il problema della doppia fonte di verità (il dettaglio
mostra una versione, la lista un'altra). Il costo: un deep-link diretto
al dettaglio mostra il task solo quando la lista ha caricato — gestito
mostrando lo spinner finché `taskListProvider` è in loading. Per
un'app con liste da 50 elementi è lo scambio giusto.

**Perché il dialog di conferma solo sulla delete dal dettaglio e non
sullo swipe?** Lo swipe è un gesto *deliberato* e reversibile
visivamente (la riga scompare, pull-to-refresh la riporterebbe se il
server non avesse confermato); il tap sul cestino è un click facile da
sbagliare. Convenzione consolidata: gesti espliciti → nessuna frizione,
click ambigui → conferma.

**Il test più prezioso del commit**: `captureAny` sull'update cattura
l'entità *davvero inviata* e verifica che `id` e `priority` siano quelli
originali dopo aver modificato solo il titolo. È il test che protegge dal
bug classico dei form di modifica: ricostruire l'oggetto da zero
perdendo i campi non mostrati.

## Come funziona

- Le **rotte annidate** di GoRouter compongono i path: `/tasks` +
  `:id` + `edit`. `state.pathParameters['id']` estrae il parametro. La
  rotta `new` è dichiarata *prima* di `:id`, altrimenti "new" verrebbe
  interpretato come un id.
- La guardia di C17 copre le rotte nuove *senza una riga in più*: il
  redirect ragiona su "è una rotta auth?" — tutto il resto richiede
  autenticazione. Aggiungere schermate non richiede di ricordarsi della
  security: è il design che paga.
- `mounted` dopo gli `await`: il classico guaio di usare un
  `BuildContext` dopo un gap asincrono (la schermata potrebbe essere già
  stata smontata) — il linter `use_build_context_synchronously` lo
  segnala, i check `if (mounted)` lo risolvono.
- Terzo incontro con mocktail: `any(named: 'priority')` su un tipo non
  primitivo richiede `registerFallbackValue(TaskPriority.medium)` in
  `setUpAll` — stessa regola già vista per `RequestOptions` in C15.

## Il ciclo TDD in questo commit

1. **Rosso** — 6 widget test sulla schermata inesistente.
2. **Verde** — edit screen, detail screen, rotte; un giro extra per il
   fallback value di mocktail.
3. **Refactor** — `_DetailRow` estratto; le label italiane di
   stato/priorità centralizzate in mappe const.

## Concetti chiave

- **Un form, due modalità**: create/edit condividono la struttura, l'if
  sta ai margini.
- **Singola fonte di verità**: il dettaglio osserva lo stesso stato della
  lista.
- **Conferme proporzionali al rischio del gesto**.
- **`mounted` dopo `await`**: mai usare un context attraverso un gap
  asincrono senza controllo.

## Per approfondire

- [GoRouter — rotte annidate e path parameters](https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html)
- [Flutter — use_build_context_synchronously](https://dart.dev/tools/linter-rules/use_build_context_synchronously)
- [Material — Dialogs](https://m3.material.io/components/dialogs/guidelines) (quando chiedere conferma)
- ROADMAP: Fase 5, Settimana 24 (TaskDetailScreen, TaskEditScreen)
