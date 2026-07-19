# 🎬 Guida alla demo

Come avviare il progetto e cosa mostrare, in ordine di effetto.

Il progetto ha **due client sullo stesso backend**: l'app Flutter (`frontend/`,
mobile) e la webapp React/TypeScript (`webapp/`, desktop). Si possono mostrare
separatamente, ma il momento migliore è **affiancarli** — vedi §6.

## Prima della demo

Quattro terminali, nell'ordine. La prima compilazione web di Flutter richiede
~1 minuto: avvia tutto **prima** che inizi la demo.

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

# Terminale 3 — Webapp (client web)
cd webapp
npm install                  # solo la prima volta
npm run dev                  # -> http://localhost:5173

# Terminale 4 — Frontend Flutter (client mobile)
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
> La webapp non ha questo problema: Vite serve e basta, il browser lo apri tu.

> **Demo pulita?** Il volume Docker conserva i dati tra i riavvii (utenti
> di prova inclusi). Per ripartire da zero:
> `docker compose down -v && docker compose up -d`, poi riavvia il backend
> (Flyway ricrea lo schema da solo).

> **Dati già pronti.** Se vuoi entrare e trovare la lista popolata invece di
> creare tutto a mano, registra un utente e crea qualche task con scadenze
> diverse (ieri, oggi, domani, fra 4 giorni, senza data, uno completato): è
> quello che serve per far vedere raggruppamenti, calendario e dashboard.

---

## A. Demo della webapp (client web)

Percorso consigliato: **colpo d'occhio → filtri → liste e tag → scadenze →
calendario → dashboard**, con le differenze rispetto al mobile raccontate
mentre si vedono.

### A0. Il colpo d'occhio
- Login su <http://localhost:5173>. La schermata è una card stretta e centrata:
  un form di due campi largo quanto uno schermo desktop è solo faticoso.
- In alto a destra il **toggle tema**: passa a scuro. Ricarica la pagina — il
  tema resta, e non c'è lampo di tema sbagliato al primo render.
- Fai notare la **barra laterale sempre visibile**: sul telefono le stesse voci
  stanno in una barra in basso più un drawer da aprire col dito; qui c'è spazio,
  e nasconderle sarebbe un peggioramento gratuito.

### A1. Filtri, ricerca, ordinamento
- Premi **`/`**: il cursore salta nella ricerca. Scrivi qualcosa e guarda la
  tab Network di DevTools: **una sola chiamata**, dopo la pausa, non una per
  tasto.
- **Chip** di stato e priorità: sono a selezione singola perché l'API accetta un
  valore solo — l'interfaccia non promette ciò che il backend non sa fare.
- Menu **ordina**: scegliendo "Titolo A-Z" le sezioni per scadenza **spariscono**
  e la lista diventa piatta. È voluto: l'utente ha chiesto un altro criterio.

### A2. Liste e tag
- Clicca una lista nella barra laterale e **guarda l'indirizzo**:
  `/tasks?list=<id>`. Copia il link, aprilo in una scheda nuova: sei già lì.
  Premi Indietro: torni a "Tutte le attività". Sul web lo stato condiviso è
  l'URL, non uno store globale.
