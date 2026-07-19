# C51 — Dettaglio ed editor: il bug che impediva di salvare

## Cosa è stato fatto

- **`webapp/src/features/tasks/task-detail-page.tsx`**: titolo, descrizione,
  righe Stato/Priorità/Scadenza/Creato/Tag, modifica ed eliminazione con
  conferma; un task inesistente riporta alla lista.
- **`webapp/src/features/tasks/task-edit-page.tsx`**: un solo form per
  creazione e modifica, con lo stato selezionabile **solo** in modifica e i
  valori iniziali presi dalla query string (`?title=`, `?date=`).
- **`webapp/src/features/tasks/components/due-date-picker.tsx`**: selettore di
  data in italiano, da −365 giorni a +5 anni, con pulsante per toglierla.
- **`webapp/src/components/ui/native-select.tsx`**: elenco a discesa nativo,
  stilato come gli input.
- **`webapp/src/features/tasks/queries.ts`**: correzione dell'aggiornamento
  ottimistico (vedi sotto).
- Test: 9 sull'editor e sul dettaglio, 1 di regressione sulle query.

## Perché

**Un form per due operazioni.** Creazione e modifica condividono tutto tranne
un campo: lo **stato**, che in creazione non ha senso scegliere (un task appena
creato è da fare). È la stessa decisione del client Flutter, che usa un unico
`TaskEditScreen`.

**`<select>` nativo invece del componente di Radix.** Il `Select` di shadcn/ui
è bello ma costruito con portali e osservatori di dimensione: in jsdom non
mostra nemmeno il valore selezionato, e sui telefoni sostituisce il selettore
di sistema con una lista disegnata. Per scelte brevi e chiuse — stato,
priorità, e in futuro la lista — il `<select>` del browser è più accessibile,
funziona da tastiera senza codice, e resta perfettamente testabile. Stilarlo
con `appearance-none` più una freccia costa dieci righe. Il componente di
Radix resta disponibile per i casi in cui le opzioni contengono contenuti
ricchi.

## Come funziona

### Il bug: `onMutate` che rompeva il salvataggio

Sintomo: dalla pagina di modifica, "Salva" non faceva **niente**. Nessuna
richiesta, nessun errore di validazione, nessun messaggio. Il form era valido,
il pulsante di tipo `submit`, il gestore collegato.

La causa era in C47, in un punto che sembrava innocuo:

```ts
queryClient.setQueriesData<Task[]>({ queryKey: taskKeys.all }, (tasks) =>
  tasks?.map((task) => (task.id === taskId ? { ...task, ...body } : task)),
)
```

`setQueriesData` con il prefisso `['tasks']` colpisce **tutte** le query che
iniziano così — e sotto quel prefisso non ci sono solo liste: `['tasks',
'detail', id]` contiene **un singolo task**, non un array. Chiamare `.map()`
su un oggetto lancia un `TypeError` dentro `onMutate`; TanStack Query, quando
`onMutate` fallisce, **non esegue la mutazione**. Da qui il silenzio totale:
la richiesta non veniva mai costruita.

Il dettaglio è che il bug era invisibile finché la cache conteneva solo liste —
tutti i test di C47 e C49 passavano. Bastava avere aperto la pagina di
dettaglio, cioè il percorso normale per arrivare all'editor, perché salvare
smettesse di funzionare.

La correzione riconosce le due forme di cache (`updateCached` distingue array e
oggetto singolo) e, come bonus, aggiorna in modo ottimistico anche il
dettaglio. C'è un test di regressione dedicato, che popola la cache del
dettaglio prima di mutare.

**Morale**: invalidare per prefisso è comodo (C47) ma *scrivere* per prefisso
richiede di sapere che forma hanno i dati sotto quel prefisso. Le due
operazioni si somigliano e hanno rischi diversi.

### Il falso colpevole

Prima di trovarlo, un'altra ipotesi sembrava perfetta: il prop `values` di
react-hook-form era ricostruito a ogni render, `new Date(task.dueDate)`
compreso, e un oggetto sempre diverso fa ripartire il reset del form. Era
davvero un difetto — solo, non *quel* difetto. È stato corretto lo stesso
(i valori sono memoizzati su `task` e sui parametri della query string),
perché un form che si resetta di continuo è comunque un problema in attesa di
manifestarsi.

### Dettagli minori ma non banali

- **La descrizione svuotata viene mandata come assente**, non come stringa
  vuota: `''` e "nessuna descrizione" non sono la stessa cosa lato backend, e
  un test lo blinda.
- **Un 404 sul dettaglio non è un errore da mostrare**: significa che il task
  è stato cancellato altrove, quindi si torna alla lista, che è la verità.
- **La data va convertita in istante UTC** (`toISOString()`) prima di partire:
  il selettore lavora in ora locale, il backend in UTC.

## Il ciclo TDD

Nove test: il dettaglio mostra i campi giusti; un id inesistente riporta alla
lista; l'editor apre i valori del task con lo stato modificabile; in creazione
lo stato non c'è; il titolo e la data arrivano dalla query string; senza
titolo non parte nessuna richiesta; salvando si manda il task **intero**
(tag compresi); la descrizione svuotata sparisce dal corpo.

Sono stati i due test di salvataggio a far emergere il bug di `onMutate`:
il caso "modifico e salvo" non era mai stato coperto con la cache del dettaglio
popolata, che è invece la condizione normale nell'uso reale.

## Concetti chiave

- **Scrivere per prefisso ≠ invalidare per prefisso**: la prima operazione deve
  conoscere la forma dei dati, la seconda no.
- **Un `onMutate` che lancia annulla la mutazione**: un errore lì diventa
  silenzio, non un messaggio.
- **Il primo sospetto plausibile non è per forza il colpevole**: valeva la pena
  correggerlo, non fermarsi lì.
- **La piattaforma prima della libreria**: `<select>` nativo dove basta.
- **Vuoto e assente sono cose diverse**, e il confine va difeso con un test.

## Per approfondire

- [TanStack Query — `onMutate` e rollback](https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates)
- [react-hook-form — `values` e reset](https://react-hook-form.com/docs/useform#values)
- [MDN — `<select>`](https://developer.mozilla.org/docs/Web/HTML/Element/select)
- C20 (`C20-task-edit-detail.md`) — le stesse due schermate in Flutter
