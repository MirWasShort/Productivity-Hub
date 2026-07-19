# C46 — Login e registrazione: chi decide dove si va dopo l'accesso

## Cosa è stato fatto

- **`webapp/src/features/auth/schemas.ts`**: schemi zod di login e
  registrazione, con i vincoli del backend (password 8–100, nome ≤100,
  conferma che deve coincidere).
- **`webapp/src/features/auth/auth-api.ts`**: `login()` e `register()`.
- **`webapp/src/lib/auth/token-storage.ts`**: `sessionFromAuthResponse()`,
  spostata qui perché la usano sia il refresh sia le schermate.
- **`webapp/src/features/auth/auth-form-layout.tsx`**: la card centrata
  larga al massimo 400px, comune alle due schermate.
- **`webapp/src/features/auth/{login,register}-page.tsx`**: i form veri,
  con react-hook-form e i componenti `Form` di shadcn/ui.
- **`webapp/src/lib/auth/route-guards.tsx`**: `RequireAnonymous` ora
  reindirizza alla pagina richiesta, non sempre a `/tasks`.
- **`webapp/src/features/auth/auth-pages.test.tsx`**: otto test di flusso.

## Perché

**Validazione doppia, non ridondante.** Gli schemi zod ripetono i vincoli che
il backend già applica. Non è duplicazione inutile: un errore rilevato prima
della richiesta è immediato e non consuma un giro di rete, mentre il backend
resta l'unica autorità (è lui a sapere se un'email è già presa). La regola che
seguiamo: il client previene gli errori che può prevedere da solo, il server
decide.

**Il conflitto va sul campo, non in fondo al form.** Un 409 "Email già
registrata" riguarda un campo preciso: mostrarlo sotto quel campo, con
`form.setError('email')`, dice all'utente cosa correggere. Un messaggio
generico in fondo alla pagina lo lascia a indovinare.

## Come funziona

**Il bug che il test ha trovato.** La prima versione faceva così: il form
chiamava `signIn()` e poi `navigate(from ?? '/tasks')`. Sette test su otto
passavano; falliva quello che apre `/dashboard` da non autenticato, fa login e
si aspetta di tornare sulla dashboard. Finiva invece sui task.

Il motivo è una corsa fra due reazioni allo stesso evento. `signIn()` aggiorna
lo store; React ri-renderizza **subito** `RequireAnonymous`, che vede la
sessione e naviga a `/tasks`; solo dopo il `navigate` del form prova ad
andare su `/dashboard`, ma la pagina di login è già smontata e la sua
navigazione non ha più effetto. Due pezzi di codice si contendevano la stessa
decisione, e vinceva quello che scattava prima.

La correzione non è aggiungere un `await` o riordinare: è togliere la
duplicazione. **La destinazione post-accesso appartiene al guard**, che è già
l'unico posto che sa sia se c'è una sessione sia da dove veniva l'utente
(`state.from`, messo lì da `RequireAuth`). I form ora si limitano a
`signIn()`; il redirect è una conseguenza, non un secondo comando. Anche la
registrazione ne beneficia: nessuna navigazione esplicita, stesso percorso.

**`noValidate` sul `<form>`**: disattiva le bolle di validazione native del
browser, che comparirebbero in inglese e con uno stile fuori dal design
system. La validazione è quella di zod, mostrata da `FormMessage`.

**Il collegamento label–input** lo fa `FormField` di shadcn/ui generando gli
`id` e gli `aria-describedby`. Per questo i test possono usare
`getByLabelText('Email')`: interrogano la pagina come farebbe uno screen
reader, e se il collegamento si rompe il test fallisce — un controllo di
accessibilità gratuito.

**Lo stato di invio** disabilita il pulsante e ne cambia il testo
(`form.formState.isSubmitting`): niente doppie registrazioni per doppio click.

## Il ciclo TDD

Otto test, rossi prima delle pagine:

- login: email non valida → nessuna chiamata al backend; credenziali corrette
  → sessione aperta e task visibili; 401 → messaggio del backend a schermo e
  nessuna sessione; **login partendo da `/dashboard` → si torna su
  `/dashboard`**;
- registrazione: password che non coincidono → nessuna chiamata; password
  troppo corta → nessuna chiamata; 409 → messaggio sul campo email; successo →
  si è già dentro.

I test montano l'**intero router**, non i componenti isolati: verificano il
flusso completo (form → API → store → guard → pagina di destinazione), che è
poi il punto dove si è annidato il bug del redirect. Un test del solo
`LoginPage` sarebbe passato senza accorgersene.

Verifica aggiuntiva contro il backend vero: registrazione, login, 409 su email
duplicata, 401 su password sbagliata — tutti confermati via `curl`.

## Concetti chiave

- **Una decisione, un posto**: se due componenti reagiscono allo stesso evento
  navigando, il risultato dipende dall'ordine di render, che non è un
  contratto.
- **Il guard è il posto giusto per il "dove si va dopo"**: è l'unico che
  conosce sia lo stato sia la provenienza.
- **Errore di campo vs errore di form**: il primo è azionabile, il secondo no.
- **Testare per ruolo e per etichetta**: interrogare la pagina come un utente
  assistito rende i test anche una verifica di accessibilità.
- **Il client previene, il server decide.**

## Per approfondire

- [react-hook-form — validazione con resolver](https://react-hook-form.com/docs/useform#resolver)
- [zod](https://zod.dev/)
- [Testing Library — priorità delle query](https://testing-library.com/docs/queries/about/#priority)
- C17 (`C17-auth-ui-router.md`) — le stesse due schermate in Flutter