- "Nuova lista" → nome e 8 colori preset. "Gestisci tag" → crea, **rinomina**
  (funzione che nel client Flutter non c'è ancora), elimina.
- Prova a creare un tag con un nome già usato: il 409 compare **dentro il
  dialogo**, che resta aperto con quello che avevi scritto.

### A3. Scadenze intelligenti
- Con task a scadenze diverse la lista si raggruppa in **In ritardo / Oggi /
  Domani / Questa settimana / Più avanti / Senza scadenza / Completati**, con
  badge di conteggio e la data in rosso su ciò che è in ritardo.
- Passa il mouse su una card: compare il **cestino** (con conferma). È il
  sostituto dello swipe, che con un mouse non esiste — ma è raggiungibile anche
  da tastiera.

### A4. Calendario
- Tab **Calendario**: pallino sui giorni con task, click su un giorno → i suoi
  task sotto, toggle **Mese / 2 settimane / Settimana**, "Aggiungi" apre
  l'editor con la data già impostata.
- Dettaglio da raccontare: il calendario **ignora i filtri** della lista. Un
  mese bucato perché è attivo un chip non sarebbe una panoramica.

### A5. Dashboard
- Quattro numeri (Totali / Completati / In ritardo / Oggi), il grafico a barre
  dei **completati per settimana** e la **ripartizione per priorità**.
- Il pezzo interessante: i colori dell'anello **non** sono quelli delle pillole.
  Validati come palette da grafico, verde e ambra risultano quasi identici sotto
  daltonismo (ΔE 0.7). Sulle pillole non è un problema — c'è il testo accanto —
  in un anello lo spicchio è solo colore. Quindi: rampa a una tinta, che mostra
  anche l'ordine Bassa→Alta. Dettagli in `journal/C57`.

### A6. Errori e sessione
- Completa un task con il backend spento (`Ctrl+C` sul terminale 2): la spunta
  si accende, poi torna indietro **e appare un avviso**. L'ottimismo senza
  spiegazione sarebbe un'app che si comporta a caso.
- Logout dalla barra laterale: torni al login e la cache viene svuotata — il
  prossimo utente non vede nemmeno per un istante i task del precedente.

---

## B. Demo del client Flutter (mobile)

Stessi flussi, forma da telefono: **tema scuro → filtri e ricerca → liste e tag
→ scadenze intelligenti → calendario → dashboard**.

### B0. Dark mode e design
- In alto a destra (o dal drawer con l'hamburger ☰) il **toggle tema**:
  passa a scuro. Palette coerente, card, chip colorati. Riavvia l'app:
  il tema resta (persistito).

### B1. Filtri, ricerca, ordinamento
- Sopra la lista: barra di **ricerca** (digita: una sola chiamata dopo la
  pausa, non a ogni tasto), **chip** di stato/priorità, menu **ordina**
  (scadenza, priorità, titolo). Tutto filtra lato server.

### B2. Liste e tag
- Apri il **drawer** (☰): "Nuova lista" con 8 colori preset; seleziona
  una lista → la lista dei task si filtra, il titolo cambia.
- "Gestisci tag" → crea qualche tag colorato.
- Apri un task in modifica: **dropdown lista** e **chip tag** multi-select.
- I tag compaiono sulle card; una chip tag nella barra filtri filtra per
  tag. (Prova a creare un tag con nome duplicato in Swagger → 409.)

### B3. Scadenze intelligenti
- Crea task con scadenze diverse (ieri, oggi, domani, tra 4 giorni, senza
  data): la lista si raggruppa in **In ritardo / Oggi / Domani / Questa
  settimana / Più avanti / Senza scadenza**, con badge di conteggio; i
  task in ritardo hanno la data in rosso.

### B4. Calendario
- Tab **Calendario**: i giorni con task hanno un pallino; tocca un giorno
  → i suoi task sotto; il toggle in alto cambia **Mese / 2 settimane /
  Settimana**; il **+** crea un task con la data già impostata.

### B5. Dashboard
- Tab **Dashboard**: 4 numeri (Totali/Completati/In ritardo/Oggi), il
  grafico a barre dei **completati per settimana**, il **donut** per
  priorità. Completa qualche task e premi refresh per vederli aggiornarsi.

---

## 6. I due client insieme (il momento migliore)

Metti le due finestre affiancate — <http://localhost:5173> e
<http://localhost:5555> — **con lo stesso utente**.

1. **Stesso backend, stessi dati.** Crea un task nella webapp, ricarica il
   client Flutter: c'è. Nessuna sincronizzazione speciale, è la stessa API.
2. **Stesso feeling, forma diversa.** Le due schermate si somigliano perché i
   colori sono gli stessi: quelli che Material 3 genera dal seed `#4F46E5` del
   client Flutter, estratti una volta e condivisi. Ma la navigazione è diversa
   di proposito, e ogni differenza è argomentata nel journal.
3. **Il colpo di scena — una sorgente, due app.** Apri `tokens/tokens.json`,
   cambia un colore (per esempio uno swatch delle liste), poi:

   ```bash
   node tokens/generate.mjs        # aggiorna Dart e CSS insieme
   node tokens/generate.mjs --check # in CI: fallisce se qualcuno li modifica a mano
   ```

   La webapp si aggiorna a caldo, il client Flutter con `R` nel suo terminale.
   Un valore, un posto, due app.
4. **La logica di dominio è dimostrata equivalente, non tradotta.** Le stesse
   14 golden fixture in `fixtures/` sono verificate da entrambe le suite:

   ```bash
   cd frontend && flutter test test/domain/golden_fixtures_test.dart
   cd webapp   && npm test -- golden-fixtures
   ```

   I due report elencano le stesse frasi. Se una delle due implementazioni
   deriva, il test dell'altra lo dice — a ogni esecuzione, non una volta sola
   al momento della traduzione. Il ragionamento sta in `journal/C61`.

---

## Flussi base (valgono per entrambi i client)

### F1. Registrazione e route guard
- L'app si apre **sul login**: `/tasks` è protetta, il router fa redirect.
- Prova una password di 6 caratteri → la validazione blocca il form
  *prima* di toccare il server.
- Registrati con dati validi → atterri direttamente sulla lista (vuota).
- **Solo webapp**: apri `/dashboard` da non autenticato, fai login → atterri
  sulla **dashboard**, non sulla lista. L'indirizzo richiesto viene conservato.

### F2. CRUD completo
- **Quick-add**: solo il titolo → Invio. Creazione al volo.
- **Form completo**: dall'aggiunta rapida, l'icona accanto apre l'editor con
  descrizione, priorità, scadenza, lista e tag.
- **Checkbox** su una riga → il task va in DONE con lo strikethrough
  (e resta DONE dopo un refresh: è persistito).
- **Click/tap sulla riga** → dettaglio → modifica → eliminazione con conferma.
- Eliminazione: **swipe** su Flutter, **cestino su hover** sulla webapp.

### F3. Il pezzo forte: isolamento tra utenti
- Apri una **finestra in incognito** su uno dei due client.
- Registra un secondo utente: la sua lista è vuota, i task del primo
  utente non esistono per lui.
- Sotto il cofano: ogni query è scoped per utente; chiedere il task di un
  altro risponde **404, mai 403** — l'API non rivela nemmeno che esiste
  (vedi `TaskService.requireOwnTask` nel backend).

### F4. Il refresh token invisibile
- L'access token dura **15 minuti**. Se l'app resta aperta oltre, alla
  prima azione: 401 → chiamata automatica a `/api/v1/auth/refresh` →
  replay della richiesta originale. L'utente non vede nulla.
- Con DevTools aperto (tab Network) la sequenza è visibile.
- Per non aspettare 15 minuti in demo: raccontalo mostrando
  `frontend/lib/core/network/auth_interceptor.dart` (7 unit test) o
  `webapp/src/lib/auth/refresh.ts` (8 test). Il refresh token **ruota** a ogni
  uso: riusare quello vecchio dà 401.
- **Il dettaglio che vale la pena raccontare**: la rotazione impone di
  serializzare i refresh. Se la pagina carica task, liste e tag insieme e tutti
  e tre vanno in 401, tre refresh paralleli brucerebbero il token e
  butterebbero fuori l'utente. Flutter lo risolve con `QueuedInterceptor`, la
  webapp condividendo la promessa in volo (`journal/C44`).

### F5. Swagger: l'API autodocumentata
- Apri <http://localhost:8081/swagger-ui.html>.
- `POST /api/v1/auth/login` da Swagger → copia l'`accessToken` → pulsante
  **Authorize** → incollalo.
- `GET /api/v1/tasks` → gli stessi dati che vedi nelle app.
- Prova un endpoint senza token → 401 col body JSON standard.
- Bonus: è da qui che la webapp **genera i suoi tipi** (`npm run generate:api`
  legge `/v3/api-docs`). Il contratto del backend diventa errori di
  compilazione nel client.

### F6. Errori ben fatti
- Login con password sbagliata → messaggio del server (401, senza distinguere
  "email inesistente" da "password errata": anti user-enumeration).
- Registrazione con email già usata → 409, mostrato **sul campo email**.
- Stesso formato di errore ovunque:
  `{timestamp, status, error, message, path, fieldErrors?}`.

## Da mostrare nel codice

| Cosa | Dove | Perché |
|------|------|--------|
| Il journal | [`journal/README.md`](journal/README.md) | 61 pagine, una per commit: cosa/perché/come + ciclo TDD + link. Da leggere in ordine con `git show <hash>` a fianco |
| I test backend | `cd backend && ./gradlew test` | ~90 test; avvia PostgreSQL veri in container (Testcontainers) |
| I test Flutter | `cd frontend && flutter test` | 142 test tra unit e widget |
| I test webapp | `cd webapp && npm test` | 168 test, quasi tutti di flusso: montano l'app vera con rotte, guard e provider |
| Il test end-to-end | `backend/src/test/java/com/smarttodo/AuthFlowIT.java` | Si legge come una storia: Alice crea, Bob non vede, il token ruota |
| I token condivisi | [`tokens/tokens.json`](tokens/tokens.json) + `tokens/generate.mjs` | Una sorgente, due generatori: `journal/C60` |
| Le golden fixture | [`fixtures/README.md`](fixtures/README.md) | L'equivalenza fra i due domini, dimostrata: `journal/C61` |
| Le divergenze volute | [`webapp/README.md`](webapp/README.md) | Ogni differenza dal mobile, con la entry che la argomenta |

## Troubleshooting rapido

| Sintomo | Causa probabile | Fix |
|---------|-----------------|-----|
| `bootRun` fallisce subito | DB non partito o porta occupata | `docker compose ps`; la API usa 8081 (`SERVER_PORT` per cambiarla) |
| Gradle: "JAVA_HOME is not set" | Shell nuova senza export | `export JAVA_HOME="$(asdf where java)"` |
| Login dall'app: "connection error" | Backend giù, o CORS | Verifica `curl localhost:8081/health`; l'origine dev'essere `http://localhost:*` |
| L'app Flutter punta all'API sbagliata | Default `localhost:8081` | `flutter run --dart-define=API_BASE_URL=http://host:porta` |
| La webapp punta all'API sbagliata | Default `localhost:8081` | `VITE_API_BASE_URL=http://host:porta npm run dev` (vedi `webapp/.env.development`) |
| `-d chrome`: "Unable to connect to Chrome debug port" | WSL2 + Chrome di Windows: la debug port è sul lato Windows | Usa `flutter run -d web-server --web-port 5555` e apri il browser a mano |
| La webapp non si apre da Windows | WSL2 non sta inoltrando `localhost` | `npm run dev -- --host` e usa l'indirizzo `Network:` stampato da Vite; in quel caso passa anche `VITE_API_BASE_URL` con lo stesso host |
| Webapp: errori di tipo dopo modifiche al backend | Lo schema generato è vecchio | Backend acceso, poi `cd webapp && npm run generate:api` |
| `npm run check:tokens` fallisce | Qualcuno ha modificato un file generato a mano | `node tokens/generate.mjs` e ricommitta i generati |
