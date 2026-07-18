# C13 — Scaffold Flutter con le dipendenze della Clean Architecture

## Cosa è stato fatto

- `flutter create --org com.smarttodo --project-name smart_todo_app
  --platforms web,linux frontend` — solo web e Linux: sono le piattaforme
  su cui questo progetto viene davvero sviluppato e provato; Android/iOS
  si possono aggiungere in ogni momento con `flutter create .`.
- Dipendenze aggiunte con `flutter pub add` (versioni risolte da pub, non
  copiate da tutorial): **flutter_riverpod 3.x** (state management),
  **dio 5.x** (HTTP client), **go_router 17.x** (navigazione dichiarativa),
  **freezed + json_annotation** (modelli immutabili e serializzazione via
  codegen), **flutter_secure_storage 10.x** (persistenza sicura dei token).
  Dev: **build_runner** (il motore di codegen), **freezed/json_serializable**
  (i generatori), **mocktail** (mock nei test).
- Il counter di default è stato sostituito da `app.dart` (MaterialApp
  minimale) + `main.dart` (`ProviderScope` alla radice), e il test template
  del counter — che non c'entrava nulla — da uno smoke test vero che
  avvia l'app e verifica che renderizzi.

## Perché

**Perché queste librerie e non altre?** Sono quelle prescritte da
`doc/SPEC.md`, ma vale la pena capire il razionale di ciascuna:
- *Riverpod* rende lo stato dichiarativo, testabile senza widget tree
  (`ProviderContainer` nei test) e compile-safe (niente `BuildContext`
  passato in giro come con Provider classico).
- *Dio* rispetto al pacchetto `http` aggiunge interceptor (fondamentali per
  il refresh automatico del token, C15), timeout configurabili e
  cancellazione.
- *Freezed* genera `copyWith`, uguaglianza strutturale e union type per
  modelli immutabili: a mano sarebbero decine di righe a classe, sempre
  leggermente sbagliate.
- *GoRouter* permette route dichiarative con `redirect` centralizzato — è
  lì che vivrà la guardia di autenticazione (C17).
- *flutter_secure_storage* usa gli store di piattaforma (libsecret su
  Linux, WebCrypto su web) invece di `SharedPreferences`, che è un file in
  chiaro: la ROADMAP elenca "storing tokens in SharedPreferences" tra gli
  errori da evitare.

**Perché `ProviderScope` già in `main.dart`?** È il contenitore radice da
cui ogni provider Riverpod viene risolto. Metterlo subito significa che
ogni schermata futura nasce già dentro l'albero giusto.

**Perché buttare il test del counter?** Un test che verifica un contatore
inesistente è peggio di nessun test: fallirebbe al primo `flutter test`
dando l'impressione che il progetto sia rotto. La suite deve riflettere
l'app reale, a ogni commit.

## Come funziona

- `pubspec.yaml` è l'equivalente del `build.gradle.kts`: dichiara le
  dipendenze con vincoli semver (`^3.3.2` = "3.x, almeno 3.3.2");
  `pubspec.lock` blocca le versioni esatte per build riproducibili (e si
  committa, per le app).
- `flutter pub add` risolve e aggiorna entrambi i file — meglio che
  copiare versioni da tutorial vecchi.
- Attenzione alle *versioni major recenti*: Riverpod 3 deprca
  `StateNotifier` a favore di `Notifier`/`AsyncNotifier`; Freezed 3
  richiede `abstract`/`sealed` sulle classi annotate. I tutorial pre-2024
  mostrano API che qui non compilano.

## Il ciclo TDD in questo commit

Lo smoke test (`app_test.dart`) è il "contextLoads" del frontend: pompa
l'app nel tester e verifica che renderizzi. Sembra banale ma valida
l'intera catena — dipendenze risolte, codice che compila, widget tree che
si costruisce. `flutter analyze` pulito + `flutter test` verde +
`flutter run -d chrome` avviabile = il criterio "runnabile" per ogni
commit frontend da qui in poi.

## Concetti chiave

- **pubspec.yaml/lock**: il contratto delle dipendenze e il suo lucchetto.
- **Codegen** (`build_runner`): parte del codice Dart sarà *generato*
  (`*.freezed.dart`, `*.g.dart`) — si rigenera con un comando, si committa.
- **ProviderScope**: la radice di ogni stato Riverpod.
- **La suite riflette l'app**: mai lasciare test di template morti.

## Per approfondire

- [Riverpod docs](https://riverpod.dev/) (in particolare "Why Riverpod?")
- [Dio](https://pub.dev/packages/dio) — interceptor e configurazione
- [Freezed](https://pub.dev/packages/freezed) — data class e union
- [GoRouter](https://pub.dev/packages/go_router)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- ROADMAP: Fase 4, Settimana 19 (Clean Architecture Setup)
