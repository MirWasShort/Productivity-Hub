# 🧭 Percorso di apprendimento — Parte II: il fullstack moderno

> **Prerequisito:** aver completato [`LEARNING_PATH.md`](LEARNING_PATH.md) con
> tutte le verifiche verdi. A quel punto sai *costruire* un sistema fullstack.
> Questo documento copre il passo successivo: saperlo **mettere in produzione,
> farlo reggere, farlo evolvere** — e restare rilevante in un mestiere che nel
> frattempo ha incorporato l'AI. È la differenza fra "so programmare" e
> "faccio lo sviluppatore di mestiere".

**Ritmo assunto:** stesso della Parte I (~25–40 h/settimana) → **~20–24 settimane**.
Ma qui c'è una differenza importante: la Parte I era una scala, ogni gradino
poggiava sul precedente. La Parte II è **un tronco + rami**: le Parti 5 e 6 vanno
fatte in ordine (sono il tronco), le Parti 7, 8 e 9 si possono alternare e
intrecciare — anche con un lavoro o una ricerca di lavoro in corso, che di
queste fasi è il complemento naturale.

**Il laboratorio resta lo stesso.** Quasi ogni fase usa il progetto che hai
costruito nella Parte I come banco di prova: lo deployerai, lo osserverai, lo
attaccherai, lo porterai al limite, gli aggiungerai un'anima AI. Un progetto che
evolve per mesi vale, in un colloquio, dieci tutorial completati.

---

## Soldi in cambio di tempo: la lista della spesa

La Parte I viveva quasi solo di risorse gratuite e delle tue due sottoscrizioni.
Da qui in poi i **libri giusti** diventano l'investimento a più alto rendimento:
condensano decenni di esperienza in giorni di lettura. Questa è la lista completa,
in ordine di priorità — comprali man mano che le fasi li richiedono, non tutti
subito (prezzi indicativi, carta o ebook):

