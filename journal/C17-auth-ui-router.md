# C17 — Stato auth, schermate di login/registrazione e guardie di rotta

## Cosa è stato fatto

- **`AuthNotifier`** (`Notifier<AuthState>`) con una gerarchia sealed
  scritta a mano: `AuthInitial`, `AuthLoading`, `AuthAuthenticated(User?)`,
  `AuthUnauthenticated`, `AuthError(message)`. Operazioni: `checkAuth()`
  (all'avvio: c'è una sessione salvata?), `login`, `register`, `logout`.
  In `build()` ascolta il `sessionExpiredProvider` di C15: se
  l'interceptor dichiara morta la sessione, lo stato diventa
  `Unauthenticated` — da qualunque punto dell'app.
- **`LoginScreen` e `RegisterScreen`**: Form con validazione (email,
  password ≥ 8, conferma password), bottone con spinner durante il
  loading, errori dal backend in SnackBar, link incrociati.
- **`app_router.dart`**: GoRouter con rotte `/login`, `/register`,
  `/tasks` (placeholder con logout, sostituito nei prossimi commit) e il
  **`redirect` centralizzato**: non autenticato → `/login`; autenticato
  su una rotta auth → `/tasks`; stato iniziale/loading → fermo dove sei.
- **`app.dart`** ora è `MaterialApp.router`; `checkAuth()` parte al primo
  frame.
- 10 test scritti prima: 7 sul notifier con `ProviderContainer` e
  repository mockato (tutte le transizioni), 3 widget test sulla
  `LoginScreen` (render, validazione che blocca la chiamata, submit che
  arriva al repository con i valori giusti).

## Perché

**Perché il redirect sta nel router e non nelle schermate?** Se ogni
schermata controllasse "sono loggato?", la protezione sarebbe sparsa e
dimenticabile (il gemello UI del bug "if dimenticato" di C09). Nel
`redirect` di GoRouter la regola è una, centrale, e vale per qualunque
rotta presente e futura: una schermata nuova è protetta *di default*.

**Perché il bridge `ValueNotifier` tra Riverpod e GoRouter?** GoRouter
rivaluta il `redirect` quando il suo `refreshListenable` notifica. Se
invece si ricreasse il router a ogni cambio di stato (`ref.watch` sul
provider del router), si perderebbe lo stack di navigazione a ogni login.
Il bridge — un contatore che incrementa a ogni cambio di auth state — fa
scattare la rivalutazione senza ricreare nulla.

**Perché `AuthAuthenticated.user` è nullable?** Dopo un riavvio l'app ha
i token ma non il profilo (abbiamo tagliato l'endpoint `/me`: il profilo
arriva solo da login/register). Il tipo dice la verità: "autenticato,
profilo forse non ancora noto". L'alternativa — fingere un utente vuoto —
nasconderebbe il caso invece di modellarlo.

**Perché lo stato sealed è scritto a mano e non con Freezed?** Cinque
classi senza campi complessi: il pattern matching di Dart 3 (`switch`
esaustivo nel redirect) dà già tutto quello che serve. Freezed paga
quando ci sono `copyWith`/JSON di mezzo (i modelli di C16); qui sarebbe
solo codegen in più. Scegliere lo strumento per il caso, non per abitudine.

**Perché i widget test overridano il *repository* e non il notifier?**
Overridare il notifier significherebbe testare la schermata contro un
falso che non esiste in produzione. Con il repository mockato, il
notifier in mezzo è *quello vero*: il test copre schermata + notifier
insieme, al costo di un solo mock — più fedeltà con meno finzione.

## Come funziona

Il flusso di avvio: `main` → `ProviderScope` → `SmartTodoApp.initState`
lancia `checkAuth()` → lo stato passa `Initial → Loading →
Authenticated|Unauthenticated` → il bridge notifica → GoRouter rivaluta
il redirect → l'utente atterra su `/tasks` o `/login`. Il tutto senza un
solo `Navigator.push` scritto a mano.

La sessione scaduta chiude il cerchio aperto in C15: interceptor (401 +
refresh fallito) → `sessionExpiredProvider` → `AuthNotifier` →
`Unauthenticated` → redirect → login. Quattro pezzi disaccoppiati, ognuno
testato da solo.

Nei widget test: `find.byKey(Key('login_email'))` — le key stabili
rendono i test indipendenti da testi e layout; `tester.enterText` +
`tap` + `pump` simulano l'utente; `verifyNever` prova che la validazione
*blocca* la chiamata di rete.

## Il ciclo TDD in questo commit

1. **Rosso** — 10 test su notifier e schermata inesistenti.
2. **Verde** — notifier, schermate, router, bridge; smoke test dell'app
   aggiornato (ora entra dalla LoginScreen con repository fake — quello
   vero toccherebbe il plugin di secure storage, assente nei test).
3. **Refactor** — la logica di redirect ridotta a un singolo `switch`
   esaustivo sullo stato sealed: aggiungere uno stato nuovo obbligherà il
   compilatore a chiedere "e qui che si fa?".

## Concetti chiave

- **Route guard centralizzata**: la protezione è una proprietà del
  router, non delle schermate.
- **refreshListenable bridge**: rivalutare ≠ ricreare.
- **Stati sealed + switch esaustivo**: le transizioni impossibili non
  compilano.
- **Mock al confine più esterno possibile**: più codice vero nel test,
  più valore.

## Per approfondire

- [GoRouter — redirection](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)
- [Riverpod — Notifier e ProviderContainer nei test](https://riverpod.dev/docs/essentials/testing)
- [Flutter — widget testing](https://docs.flutter.dev/testing/overview#widget-tests) e [Form validation](https://docs.flutter.dev/cookbook/forms/validation)
- ROADMAP: Fase 5, Settimana 22 (Auth Screens + AuthNotifier + navigation wiring), kata 4.4 (Form Validation Kata)
