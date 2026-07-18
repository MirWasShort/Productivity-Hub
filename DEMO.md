# 🎬 Guida alla demo

Come avviare il progetto e cosa mostrare, in ordine di effetto.

## Prima della demo

Tre terminali, nell'ordine. La prima compilazione web richiede ~1 minuto:
avvia tutto **prima** che inizi la demo.

```bash
# Terminale 1 — Database
cd Productivity-Hub
docker compose up -d
docker compose ps            # aspetta lo stato "healthy"

# Terminale 2 — Backend
cd backend
export JAVA_HOME="$(asdf where java)"    # Gradle vuole JAVA_HOME, gli shim asdf non bastano
./gradlew bootRun                        # pronto a "Started SmartTodoBackendApplication"
curl localhost:8081/health               # -> {"status":"UP"}

# Terminale 3 — Frontend
cd frontend
flutter run -d web-server --web-port 5555
# poi apri TU il browser su http://localhost:5555
```

> **Perché `web-server` e non `-d chrome`?** Su WSL2 con il Chrome di
> Windows (`CHROME_EXECUTABLE=/mnt/c/...`), `-d chrome` fallisce con
> *"Unable to connect to Chrome debug port … Connection refused"*: la
> porta di debug di Chrome vive sul lato Windows e il processo Linux non
> la raggiunge. Con `web-server` Flutter serve solo l'app e il browser lo
> apri a mano — il forwarding localhost Windows→WSL funziona in quella
> direzione. Hot reload/restart si fanno dal terminale (`r` / `R`).

> **Demo pulita?** Il volume Docker conserva i dati tra i riavvii (utenti
> di prova inclusi). Per ripartire da zero:
> `docker compose down -v && docker compose up -d`, poi riavvia il backend
> (Flyway ricrea lo schema da solo).

## Scaletta dei flussi

### 1. Registrazione e route guard
- L'app si apre **sul login**: `/tasks` è protetta, il router fa redirect.
- Prova una password di 6 caratteri → la validazione blocca il form
  *prima* di toccare il server.
- Registrati con dati validi → atterri direttamente sulla lista (vuota).

### 2. CRUD completo
- **Quick-add**: `+` → solo il titolo → invio. Creazione al volo.
- **Form completo**: `+` → icona "più opzioni" → descrizione, priorità,
  scadenza.
- **Checkbox** su una riga → il task va in DONE con lo strikethrough
  (e resta DONE dopo un refresh: è persistito).
- **Tap sulla riga** → dettaglio → matita per modificare → cestino con
  dialog di conferma.
- **Swipe verso sinistra** → delete immediata (ottimistica: la riga
  sparisce subito, il server conferma dietro le quinte).
- **Pull-to-refresh** sulla lista.

### 3. Il pezzo forte: isolamento tra utenti
- Apri una **finestra in incognito** su `http://localhost:5555`.
- Registra un secondo utente: la sua lista è vuota, i task del primo
  utente non esistono per lui.
- Sotto il cofano: ogni query è scoped per utente; chiedere il task di un
  altro risponde **404, mai 403** — l'API non rivela nemmeno che esiste
  (vedi `TaskService.requireOwnTask` nel backend).

### 4. Il refresh token invisibile
- L'access token dura **15 minuti**. Se l'app resta aperta oltre, alla
  prima azione: 401 → chiamata automatica a `/api/v1/auth/refresh` →
  replay della richiesta originale. L'utente non vede nulla.
- Con DevTools aperto (tab Network) la sequenza è visibile.
- Per non aspettare 15 minuti in demo: raccontalo mostrando
  `frontend/lib/core/network/auth_interceptor.dart` (e i suoi 7 unit
  test). Bonus: il refresh token **ruota** a ogni uso — riusare quello
  vecchio dà 401 (anti-furto).

### 5. Swagger: l'API autodocumentata
- Apri <http://localhost:8081/swagger-ui.html>.
- `POST /api/v1/auth/login` da Swagger → copia l'`accessToken` → pulsante
  **Authorize** → incollalo.
- `GET /api/v1/tasks` → gli stessi dati che vedi nell'app.
- Prova un endpoint senza token → 401 col body JSON standard.

### 6. Errori ben fatti
- Login con password sbagliata → SnackBar col messaggio del server
  (401, senza distinguere "email inesistente" da "password errata":
  anti user-enumeration).
- Registrazione con email già usata → 409.
- Stesso formato di errore ovunque:
  `{timestamp, status, error, message, path, fieldErrors?}`.

## Da mostrare nel codice

| Cosa | Dove | Perché |
|------|------|--------|
| Il journal | [`journal/README.md`](journal/README.md) | 21 pagine, una per commit: cosa/perché/come + ciclo TDD + link. Da leggere in ordine con `git show <hash>` a fianco |
| I test backend | `cd backend && ./gradlew test` | ~60 test; avvia PostgreSQL veri in container (Testcontainers) |
| I test frontend | `cd frontend && flutter test` | 59 test tra unit e widget |
| Il test end-to-end | `backend/src/test/java/com/smarttodo/AuthFlowIT.java` | Si legge come una storia: Alice crea, Bob non vede, il token ruota |
| Il confronto | `git diff --stat de5bd9b..HEAD` | La distanza dalla vecchia app (6 file, delete che cancellava l'intero DB) |

## Troubleshooting rapido

| Sintomo | Causa probabile | Fix |
|---------|-----------------|-----|
| `bootRun` fallisce subito | DB non partito o porta occupata | `docker compose ps`; la API usa 8081 (`SERVER_PORT` per cambiarla) |
| Gradle: "JAVA_HOME is not set" | Shell nuova senza export | `export JAVA_HOME="$(asdf where java)"` |
| Login dall'app: "connection error" | Backend giù, o CORS | Verifica `curl localhost:8081/health`; l'origine dev'essere `http://localhost:*` |
| L'app punta all'API sbagliata | Default `localhost:8081` | `flutter run --dart-define=API_BASE_URL=http://host:porta` |
| `-d chrome`: "Unable to connect to Chrome debug port" | WSL2 + Chrome di Windows: la debug port è sul lato Windows | Usa `flutter run -d web-server --web-port 5555` e apri il browser a mano |
