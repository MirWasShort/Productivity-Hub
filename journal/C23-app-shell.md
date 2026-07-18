# C23 — App shell: NavigationBar e tab con stack indipendenti

## Cosa è stato fatto

- **`core/widgets/app_shell.dart`**: lo Scaffold condiviso dalle tre tab
  principali — `NavigationBar` M3 con destinazioni **Task / Calendario /
  Dashboard** (key `nav_*`), icone outlined/filled per lo stato
  selezionato.
- **Router**: le tre rotte `/tasks`, `/calendar`, `/dashboard` ora vivono
  dentro una **`StatefulShellRoute.indexedStack`**; le rotte di
  dettaglio/editor (`/tasks/new`, `/tasks/:id`, `/tasks/:id/edit`)
  restano **fuori** dalla shell (push a schermo pieno, senza bottom bar).
- Schermate placeholder per Calendario e Dashboard (con key testabili) —
  verranno sostituite dalle feature reali nei prossimi commit.
- 4 test scritti prima: le tre destinazioni esistono, il tap cambia tab
  (placeholder visibile), il logout da una tab della shell riporta al
  login *senza* NavigationBar (la guardia copre le rotte nuove).

## Perché

**Perché la shell adesso, con due tab vuote?** Calendario e dashboard
arrivano tra qualche commit: se la navigazione nascesse insieme a loro,
ogni feature ridiscuterebbe il frame. Costruendo prima lo scheletro, le
feature future si *inseriscono* in una struttura stabile — e la guardia
di autenticazione sulle rotte nuove è già testata oggi, non "quando
serve".

**Perché `StatefulShellRoute.indexedStack` e non un semplice
`ShellRoute`?** La differenza è la parola *stateful*: ogni branch
mantiene il proprio Navigator e il proprio stato (posizione di scroll,
sotto-navigazione). Passi da Task a Calendario e torni: ritrovi la lista
esattamente dov'era. Con una `ShellRoute` semplice ogni cambio tab
ricostruirebbe la schermata da zero.

**Perché dettaglio ed editor stanno fuori dalla shell?** Sono flussi di
*focus*: l'utente sta compilando un form o leggendo un dettaglio — la
bottom bar lì è rumore e rubare spazio verticale a un form è un costo.
Convenzione consolidata (la usano Gmail, Calendar…): le tab per i
contesti, il push a schermo pieno per le azioni.

**La guardia non ha richiesto una riga.** Il `redirect` di C17 ragiona
per esclusione ("è una rotta auth? no → serve autenticazione"): le due
rotte nuove sono nate protette. Il test del logout-dalla-shell lo
dimostra — è il dividendo del design centralizzato, incassato per la
seconda volta (la prima: le rotte annidate di C20).

## Come funziona

- La shell riceve una `StatefulNavigationShell`: è sia il widget da
  mettere nel body (l'indexed stack dei branch) sia il controller
  (`currentIndex`, `goBranch(index)`).
- `goBranch(..., initialLocation: index == currentIndex)`: il tap sulla
  tab **già attiva** riporta il branch alla sua radice — il pattern
  standard delle bottom bar (ri-tap = reset).
- Ordine delle rotte: `/tasks/new` è dichiarata *prima* di `/tasks/:id`,
  altrimenti "new" verrebbe catturato come `:id` (stessa attenzione di
  C20, ora a livello top).

## Il ciclo TDD in questo commit

1. **Rosso** — 4 test sulla shell inesistente (niente NavigationBar).
2. **Verde** — shell + placeholder + ristrutturazione del router; l'intera
   suite (68) verde, inclusi tutti i test di navigazione preesistenti.
3. **Refactor** — nessuno: il commit *è* un refactoring strutturale del
   router, fatto sotto la protezione dei test esistenti.

## Concetti chiave

- **Shell route**: un layout persistente che avvolge un sottoinsieme di
  rotte; le tab sono figlie, non copie.
- **Stack per branch**: ogni tab ricorda dov'era — `indexedStack`.
- **Tab per i contesti, push per il focus**: la bottom bar sparisce nei
  flussi di compilazione.
- **Sicurezza per default**: con la guardia centralizzata, una rotta
  nuova è protetta finché qualcuno non decide altrimenti.

## Per approfondire

- [GoRouter — StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html)
- [Material 3 — Navigation bar](https://m3.material.io/components/navigation-bar/overview)
- [Flutter — Deep linking e navigazione annidata](https://docs.flutter.dev/ui/navigation)
- ROADMAP: Fase 4, Settimana 20 (Navigation & First Screens — qui portata alla forma finale)
