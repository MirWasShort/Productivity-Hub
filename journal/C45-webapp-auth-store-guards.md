# C45 — Store di autenticazione, guard e la cache che va svuotata

## Cosa è stato fatto

- **`webapp/src/lib/auth/auth-store.ts`**: store zustand con `session`,
  `isAuthenticated`, `hydrate()`, `signIn()`, `signOut()`; `initAuth()` lo
  aggancia agli eventi esterni (refresh fallito, altre schede).
- **`webapp/src/lib/query-client.ts`**: la `QueryClient` condivisa, con
  `staleTime` di 30s e niente retry sui 4xx.
- **`webapp/src/lib/auth/route-guards.tsx`**: `RequireAuth` (conserva
  l'indirizzo richiesto in `state.from`) e `RequireAnonymous`.
- **`webapp/src/lib/router.tsx`**: shell sotto `RequireAuth`, login e
  registrazione sotto `RequireAnonymous`.
- **`webapp/src/main.tsx`**: `QueryClientProvider`, `initTheme()`, `initAuth()`.
- **`webapp/src/components/layout/app-shell.tsx`**: voce "Esci" nella barra.
- Test: 8 sullo store, 3 nuovi sui guard.

## Perché

**Perché uno store fuori da React.** Lo stato di autenticazione serve in tre
posti che non sono componenti: il client HTTP (per allegare il token), il
modulo di refresh (per annunciare la fine della sessione) e le altre schede
del browser. Un Context React sarebbe leggibile solo dentro l'albero dei
componenti, e finiremmo a passare callback verso il basso o a duplicare lo
stato. Uno store zustand è leggibile ovunque con `getState()` e resta
reattivo nei componenti con l'hook.

**Perché `queryClient.clear()` al logout.** È il bug che il client Flutter ha
avuto e corretto (C-*"clear cached user data on logout"*): senza svuotare la
cache, il secondo utente che accede sullo stesso browser vede per un istante i
task del primo — la cache è ancora popolata e TanStack Query mostra il dato
vecchio mentre rifetcha. Non è solo un difetto estetico: è una fuga di dati fra
account. `signOut()` cancella storage, cache e stato insieme, sempre.

**Perché tre percorsi convergono su `signOut()`.** La sessione può finire per
scelta dell'utente, perché il refresh si è arreso, o perché un'altra scheda ha
fatto logout. Sono eventi diversi con lo stesso identico effetto; averli
convergere su un unico metodo idempotente evita che uno dei tre dimentichi un
pezzo di pulizia.

Alternative valutate per i guard:

- **`loader` + `redirect()` di React Router** — scartata: i loader girano fuori
  da React e non si risottoscrivono ai cambi di stato, quindi un logout
  avvenuto *mentre* si è su una pagina protetta non farebbe scattare nulla
  finché non si naviga.
- **Un controllo dentro ogni pagina** — scartata: si dimentica su una pagina
  su cinque, ed è esattamente il tipo di errore che non si vede finché non è
  troppo tardi.

## Come funziona

**Guard come componenti che avvolgono.** `RequireAuth` legge
`isAuthenticated` dallo store con l'hook: quando lo stato cambia, il componente
si ri-renderizza e il redirect scatta **subito**, anche se l'utente non sta
navigando. È il test "il logout riporta al login anche se si è già dentro": la
sessione viene chiusa mentre la pagina dei task è montata, e la pagina di login
compare senza che nessuno abbia cliccato niente. È l'equivalente del
`refreshListenable` che in GoRouter fa rivalutare il redirect (C17).

`RequireAuth` avvolge **la shell**, non le singole pagine: una sola dichiarazione
copre tutte le rotte figlie, presenti e future. Chi aggiunge una pagina domani
la ottiene protetta senza doverlo ricordare.

**`state.from`**: il redirect al login porta con sé l'indirizzo richiesto. Chi
apre un link diretto a un task, si trova a fare login e viene poi riportato lì
invece che sulla lista generica. Il login lo userà in C46.

**`retry` selettivo nella QueryClient.** Riprovare un 404 o un 403 è tempo
sprecato: la risposta non cambierà. Riprovare un 500 o un errore di rete ha
senso, perché possono essere transitori. Il predicato distingue i due casi
guardando `ApiError.status`.

**Nota sullo `staleTime` a 30 secondi**: senza, TanStack Query considera ogni
dato immediatamente stantio e rifetcha a ogni rimontaggio di componente —
cambiare tab avanti e indietro genererebbe una raffica di richieste identiche.

## Il ciclo TDD

1. **Rosso** — `auth-store.test.ts`: idratazione dalla sessione salvata,
   assenza di sessione, login che scrive anche su disco, **logout che svuota
   la cache di TanStack Query**, sessione scaduta equivalente al logout,
   allineamento al logout e al login di un'altra scheda, idempotenza del
   logout ripetuto (la cache si svuota una volta sola).
2. **Verde** — `query-client.ts` e `auth-store.ts`.
3. **Rosso** — tre test sui guard: rotta protetta senza sessione → login;
   login con sessione → task; logout durante la navigazione → login.
4. **Verde** — `route-guards.tsx` e il cablaggio nel router.

I cinque test di navigazione già esistenti sono stati aggiornati per fare
`signIn()` prima: ora falliscono davvero se il guard non c'è, il che li rende
più informativi di prima.

## Concetti chiave

- **Lo stato di sessione non appartiene all'albero dei componenti**: lo
  leggono anche la rete e le altre schede.
- **La cache è dati dell'utente**: svuotarla al logout è una questione di
  privacy, non di igiene.
- **Guard reattivo, non solo al cambio rotta**: la sessione può finire mentre
  guardi una pagina.
- **Un solo punto di uscita**: tre cause diverse, un unico `signOut()`
  idempotente.
- **Retry con criterio**: riprovare ha senso solo per errori che possono
  passare da soli.

## Per approfondire

- [TanStack Query — `QueryClient` e invalidazione](https://tanstack.com/query/latest/docs/framework/react/reference/QueryClient)
- [React Router — redirect e `Navigate`](https://reactrouter.com/api/components/Navigate)
- [zustand — uso fuori da React](https://zustand.docs.pmnd.rs/guides/practice-with-no-store-actions)
- C17 (`C17-auth-ui-router.md`) — guard e AuthNotifier lato Flutter
