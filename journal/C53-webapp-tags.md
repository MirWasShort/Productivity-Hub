# C53 — Tag: gestione, filtro e selezione multipla

## Cosa è stato fatto

- **`webapp/src/features/tags/{api,queries}.ts`**: CRUD dei tag; ogni
  mutazione invalida anche i task, perché i tag viaggiano dentro di loro.
- **`webapp/src/features/tags/tag-management-page.tsx`**: elenco, creazione,
  rinomina, eliminazione, stato vuoto che spiega a cosa servono i tag.
- **`webapp/src/features/tasks/components/filter-bar.tsx`**: un chip per ogni
  tag, a selezione singola come gli altri.
- **`webapp/src/features/tasks/task-edit-page.tsx`**: scelta dei tag **a più a
  più**, nel colore di ciascuno.
- **`webapp/src/components/layout/app-shell.tsx`**: voce "Gestisci tag".
- Test: 7 sui tag.

## Perché

**Selezione singola nei filtri, multipla nell'editor.** Non è un'incoerenza: il
backend accetta un solo `tagId` come filtro (`GET /tasks?tagId=`), mentre un
task può portare più tag (`tagIds[]`). L'interfaccia riflette il modello, in
entrambe le direzioni.

**La rinomina, che nel client Flutter manca.** Il repository Flutter espone
`update` per i tag ma nessuna schermata lo usa (C32). Qui c'era già l'endpoint
e c'era già il dialogo delle liste: aggiungerla è costato un pulsante. È una
delle poche cose in cui la webapp fa **più** del mobile, e va segnata come
divergenza da colmare quando il client Flutter verrà ripreso.

**Il 409 si mostra dentro il dialogo.** Il backend ha un indice univoco su
`(user_id, nome)` (C29): provare a creare un tag già esistente risponde 409.
Il messaggio compare nel dialogo, che resta aperto con il testo scritto —
chiuderlo e mostrare un avviso altrove costringerebbe a riscrivere tutto.

## Come funziona

**Invalidazione incrociata.** I tag compaiono **dentro** i task
(`TaskResponse.tags` è un array di oggetti, non di id). Rinominare o eliminare
un tag cambia quindi ciò che le card devono mostrare, anche se la richiesta
riguardava solo `/tags`. Le tre mutazioni condividono un helper che invalida
sia `['tags']` sia `['tasks']`. È la stessa logica di C52 con
`ON DELETE SET NULL`: **si invalida ciò che il server cambia di riflesso**, non
solo ciò che la richiesta nomina.

**Il dialogo riusato.** `ListEditorDialog`, nato per le liste, serve anche i
tag: nome più otto colori, con etichette e lunghezza massima parametriche (100
per le liste, 50 per i tag, come il backend). Ha guadagnato due cose in questo
commit: `errorMessage`, per mostrare il conflitto, e la gestione dell'errore
lanciato da `onSubmit` — se la mutazione fallisce il dialogo **non si chiude**.
Senza quel `catch`, il rifiuto della promessa restava non gestito.

**I chip dell'editor sono colorati come i tag.** Selezionato: sfondo al 15% e
bordo al 60%; deselezionato: solo un bordo tenue al 25%. Il colore è dato
dell'utente, quindi va inline (vedi C49); il contrasto regge in entrambi i
temi perché i colori scelti sono gli otto della palette.

## Il ciclo TDD

Sette test: elenco dei tag; creazione con nome e colore; **409 mostrato dentro
il dialogo**; rinomina che manda nome e colore all'id giusto; eliminazione che
avvisa della rimozione dai task; ogni tag diventa un chip che filtra
(`tagId` nella query); nell'editor i tag si selezionano a più a più e
finiscono in `tagIds`.

Verifica contro il backend vero: creata una lista, un tag e un task che li usa
entrambi; filtrato per `listId` e per `tagId` — il task compare in entrambi i
casi con il tag incorporato; un tag duplicato risponde 409 come atteso.

**Sette test rossi di rimbalzo.** Aggiungendo i chip dei tag alla barra dei
filtri, i test delle *liste* sono caduti: il loro mock rispondeva
`{items: []}` anche a `/tags`, e `tags?.map` non esiste su un oggetto. È lo
stesso inciampo di C52, con la stessa lezione — un mock che non instrada
mente. Ora anche quel file usa `createApiMock`.

## Concetti chiave

- **L'interfaccia rispecchia il modello**: uno solo dove il filtro accetta uno
  solo, molti dove la relazione è molti-a-molti.
- **Invalidare per conseguenza, non per soggetto**: i tag sono dentro i task,
  quindi toccare i primi invalida i secondi.
- **Un dialogo che fallisce resta aperto**: chiuderlo perde il lavoro
  dell'utente.
- **Riusare un componente parametrizzandolo** batte duplicarlo: liste e tag
  sono la stessa forma con vincoli diversi.

## Per approfondire

- [TanStack Query — invalidazione mirata](https://tanstack.com/query/latest/docs/framework/react/guides/query-invalidation)
- C29 (`C29-tags-crud.md`) — indice univoco e 409 lato backend
- C32 (`C32-frontend-tags.md`) — i tag nel client Flutter (senza rinomina)
