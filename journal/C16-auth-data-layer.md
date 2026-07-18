# C16 — Auth data layer: modelli, datasource, repository

## Cosa è stato fatto

Prima feature con la struttura Clean Architecture completa
(`features/auth/{domain,data}`):

- **Domain**: entità `User` (pura, niente JSON) e interfaccia
  `AuthRepository` — il boundary che la UI userà: `register`, `login`,
  `hasSession`, `logout`.
- **Data**: `UserModel` e `AuthResponseModel` (freezed +
  json_serializable, speculari al DTO `AuthResponse` del backend),
  `AuthRemoteDataSource` (le due chiamate Dio), `AuthRepositoryImpl` che
  orchestra: chiama il datasource, **salva la coppia di token** nel
  `TokenStorage`, converte il modello in entità, traduce le
  `DioException` in `Failure`.
- Codegen: primo `dart run build_runner build` del progetto — nascono i
  `*.freezed.dart` e `*.g.dart` (committati). `build.yaml` con
  `explicit_to_json: true`.
- 7 test scritti prima: round-trip JSON dei modelli, login/register che
  salvano i token e restituiscono l'entità, errore 401 mappato a
  `UnauthorizedFailure` col messaggio del backend (e nessun salvataggio di
  token), `hasSession`, `logout`.

## Perché

**Perché `UserModel` E `User`?** Stessa separazione di C04 sul backend
(entity JPA vs record di dominio), lato client: il *model* conosce il JSON
e la forma dell'API; l'*entità* è ciò su cui ragiona la UI. Se il backend
rinominasse un campo, cambierebbero model e mapper — non le schermate.
Su un'app piccola sembra cerimonia; è il tipo di cerimonia che costa 20
righe oggi e risparmia un refactoring trasversale domani.

**Perché il repository salva i token, e non il datasource o il
notifier?** Il datasource fa *solo* HTTP (facile da mockare); il notifier
(C17) farà *solo* stato UI. "Autenticarsi" = ottenere la risposta E
persistere la sessione: è un'operazione sola, e il repository è il posto
dove le due metà si incontrano. Il test lo inchioda: login riuscito →
`saveTokens` chiamato; login fallito → *mai* chiamato.

**Perché niente classi use-case separate (`LoginUseCase` ecc.) come
prescriverebbe la Clean Architecture ortodossa?** Taglio deliberato:
sarebbero wrapper a un metodo che delegano al repository, puro
boilerplate finché non esiste logica da mettere in mezzo. L'interfaccia
`AuthRepository` in `domain/` È il boundary. Se un giorno servisse
logica pre/post chiamata, estrarre lo use case è meccanico. (Il backend
ha tenuto i port espliciti perché lì la ROADMAP li usa come strumento
didattico; qui vince la pragmatica — l'importante è *sapere* cosa si sta
saltando e perché.)

**Perché il round-trip `toJson` nel test dei modelli?** Ha subito pagato:
json_serializable di default serializza gli oggetti annidati come
riferimenti (non richiama `toJson` sul nested `user`). Il test è fallito
e ha portato alla configurazione `explicit_to_json: true` in `build.yaml`.
Senza quel test, il bug sarebbe emerso alla prima POST col body sbagliato.

## Come funziona

- **Freezed 3**: `abstract class UserModel with _$UserModel` + factory
  const = data class immutabile con `==`, `hashCode`, `copyWith` generati.
  Il costruttore privato `const UserModel._()` è ciò che permette di
  aggiungere metodi propri (`toEntity`).
- **Il codegen** produce `part` files: `user_model.freezed.dart` (la
  classe) e `user_model.g.dart` (fromJson/toJson). Si rigenerano con
  build_runner a ogni modifica dei modelli; si committano per non
  obbligare chi clona a rigenerarli prima ancora di compilare.
- `_authenticate` è il template method privato che unifica login e
  register: stessa sequenza (chiama → salva → mappa → traduci errori),
  due endpoint.

## Il ciclo TDD in questo commit

1. **Rosso** — 7 test su classi inesistenti.
2. **Verde** — dopo l'implementazione, un rosso *residuo* prezioso: il
   round-trip JSON che ha scovato il problema del nested `toJson`.
3. **Refactor** — login/register unificati in `_authenticate`.

## Concetti chiave

- **Model vs entity**: il JSON si ferma al layer data.
- **Il repository come orchestratore**: rete + persistenza locale in
  un'unica operazione atomica dal punto di vista del chiamante.
- **Codegen committato**: build riproducibile senza step nascosti.
- **Tagli dichiarati**: saltare gli use-case wrapper è una scelta, non
  una dimenticanza.

## Per approfondire

- [Freezed — data classes](https://pub.dev/packages/freezed)
- [json_serializable — explicit_to_json](https://pub.dev/packages/json_serializable#build-configuration)
- [Reso Coder — Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/) (il riferimento classico per questa struttura)
- ROADMAP: Fase 5, Settimane 21 e 23 (Auth Data Layer, repository pattern), kata 4.3 (Freezed Model Kata)
