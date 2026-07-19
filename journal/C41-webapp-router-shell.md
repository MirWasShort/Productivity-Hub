# C41 — Router e guscio dell'app: la stessa mappa, un'altra forma

## Cosa è stato fatto

- **`webapp/src/lib/router.tsx`**: albero delle rotte con React Router v7 in
  *library mode*. Login e registrazione fuori dalla shell, tutto il resto
  dentro (`/tasks`, `/tasks/new`, `/tasks/:taskId`, `/tasks/:taskId/edit`,
  `/calendar`, `/dashboard`, `/tags`), radice che rimanda a `/tasks`, catch-all
  per le rotte inesistenti.
- **`webapp/src/components/layout/app-shell.tsx`**: barra laterale permanente
  da `lg` in su, a scomparsa (Sheet) sotto; header con il toggle del tema;
  `<Outlet />` per la pagina corrente.
- **`webapp/src/components/layout/not-found-page.tsx`**: 404 con ritorno ai task.
- **`webapp/src/features/**/*-page.tsx`**: otto pagine segnaposto, una per
  rotta, che i commit successivi riempiranno.
- **`webapp/src/main.tsx`**: monta `RouterProvider`; `App.tsx` sparisce.
- **`webapp/src/lib/router.test.tsx`**: cinque test di navigazione.

## Perché

**Library mode invece di framework mode.** React Router v7 può funzionare come
framework completo (loader, action, SSR, file-based routing). Qui non serve:
l'app è interamente dietro login, i dati li gestirà TanStack Query e il deploy
è un bundle statico. `createBrowserRouter` con un array di rotte dà la stessa
cosa che dà GoRouter nel client Flutter — un albero dichiarativo con un punto
unico dove, in C45, si aggancerà il guard di sessione.

**Una barra laterale al posto di NavigationBar + Drawer.** Il client Flutter ha
due elementi di navigazione: la barra in basso con le tre destinazioni e il
drawer che si apre col dito per liste, tag e logout. Sul desktop questa
divisione non ha senso: c'è spazio per tenere tutto visibile, e nascondere la
navigazione dietro un pulsante sarebbe un peggioramento gratuito. I due
elementi diventano quindi una sola barra laterale sempre presente; sotto i
1024px, dove lo spazio torna a mancare, collassa in un pannello a scomparsa.

È il primo punto in cui la webapp diverge di proposito dal mobile: stesse
destinazioni, stessa gerarchia, forma diversa.

Alternative valutate:

- **Riprodurre la bottom bar anche sul web** — scartata: imita il telefono su
  uno schermo che non è un telefono.
- **`StatefulShellRoute` di GoRouter (stack per tab)** — non ha equivalente e
  non serve: sul web la cronologia del browser *è* lo stack, e il pulsante
  Indietro deve funzionare come l'utente si aspetta.

## Come funziona

**Rotte annidate e `<Outlet />`.** La rotta senza `path` con `element:
<AppShell />` è una *layout route*: non corrisponde a un URL, esiste solo per
avvolgere i figli. React Router monta `AppShell` una volta e sostituisce solo
ciò che sta dentro `<Outlet />` quando si cambia sezione. È lo stesso principio
di `ShellRoute` in GoRouter: la shell non si rismonta, quindi lo stato che vive
lì (pannello aperto, scroll della sidebar) sopravvive alla navigazione.

**`NavLink` invece di `Link`** per le destinazioni: passa `isActive` alla
funzione che calcola le classi, così l'evidenziazione dell'elemento corrente
non richiede di leggere a mano la location. Il colore attivo usa
`primary-container`, gli stessi token dell'indicatore della NavigationBar
Flutter.

**Perché `routes` è esportato separatamente da `router`.** `createBrowserRouter`
parla con la History API del browser, che nei test non c'è. Esportando l'array
di rotte, i test possono costruire un `createMemoryRouter` con un URL iniziale
arbitrario e verificare la stessa identica configurazione che gira in
produzione — senza mock e senza duplicare l'albero.

**Il catch-all `path: '*'`** sta in fondo: React Router v7 sceglie la rotta più
specifica indipendentemente dall'ordine, ma tenerlo per ultimo rende esplicito
che è il ripiego.

## Il ciclo TDD

1. **Rosso** — cinque test su `routes` con `createMemoryRouter`: la radice
   porta ai task; la navigazione mostra le tre destinazioni; cliccare
   "Calendario" cambia pagina lasciando in piedi la shell; `/login` non ha
   navigazione attorno; una rotta inventata mostra la 404. Tutti falliti,
   `@/lib/router` non esisteva.
2. **Verde** — albero delle rotte, `AppShell` e le pagine segnaposto.

Il test più interessante è il terzo: dopo il click verifica **sia** il nuovo
titolo **sia** che la navigazione sia ancora nel documento. È la prova che la
shell avvolge davvero le rotte figlie invece di essere ridisegnata a ogni
cambio pagina — un errore facile da fare mettendo `AppShell` dentro ogni
singola pagina, e invisibile a occhio nudo.

## Concetti chiave

- **Layout route**: una rotta senza percorso che esiste solo per avvolgere.
- **Stessa gerarchia, forma diversa**: portare un'app da mobile a desktop non è
  ridisegnarla, ma nemmeno ricalcarla.
- **Configurazione esportabile = configurazione testabile**: separare la
  descrizione delle rotte dall'oggetto legato al browser.
- **Sul web la cronologia è già uno stack**: non va ricostruita.

## Per approfondire

- [React Router — Routing](https://reactrouter.com/start/library/routing) e
  [Navigating](https://reactrouter.com/start/library/navigating)
- [`createMemoryRouter`](https://reactrouter.com/api/data-routers/createMemoryRouter)
- C17 (`C17-auth-ui-router.md`) e C23 (`C23-app-shell.md`) — router e shell Flutter