| Priorità | Libro | Perché vale i soldi | ~Prezzo |
|---|---|---|---|
| 1 | **Designing Data-Intensive Applications, 2ª ed.** (Kleppmann & Riccomini, O'Reilly 2026) | *Il* libro del mestiere, appena aggiornato. Ti dà il modello mentale di ogni sistema che toccherai per i prossimi 15 anni. | ~60 € |
| 2 | **A Philosophy of Software Design, 2ª ed.** (John Ousterhout) | Il miglior rapporto pagine/valore esistente sul design del codice. Si legge in una settimana, cambia come scrivi per sempre. | ~25 € |
| 3 | **Unit Testing: Principles, Practices, and Patterns** (Vladimir Khorikov, Manning) | Dopo mesi di TDD ti dice *quali* test valgono e quali sono zavorra. Sistema ciò che la pratica da sola non insegna. | ~40 € |
| 4 | **High-Performance Java Persistence** (Vlad Mihalcea) | L'autorità mondiale su JPA/Hibernate. Ripaga il prezzo alla prima query lenta risolta in produzione. | ~40 € |
| 5 | **SQL Performance Explained** (Markus Winand) | 200 pagine sugli indici che il 90% degli sviluppatori non ha mai capito. | ~30 € |
| 6 | **Learning Domain-Driven Design** (Vlad Khononov, O'Reilly) | Il DDD moderno senza il misticismo: come scoprire i confini di un dominio e disegnarci sopra l'architettura. | ~45 € |
| 7 | **Refactoring, 2ª ed.** (Martin Fowler) | Il catalogo dei movimenti sicuri per cambiare codice esistente — il lavoro vero è per l'80% questo. | ~50 € |
| 8 | **The Pragmatic Programmer, 20th Anniversary** (Hunt & Thomas) | Il libro sul *mestiere*: atteggiamento, abitudini, carriera. | ~40 € |

Facoltativi mirati: **System Design Interview vol. 1–2** (Alex Xu, ~40 € l'uno)
o l'abbonamento [ByteByteGo](https://bytebytego.com/) (~60 $/anno) se punti a
colloqui in aziende che fanno interview di system design.

E ricorda: **le sottoscrizioni che hai già coprono moltissimo anche qui** —
Frontend Masters ha corsi su AWS, GitHub Actions, Next.js, system design e AI
engineering; Code with Andrea copre animazioni, Firebase e la messa in
produzione di app Flutter. Sono segnalate fase per fase.

### Legenda (come nella Parte I)

| Simbolo | Significato |
|---------|-------------|
| 🆓 | Gratuita |
| ⭐ | Inclusa nella sottoscrizione **Frontend Masters** |
| 🎯 | Inclusa nella sottoscrizione **Code with Andrea** |
| 📕 | Libro / premium a pagamento singolo |

### Mappa del percorso

| Parte | Fasi | Cosa impari | Settimane |
|-------|------|-------------|-----------|
| [5 — In produzione](#parte-5--in-produzione) | F5.1–F5.3 | Deploy, osservabilità, sicurezza applicata | ~5 |
| [6 — Dati sul serio](#parte-6--dati-sul-serio) | F6.1–F6.3 | PostgreSQL avanzato, performance JPA, cache e code | ~4 |
| [7 — Architettura e design](#parte-7--architettura-e-design) | F7.1–F7.4 | Design del codice, testing maturo, DDD, sistemi distribuiti | ~6 |
| [8 — Il web moderno completo](#parte-8--il-web-moderno-completo) | F8.1–F8.3 | Next.js/RSC, performance & a11y, Flutter avanzato | ~4 |
| [9 — AI e carriera](#parte-9--ai-e-carriera) | F9.1–F9.3 | Costruire con gli LLM, sviluppo AI-assistito, portfolio e colloqui | ~4 |

---

## Parte 5 — In produzione

Un sistema che gira solo su `localhost` è un esercizio. Questa parte lo
trasforma in un servizio: raggiungibile, osservabile, difendibile. È la parte
con il maggior salto di identità professionale: da "studente che costruisce" a
"ingegnere che opera".

### F5.1 — Deploy: container, cloud, HTTPS (~2 settimane)

**Obiettivo:** il tuo Productivity-Hub raggiungibile da un URL pubblico con
HTTPS, deployato in modo ripetibile (un comando, non una liturgia).

**Costruisci:**
- `Dockerfile` multi-stage per il backend (build Gradle → immagine JRE minimale)
  e build statica della webapp servita da un web server o da un hosting statico.
- Deploy su un PaaS o un VPS — due strade valide:
  - *PaaS* ([Fly.io](https://fly.io/), [Railway](https://railway.com/)): più veloce,
    impari i concetti senza amministrare macchine;
  - *VPS* (es. Hetzner + [Coolify](https://coolify.io/)): più economico e più
    formativo — ci amministri sopra Postgres, reverse proxy e TLS.
- Configurazione per ambiente (dev/prod) solo via variabili d'ambiente; le
  migrazioni Flyway girano al deploy; un dominio con HTTPS (Let's Encrypt).
- Il workflow CI di F4.2 esteso: sul merge in `main`, build dell'immagine e deploy.

**Risorse:**
1. 🆓 [Docker — Multi-stage builds](https://docs.docker.com/build/building/multi-stage/) e 🆓 [Spring Boot — Container Images](https://docs.spring.io/spring-boot/reference/packaging/container-images/index.html).
2. ⭐ [Deploying Web Applications on AWS, v3 (Steve Kinney)](https://frontendmasters.com/courses/aws-v3/) — anche se non usi AWS: i concetti (DNS, CDN, certificati, IAM) sono universali.
3. ⭐ [Cloud CI/CD with GitHub Actions (Erik Reinert)](https://frontendmasters.com/courses/github-actions/) — porta la CI di F4.2 fino al deploy continuo.
4. 🆓 Le docs del provider scelto (Fly.io e Coolify le hanno ottime).

**Verifica (Definition of Done):**
- [ ] L'app è usabile da un telefono qualsiasi a un URL pubblico, in HTTPS.
- [ ] Un merge in `main` con CI verde arriva in produzione senza passi manuali.
- [ ] Sai fare rollback all'immagine precedente e lo hai provato davvero.
- [ ] Il database di produzione ha un backup automatico e hai provato un restore.

> **💡 Approfondimento — perché il deploy è un problema di ripetibilità.**
> Il nemico non è la complessità del cloud: è il deploy "artigianale" fatto di
> passi a memoria. Tutto ciò che impari qui — container immutabili, config
> nell'ambiente, migrazioni automatiche, rollback — serve a un'unica cosa:
> rendere il rilascio *noioso*. Un rilascio noioso si può fare il venerdì
> pomeriggio; uno artigianale no, e infatti nelle aziende senza queste pratiche
> nessuno rilascia mai il venerdì.

---

### F5.2 — Osservabilità: log, metriche, tracce (~1,5 settimane)

**Obiettivo:** rispondere alla domanda "che sta succedendo in produzione?"
guardando dati, non riavviando a caso.

**Costruisci:**
- Log strutturati (JSON) nel backend, con un **correlation id** per richiesta
  che compare in ogni riga di log di quella richiesta.
- Metriche con Spring Boot Actuator + Micrometer esposte a
  [Prometheus](https://prometheus.io/); dashboard [Grafana](https://grafana.com/)
  (entrambi in Docker Compose accanto all'app) con: richieste/s, latenza p95,
  tasso di errori, connessioni al DB.
- Un alert che scatta davvero (es. tasso di 5xx > 1% per 5 minuti).
- Facoltativo ma consigliato: tracing con [OpenTelemetry](https://opentelemetry.io/docs/)
  per vedere il percorso di una richiesta attraverso i layer.

**Risorse:**
1. 🆓 [Spring Boot — Actuator & Metrics](https://docs.spring.io/spring-boot/reference/actuator/index.html) e [Micrometer docs](https://micrometer.io/docs).
2. 🆓 [Grafana — Get started](https://grafana.com/docs/grafana/latest/getting-started/) + [Prometheus — Getting started](https://prometheus.io/docs/prometheus/latest/getting_started/).
3. 🆓 [Google SRE Book — Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/) — il capitolo che definisce *cosa* vale la pena misurare (i "four golden signals").

**Verifica (Definition of Done):**
- [ ] Da un errore in produzione risali ai log della *singola richiesta* col suo correlation id.
- [ ] La dashboard mostra p95 e tasso d'errore; sai dire qual è la "normalità" del tuo sistema.
- [ ] Hai provocato un guasto di proposito (es. spegnere il DB) e l'alert è arrivato.
- [ ] Sai spiegare la differenza fra log, metrica e traccia, e quando serve ciascuno.

---

### F5.3 — Sicurezza applicata: pensare da attaccante (~1,5 settimane)

**Obiettivo:** passare da "ho applicato le best practice" (Parte I) a "so *come*
si attacca un'app web, quindi so cosa sto difendendo".

**Costruisci:**
- Completa i percorsi principali della
  [PortSwigger Web Security Academy](https://portswigger.net/web-security)
  (gratuita, con laboratori attaccabili veri): SQL injection, XSS, CSRF,
  vulnerabilità di autenticazione, access control / IDOR.
- Audit del tuo Productivity-Hub contro la
  [OWASP Top 10](https://owasp.org/www-project-top-ten/): per ogni voce, scrivi
  dove il tuo sistema è protetto (e *da quale riga di codice*) o dove è esposto.
- Rate limiting sugli endpoint `/auth/**` (era già negli obiettivi della fase 3
  di [ROADMAP.md](ROADMAP.md)) + header di sicurezza sulla webapp (CSP, ecc.).
- Scansione automatica delle dipendenze in CI (Dependabot o `npm audit`/OWASP
  Dependency-Check).

**Risorse:**
1. 🆓 [PortSwigger Web Security Academy](https://portswigger.net/web-security) — la migliore risorsa di sicurezza web esistente, a qualunque prezzo. Fatta dai creatori di Burp Suite.
2. 🆓 [OWASP Top 10](https://owasp.org/www-project-top-ten/) e le [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/) come riferimento permanente.

**Verifica (Definition of Done):**
- [ ] Almeno 15 lab PortSwigger risolti nelle 5 categorie sopra.
- [ ] Il documento di audit OWASP esiste, con riferimenti a file e test del tuo repo.
- [ ] Un brute-force sul login viene rallentato (test che lo dimostra).
- [ ] Sai spiegare perché il tuo backend è immune alla SQL injection *per costruzione* (JPA/parametri bindati) e cosa la reintrodurrebbe.

---

## Parte 6 — Dati sul serio

Il database è quasi sempre il collo di bottiglia e quasi mai il colpevole: il
colpevole è come lo usiamo. Questa parte ti dà quello che distingue un backend
developer medio da uno che i colleghi cercano quando "il sito è lento".

### F6.1 — PostgreSQL avanzato: indici, EXPLAIN, transazioni (~1,5 settimane)

**Obiettivo:** leggere un piano di esecuzione, scegliere gli indici con criterio,
capire cosa fanno davvero le transazioni concorrenti.

**Costruisci:**
- Genera **1 milione di task** finti nel tuo DB (script SQL o `generate_series`).
- Misura le query dei filtri di F1.4 con `EXPLAIN (ANALYZE, BUFFERS)`: trova i
  sequential scan, aggiungi gli indici giusti (composti, parziali), rimisura.
  Documenta il prima/dopo.
- Esperimenti di concorrenza in due sessioni `psql` affiancate: lost update,
  livelli di isolamento, lock espliciti (`SELECT … FOR UPDATE`), un deadlock
  provocato e spiegato.

**Risorse:**
1. 🆓 [Use The Index, Luke!](https://use-the-index-luke.com/) (Markus Winand) — la versione web gratuita del libro: come funzionano gli indici B-tree, spiegato come nessun altro.
2. 📕 **SQL Performance Explained** (Winand) — il libro completo; compralo quando la versione web ti ha convinto (succederà).
3. 🆓 [PostgreSQL — Using EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html) e [Transaction Isolation](https://www.postgresql.org/docs/current/transaction-iso.html) — la documentazione di Postgres è fra le migliori del settore.

**Verifica (Definition of Done):**
- [ ] Su 1M di righe, la ricerca filtrata risponde in decine di ms, e sai dire *perché* leggendo il piano.
- [ ] Sai spiegare quando un indice **non** viene usato (funzioni sulla colonna, `LIKE '%…'`, bassa selettività).
- [ ] Hai riprodotto un lost update e sai due modi per impedirlo (lock pessimista, versione ottimista).

---

### F6.2 — JPA/Hibernate ad alte prestazioni (~1 settimana)

**Obiettivo:** sapere cosa fa Hibernate sotto il cofano e piegarlo alle
prestazioni, invece di subirlo.

**Costruisci:**
- Attiva le statistiche Hibernate e un logger delle query sul tuo backend con il
  dataset da 1M: caccia ogni query superflua.
- Applica dove serve: proiezioni DTO per le letture (invece di entity complete),
  batch di insert/update, paginazione keyset per liste lunghe (invece di
  `OFFSET` profondi), controllo del dirty checking.
- Un test di carico minimo (es. [k6](https://k6.io/), gratuito) su lista e
  ricerca: misura p95 prima e dopo le ottimizzazioni.

**Risorse:**
1. 📕 **High-Performance Java Persistence** (Vlad Mihalcea) — il libro di riferimento assoluto su JPA/Hibernate; l'acquisto tecnico più ripagato di questa parte.
2. 🆓 [Il blog di Vlad Mihalcea](https://vladmihalcea.com/blog/) — moltissimo del libro è anticipato qui.
3. 🆓 [k6 — docs](https://grafana.com/docs/k6/latest/) per i test di carico.

**Verifica (Definition of Done):**
- [ ] Zero query N+1 su tutti gli endpoint (verificato con le statistiche, non a occhio).
- [ ] Un endpoint di lettura è passato a proiezione DTO, con la differenza misurata.
- [ ] Il report del test di carico esiste: richieste/s e p95 prima/dopo.
- [ ] Sai spiegare cos'è il persistence context e quando conviene una query nativa.

---

### F6.3 — Cache, code ed eventi (~1,5 settimane)

**Obiettivo:** i due strumenti che compaiono in ogni architettura reale: una
cache davanti alle letture costose, una coda per il lavoro asincrono — e i loro
prezzi nascosti.

**Costruisci:**
- **Redis** in Docker Compose: cache degli endpoint analytics (i più costosi),
  con invalidazione al completamento di un task e TTL di sicurezza. Metti in
  dashboard il hit ratio (F5.2 paga già i dividendi).
- Una **coda** (RabbitMQ, o in alternativa `@Async` + outbox per iniziare):
  alla registrazione, una "email di benvenuto" (finta: un log) processata in
  asincrono, con retry e coda dei falliti (dead letter).
- Il **transactional outbox pattern**: l'evento si scrive nella stessa
  transazione del dato, un processo lo pubblica dopo — così non esistono email
  per utenti mai salvati né utenti senza email.

**Risorse:**
1. 🆓 [Redis — docs](https://redis.io/docs/latest/) e [Spring — Caching](https://docs.spring.io/spring-boot/reference/io/caching.html).
2. 🆓 [RabbitMQ — Tutorials](https://www.rabbitmq.com/tutorials) — i sei tutorial ufficiali sono eccellenti.
3. 🆓 [microservices.io — Transactional Outbox](https://microservices.io/patterns/data/transactional-outbox.html) (Chris Richardson).

**Verifica (Definition of Done):**
- [ ] La dashboard analytics con cache calda risponde in < 10 ms e il hit ratio è misurato.
- [ ] Un task completato **invalida** la cache giusta (test che lo prova — è lo stesso obbligo di sync di C38, un layer più in basso).
- [ ] Spegni il consumer della coda, registri 5 utenti, lo riaccendi: le 5 email partono. Nessuna persa, nessuna doppia.
- [ ] Sai spiegare i due problemi classici della cache (stale data, stampede) e cosa fa il tuo TTL.

> **💡 Approfondimento — la cache è un debito di coerenza.**
> In C38 avevi imparato che "una cache è un obbligo di sincronizzazione" per la
> cache di TanStack Query. Redis è identico, ma senza framework che ti aiuta:
> ogni cache che aggiungi è una copia che può mentire, e l'invalidazione è a
> carico tuo. Per questo l'ordine giusto è: prima misurare (F6.1–F6.2), poi
> indicizzare, e **solo alla fine** cachare ciò che resta lento. La cache messa
> per prima nasconde i problemi invece di risolverli.

---

## Parte 7 — Architettura e design

La Parte I ti ha fatto *applicare* buone architetture. Questa ti dà i criteri
per *sceglierle* — e per difendere le tue scelte in una discussione tecnica.
È la parte più "da lettura" del percorso: alternala con le parti 8 e 9.

### F7.1 — Il design del codice (~1,5 settimane)

**Obiettivo:** interiorizzare i pochi principi che reggono tutto il resto:
profondità dei moduli, complessità come costo, refactoring come disciplina.

**Costruisci:**
- Leggi **A Philosophy of Software Design** e, mentre leggi, applica: scegli i
  due moduli più brutti del tuo progetto (li conosci) e rifattorizzali guidato
  dai concetti del libro (deep modules, information hiding, define errors out
  of existence).
- Tieni **Refactoring** (Fowler) come catalogo: per ogni movimento che fai,
  dagli il nome giusto e falla sotto test verde.

**Risorse:**
1. 📕 **A Philosophy of Software Design, 2ª ed.** (Ousterhout) — leggilo tutto, è breve.
2. 📕 **Refactoring, 2ª ed.** (Fowler) — da consultazione; il [catalogo online](https://refactoring.com/catalog/) è 🆓.
3. 🆓 La tua palestra: `doc/CODE_REVIEW.md` di questo repo — rileggilo *dopo* Ousterhout e nota quanti finding ora hanno un nome.

**Verifica (Definition of Done):**
- [ ] Due refactoring completati con suite sempre verde e un diff che sapresti difendere in review.
- [ ] Sai spiegare "deep module vs shallow module" con un esempio *tuo*, non del libro.
- [ ] In una code review (anche di codice altrui su GitHub) hai scritto 3 commenti motivati da principi, non da gusti.

---

### F7.2 — Testing maturo (~1 settimana)

**Obiettivo:** dopo mesi di TDD, il salto di qualità: capire quali test creano
fiducia e quali solo attrito, e misurare la tua suite invece di fidarti.

**Costruisci:**
- Leggi **Unit Testing** (Khorikov) e fai l'audit della tua suite: quali test
  si rompono a ogni refactor pur senza bug (fragili, accoppiati
  all'implementazione)? Quali non fallirebbero mai (inutili)? Correggi i peggiori.
- **Mutation testing** con [PIT](https://pitest.org/) sul backend: fai mutare il
  codice e scopri quanti mutanti la tua suite uccide davvero.
- Rileggi la piramide dei test del repo (unit → slice → integration → E2E su
  tutti e tre i lati) e scrivi, con parole tue, *perché* ogni livello esiste.

**Risorse:**
1. 📕 **Unit Testing: Principles, Practices, and Patterns** (Khorikov) — il libro che mette ordine: i 4 pilastri di un buon test, scuola classica vs London, quando i mock aiutano e quando mentono.
2. 🆓 [PIT / pitest](https://pitest.org/) — mutation testing per JVM, con plugin Gradle.
3. 🆓 [Martin Fowler — Test Pyramid & practical test articles](https://martinfowler.com/articles/practical-test-pyramid.html).

**Verifica (Definition of Done):**
- [ ] Mutation score del backend misurato e migliorato di almeno 10 punti sui moduli core.
- [ ] Almeno 5 test fragili riscritti per testare comportamento, non implementazione.
- [ ] Sai argomentare quando un mock è la scelta giusta (dipendenze *out-of-process* condivise) e quando è un odore.

---

### F7.3 — DDD e il monolite modulare (~1,5 settimane)

**Obiettivo:** capire come si scoprono i confini di un dominio e perché il
"monolite modulare" è oggi il default sensato — con i confini *verificati dai
test*, non dalle intenzioni.

**Costruisci:**
- Leggi **Learning Domain-Driven Design**: linguaggio ubiquo, bounded context,
  aggregati. Poi mappa il tuo Productivity-Hub: quali bounded context vedi?
  (auth, tasks, analytics…) Dove i confini attuali del codice non coincidono
  con quelli del dominio?
- Introduci [ArchUnit](https://www.archunit.org/) nel backend: test che
  *falliscono* se un modulo importa dagli interni di un altro o se il dominio
  importa Spring (finora era una convenzione; ora è una regola eseguibile).
- Esplora [Spring Modulith](https://spring.io/projects/spring-modulith): moduli
  espliciti ed eventi applicativi fra moduli al posto delle chiamate dirette.

**Risorse:**
1. 📕 **Learning Domain-Driven Design** (Khononov) — il DDD spiegato per decidere architetture, non per venerare il libro blu.
2. 🆓 [ArchUnit — user guide](https://www.archunit.org/userguide/html/000_Index.html).
3. 🆓 [Spring Modulith — reference](https://docs.spring.io/spring-modulith/reference/) e 🆓 [Majestic Modular Monoliths (talk)](https://www.youtube.com/results?search_query=majestic+modular+monoliths) per il quadro.

**Verifica (Definition of Done):**
- [ ] I test ArchUnit codificano le regole architetturali del repo e girano in CI.
- [ ] La mappa dei bounded context esiste, con almeno una discrepanza trovata e discussa.
- [ ] Sai argomentare perché *non* spaccheresti questo sistema in microservizi — e cosa dovrebbe succedere perché tu cambi idea.

> **💡 Approfondimento — perché monolite modulare e non microservizi.**
> I microservizi risolvono un problema *organizzativo* (molti team che devono
> rilasciare indipendentemente) al prezzo di problemi *tecnici* enormi: rete
> ovunque, transazioni distribuite, osservabilità distribuita, versioning dei
> contratti. Un team piccolo che li adotta paga il prezzo senza incassare il
> beneficio. Il monolite modulare tiene il beneficio dei confini (imposti da
> ArchUnit/Modulith invece che dalla rete) e un solo deploy. E se un giorno un
> modulo dovrà davvero scalare da solo, un modulo *pulito* si estrae in
> settimane; un monolite a spaghetti, mai.

---

### F7.4 — Sistemi distribuiti e system design (~2 settimane)

**Obiettivo:** il modello mentale dei sistemi che superano una macchina:
replicazione, partizionamento, consistenza, code — e la capacità di ragionarci
ad alta voce in un system design interview.

**Costruisci:**
- Leggi **Designing Data-Intensive Applications (2ª ed.)** — con calma, è denso;
  le parti su storage, replicazione, partizionamento e stream processing sono
  il cuore.
- Due esercizi di design scritti (2–3 pagine l'uno, con diagrammi e trade-off):
  1. *"Productivity-Hub per 1M di utenti"*: dove si rompe l'attuale design?
     Cosa scali prima? Read replica? Cache? Cosa sacrifichi?
  2. Un classico a scelta (URL shortener, feed, chat) fatto col metodo dei
     colloqui: requisiti → stime → API → dati → scala.

**Risorse:**
1. 📕 **Designing Data-Intensive Applications, 2ª ed.** (Kleppmann & Riccomini, 2026) — l'acquisto n°1 della lista.
2. ⭐ [Backend System Design (Jem Young)](https://frontendmasters.com/courses/backend-system-design/) — il formato "colloquio", pratico.
3. 📕 [ByteByteGo](https://bytebytego.com/) / **System Design Interview** (Alex Xu) — solo se hai colloqui di system design all'orizzonte; per imparare basta DDIA.

**Verifica (Definition of Done):**
- [ ] I due design doc esistono e un altro sviluppatore li capisce senza di te.
- [ ] Sai spiegare replicazione sincrona vs asincrona e cosa si rompe in ciascuna.
- [ ] Sai fare una stima di capacità (richieste/s, storage) a ordine di grandezza senza panico.
- [ ] Sai collocare il tuo Productivity-Hub: cosa è già pronto a scalare, cosa no, e perché va bene così.

---

## Parte 8 — Il web moderno completo

La Parte I ti ha dato React "classico" (SPA + API). Il web moderno ha
un'anima in più (rendering sul server, edge) e due doveri spesso ignorati:
performance e accessibilità. E il tuo lato Flutter merita il livello "production".

### F8.1 — Next.js e i React Server Components (~1,5 settimane)

**Obiettivo:** capire il rendering sul server (SSR/RSC), quando serve davvero,
e come si integra con un backend esistente.

**Costruisci:**
- Un **sito vetrina/landing per Productivity-Hub** in Next.js: pagine
  statiche/SSR, SEO, un blog in markdown (i tuoi articoli di F9.3 vivranno qui),
  deployato.
- Una pagina che consuma il tuo backend Spring dal server (Server Component +
  fetch server-side) per toccare con mano la differenza con la SPA.
- Scrivi una nota di architettura: per la *app* (dietro login, ricca di stato)
  la SPA con TanStack Query resta la scelta giusta; per il *sito* no. Saperlo
  argomentare è il punto della fase.

**Risorse:**
1. ⭐ [Next.js Fundamentals, v4 (Scott Moss)](https://frontendmasters.com/courses/next-js-v4/) — il corso principale.
2. ⭐ [Intermediate React, v6 (Brian Holt)](https://frontendmasters.com/courses/intermediate-react-v6/) — la parte RSC, se non l'hai già fatta in F3.3.
3. 🆓 [Next.js — Learn](https://nextjs.org/learn) — il tutorial ufficiale è ben fatto.

**Verifica (Definition of Done):**
- [ ] Il sito è online, indicizzabile, con Lighthouse SEO/Performance ≥ 90.
- [ ] Sai spiegare cosa esegue il server e cosa il client in una pagina RSC, e il perché dei due mondi.
- [ ] La nota "quando SSR e quando SPA" esiste ed è onesta (niente hype in nessuna direzione).

---

### F8.2 — Performance web e accessibilità (~1 settimana)

**Obiettivo:** il tuo frontend misurato e usabile da tutti — tastiera, screen
reader, connessioni lente. Sono le due competenze che quasi nessun junior ha e
quasi ogni azienda seria richiede.

**Costruisci:**
- Audit di performance della webapp: Lighthouse + Web Vitals (LCP, CLS, INP),
  bundle analysis, code splitting delle route, immagini/font ottimizzati.
- Audit di accessibilità: navigazione completa da tastiera, focus visibile,
  label e ruoli ARIA dove servono, contrasti — parti dal finding **F-17** di
  [`CODE_REVIEW.md`](CODE_REVIEW.md), che elenca i gap reali di questo repo.
- Automatizza: Lighthouse CI e [axe](https://github.com/dequelabs/axe-core) nei
  test, così la regressione è bloccata, non solo corretta.

**Risorse:**
1. ⭐ [Web Performance Fundamentals, v2 (Todd Gardner)](https://frontendmasters.com/courses/web-perf-v2/).
2. 🆓 [web.dev — Learn Performance](https://web.dev/learn/performance) e [Learn Accessibility](https://web.dev/learn/accessibility) — i percorsi di Google, gratuiti e ben curati.
3. 🆓 [The A11y Project — checklist](https://www.a11yproject.com/checklist/) — pratica, per iniziare subito.

**Verifica (Definition of Done):**
- [ ] Ogni flusso della webapp completabile solo con la tastiera, focus sempre visibile.
- [ ] Web Vitals in verde su connessione simulata "Slow 4G"; bundle iniziale ridotto e misurato.
- [ ] axe non riporta violazioni gravi, e gira in CI.
- [ ] Hai usato la webapp 10 minuti con uno screen reader (NVDA/VoiceOver): le cose che ti hanno fatto soffrire sono in un issue.

---

### F8.3 — Flutter livello produzione (~1,5 settimane)

**Obiettivo:** completare il lato mobile: animazioni con giudizio, conoscere il
mondo Firebase (lo stack BaaS che troverai ovunque nelle offerte di lavoro
Flutter), e un'app firmata pronta per gli store.

**Costruisci:**
- Due o tre animazioni *misurate* nel tuo client: transizioni fra schermate,
  micro-feedback sul completamento task (il journal predica sobrietà: ogni
  animazione deve avere uno scopo).
- Un progetto satellite piccolo con **Firebase** (auth + Firestore) per capire
  il modello BaaS e saperlo confrontare con il tuo backend Spring: cosa ti
  regala, cosa ti toglie (il controllo sul dominio che hai in C08 non esiste lì).
- Build di release firmata dell'app (Android almeno), con flavor dev/prod e
  la pipeline che la produce — fino alla distribuzione interna.

**Risorse:**
1. 🎯 [Flutter Animations Masterclass](https://codewithandrea.com/courses/flutter-animations-masterclass/) — 10 moduli indipendenti, da fare mirati.
2. 🎯 [Flutter & Firebase Masterclass](https://codewithandrea.com/courses/flutter-firebase-masterclass/) — auth, Firestore, Cloud Functions, pagamenti.
3. 🎯 [Flutter in Production](https://codewithandrea.com/courses/flutter-in-production/) — flavors, firma, store, crash reporting, CI/CD mobile: il pezzo che chiude il cerchio.

**Verifica (Definition of Done):**
- [ ] APK/AAB di release firmato, installato su un telefono vero, con flavor e versioning corretti.
- [ ] Le animazioni girano a 60fps (verificato col profiler, non a sensazione).
- [ ] Sai argomentare Firebase vs backend proprio: costi, lock-in, regole di sicurezza, offline.
- [ ] Crash reporting attivo (es. Sentry/Crashlytics) e un crash di prova arrivato in dashboard.

---

## Parte 9 — AI e carriera

Il fullstack developer "moderno" del titolo si gioca qui: gli LLM sono ormai
parte dello stack (come feature nei prodotti e come strumento di lavoro), e
tutto il percorso fatto finora deve diventare **carriera**: visibilità,
colloqui, rete.

### F9.1 — Costruire con gli LLM (~1,5 settimane)

**Obiettivo:** trattare un LLM come una dipendenza di sistema: API, structured
output, tool use, RAG di base — con test, costi e latenza misurati, come per
qualunque altra dipendenza.

**Costruisci:**
- **Quick-add in linguaggio naturale** per Productivity-Hub: l'utente scrive
  "domani alle 15 dentista, priorità alta, lista Salute" e il sistema crea il
  task strutturato. Lato backend: chiamata al modello con structured output
  (JSON schema), validazione severa della risposta, fallback se il modello
  sbaglia, timeout e budget.
- Un piccolo **RAG**: "chiedi ai tuoi task" (es. "cosa ho concluso questa
  settimana?") con retrieval dei task dell'utente passati come contesto.
- Test: il parsing è coperto da test con risposte del modello registrate; i
  prompt sono versionati nel repo come il codice; costo per richiesta e p95
  finiscono nella dashboard di F5.2.

**Risorse:**
1. 🆓 [Anthropic Academy](https://anthropic.skilljar.com/) — i corsi ufficiali su API, tool use e MCP, gratuiti e con certificato; parti da quello sull'API.
2. ⭐ [AI Engineering Fundamentals (Scott Moss)](https://frontendmasters.com/courses/ai-engineering/) — il quadro da ingegnere: prompting, RAG, valutazione.
3. 🆓 [Anthropic — docs API](https://docs.anthropic.com/) (structured output, tool use) — o l'equivalente del provider che scegli: i concetti sono identici.

**Verifica (Definition of Done):**
- [ ] Il quick-add naturale funziona end-to-end e **degrada con grazia**: se il modello è giù o risponde spazzatura, l'utente ha l'editor normale, mai un errore criptico.
- [ ] Nessun output del modello tocca il DB senza passare dalla validazione del dominio (il backend resta l'autorità, come sempre).
- [ ] Costo per richiesta noto, con un limite; prompt versionati e testati con risposte registrate.
- [ ] Sai spiegare cos'è il context window, perché il RAG esiste, e quando *non* serve un LLM.

> **💡 Approfondimento — l'LLM è un dipendenza inaffidabile per contratto.**
> Tutto ciò che hai imparato sui confini (Parte I) qui diventa vitale: il
> modello è un servizio esterno **non deterministico** — può rispondere
> lentamente, rispondere sbagliato, o rispondere qualcosa che *sembra* giusto.
> Il pattern è lo stesso dell'`ErrorResponse` e delle `Failure` sealed: un
> confine che valida, traduce e degrada. La differenza fra una demo AI e una
> feature AI è tutta lì: la demo mostra il caso felice, la feature sopravvive
> agli altri.

---

### F9.2 — Sviluppo AI-assistito, da professionista (~1 settimana)

**Obiettivo:** usare gli strumenti AI (Claude Code, Copilot & co.) per andare
più veloce **senza smettere di capire** — la competenza che i team stanno
davvero cercando: chi si fa amplificare, non sostituire.

**Costruisci:**
- Una feature intera del tuo progetto sviluppata con un agente AI, con regole
  da professionista: specifichi tu il design, il TDD resta (i test li capisci
  e li approvi tu), ogni diff letto riga per riga prima del commit.
- Un `CLAUDE.md` (o equivalente) per il tuo progetto — come quello di questo
  repo: convenzioni, comandi, architettura. Nota quanto migliora l'output
  dell'agente: scrivere contesto è la nuova competenza.
- Una sessione di **code review AI-assistita** sul tuo codice, in cui decidi
  tu quali finding sono reali e quali rumore — e sai motivare entrambi.

**Risorse:**
1. ⭐ [Claude Code (Lydia Hallie)](https://frontendmasters.com/courses/claude-code/) — workflow agentici fatti bene.
2. 🆓 [Anthropic Academy — corsi su Claude Code](https://anthropic.skilljar.com/) e 🆓 [docs di Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).
3. 🆓 Il [`CLAUDE.md`](../CLAUDE.md) di questo repo come esempio concreto di contesto ben scritto.

**Verifica (Definition of Done):**
- [ ] La feature è in produzione e sapresti riscriverla senza l'AI (prova: spiegala a voce, file per file).
- [ ] Il tuo `CLAUDE.md` esiste e un agente con quel contesto produce codice conforme alle tue convenzioni.
- [ ] Hai un'opinione fondata, con esempi tuoi, su dove l'AI ti fa guadagnare tempo e dove te lo fa perdere.

---

### F9.3 — Portfolio, visibilità, colloqui (~1,5 settimane)

**Obiettivo:** convertire 10+ mesi di lavoro nella cosa che li ripaga: un
lavoro (o clienti). Il progetto c'è; ora deve *raccontarsi* — e tu devi saper
superare i colloqui.

**Costruisci:**
- **Il repo come biglietto da visita**: README con demo GIF/video, architettura
  disegnata, link all'app live (F5.1) e al journal. Chi apre il repo deve capire
  in 60 secondi cosa sa fare chi l'ha scritto.
- **Due articoli tecnici** sul blog di F8.1, presi dal tuo journal (i candidati
  migliori: la corsa dei 401 e la promessa condivisa; le golden fixtures).
  Scrivere in pubblico è il moltiplicatore di carriera più sottovalutato.
- **Una contribuzione open source** a una libreria che usi (anche piccola:
  un bug riprodotto e corretto, docs migliorate). Insegna a leggere codice
  altrui e lascia un segno pubblico verificabile.
- **Preparazione colloqui**: DSA di base su [NeetCode](https://neetcode.io/)
  (roadmap gratuita — per l'Europa il livello richiesto è raggiungibile in
  qualche settimana, non serve il grind americano), i due design doc di F7.4
  ripassati ad alta voce, e il pitch da 5 minuti del progetto provato davvero.

**Risorse:**
1. 📕 **The Pragmatic Programmer, 20th Anniversary** — da leggere qui, a fine percorso: parlerà di cose che ora riconosci.
2. 🆓 [NeetCode — roadmap](https://neetcode.io/) per gli algoritmi da colloquio.
3. 🆓 [First Timers Only](https://www.firsttimersonly.com/) e le label `good first issue` su GitHub per la prima contribuzione.

**Verifica (Definition of Done):**
- [ ] App live + repo curato + 2 articoli pubblicati + 1 PR esterna merged (o in review seria).
- [ ] CV e LinkedIn raccontano il progetto in termini di *decisioni* ("refresh token rotation, monolite modulare, p95 sotto X ms"), non di tecnologie elencate.
- [ ] Hai fatto almeno un mock interview (tecnico o system design) con una persona vera.
- [ ] Il pitch da 5 minuti è registrato: riguardandoti, ci credi.

---

## Fine del percorso (cioè: l'inizio)

Chi arriva qui ha attraversato: un sistema costruito da zero su tre stack, messo
in produzione con osservabilità e sicurezza, dati misurati e ottimizzati,
un'architettura di cui sa discutere, feature AI fatte da ingegnere e un
portfolio pubblico che lo dimostra. Questo non è più "imparare a programmare":
è la parte alta della professione, quella che i titoli di lavoro chiamano
*senior* quando ci aggiungi gli anni di pratica.

Da qui le strade sono personali, e nessun documento può più sceglierle per te:
specializzarti in profondità (dati, mobile, piattaforma, AI), fare da mentore a
chi inizia (insegnare è il modo più veloce di consolidare — questo journal ne è
la prova), o costruire qualcosa di tuo con la velocità di chi ormai lo stack ce
l'ha nelle mani.

L'unica abitudine da non perdere è quella che ti ha portato fin qui: una fase
alla volta, deliverable concreti, e il test rosso prima. 🚦
