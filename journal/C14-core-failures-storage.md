# C14 — Core: failures tipizzate e storage sicuro dei token

## Cosa è stato fatto

- `core/error/failures.dart`: gerarchia **sealed** `Failure` —
  `NetworkFailure`, `UnauthorizedFailure`, `NotFoundFailure`,
  `ServerFailure` — con factory `Failure.fromDio(DioException)` che
  traduce gli errori HTTP grezzi in fallimenti di dominio, estraendo il
  `message` dall'`ErrorResponse` del backend quando c'è (il contratto
  unico di C10 paga qui il suo primo dividendo).
- `core/storage/token_storage.dart`: `TokenStorage` avvolge
  `FlutterSecureStorage` — save/read/clear della coppia di token, unico
  posto che conosce le chiavi — esposto come provider Riverpod.
- `core/constants/api_constants.dart`: `baseUrl` da
  `String.fromEnvironment('API_BASE_URL')` con default
  `http://localhost:8081` (la porta scelta in C08).
- 10 test scritti prima: 6 sul mapper (timeout→Network, 401→Unauthorized,
  404→NotFound, altri→Server col messaggio del backend, fallback
  generico), 4 sul TokenStorage con `FlutterSecureStorage` mockato
  (mocktail).

## Perché

**Perché tradurre le `DioException` in `Failure`?** Se le eccezioni Dio
arrivassero fino alla UI, ogni schermata dovrebbe conoscere Dio (status
code, `DioExceptionType`...) — un accoppiamento al framework HTTP sparso
ovunque. Con la traduzione al confine del layer data, la UI ragiona su
quattro casi di dominio con messaggi già pronti da mostrare. È lo stesso
principio dei port del backend, applicato agli errori.

**Perché `sealed`?** Un `switch` su una classe sealed è *esaustivo*: se
domani si aggiunge `ValidationFailure`, il compilatore segnala ogni punto
del codice che non la gestisce. Con una gerarchia aperta quei punti si
scoprirebbero a runtime.

**Perché `FlutterSecureStorage` e non `SharedPreferences`?**
`SharedPreferences` è un file in chiaro leggibile da chiunque acceda al
dispositivo. `flutter_secure_storage` delega agli store di piattaforma
(Keychain su iOS, Keystore su Android, libsecret su Linux, WebCrypto su
web). Per un refresh token che vale 7 giorni di accesso, è il minimo.
(La ROADMAP lo mette tra gli errori da evitare, Fase 5.)

**Perché `--dart-define` per il baseUrl?** È il gemello di
`${APP_JWT_SECRET:...}` nel backend: il valore committato è il default di
sviluppo, l'override arriva dall'ambiente di build senza toccare il
codice. Un'app installata su un telefono fisico punterà all'IP del PC con
un flag, non con un edit.

## Come funziona

- `Failure.fromDio` fa switch sul `DioExceptionType`: i tipi di
  connessione/timeout diventano `NetworkFailure` (il messaggio invita a
  controllare la rete); `badResponse` guarda lo status e prova a leggere
  `data['message']` — che esiste sempre, perché il backend risponde
  sempre con l'`ErrorResponse` standard. Contratto di errore unico lato
  server = un solo parser lato client.
- `TokenStorage` riceve lo storage nel costruttore (dependency injection
  manuale): nei test si passa il mock, in produzione il provider Riverpod
  costruisce quello vero. Stesso pattern dei port/adapter, in miniatura.
- I test usano **mocktail**: `when(() => storage.read(key: ...))` /
  `verify(...)` — l'equivalente Dart di Mockito, senza codegen.

## Il ciclo TDD in questo commit

1. **Rosso** — i due file di test non compilavano (le classi non
   esistevano); nota: in Flutter un errore di compilazione in *un* file di
   test manda in rosso l'intero batch, `app_test.dart` incluso.
2. **Verde** — le tre classi core; 11 test verdi totali.
3. **Refactor** — l'estrazione del messaggio backend è isolata in
   `_backendMessage`, un solo punto da toccare se il contratto cambia.

## Concetti chiave

- **Error translation al confine**: gli errori del framework non superano
  il layer data.
- **Sealed class + switch esaustivo**: il compilatore come rete di
  sicurezza sui casi mancanti.
- **Secure storage**: i segreti stanno negli store di piattaforma.
- **Configurazione by environment**: stesso principio su backend e
  frontend.

## Per approfondire

- [Dart — sealed classes e pattern matching](https://dart.dev/language/class-modifiers#sealed)
- [mocktail](https://pub.dev/packages/mocktail)
- [flutter_secure_storage — piattaforme e limiti](https://pub.dev/packages/flutter_secure_storage) (nota: su web è sperimentale)
- [Flutter — dart-define](https://dart.dev/guides/environment-declarations)
- ROADMAP: Fase 5, Settimana 23 (domain failures) e kata 5.3 (Secure Storage Kata)
