# C03 — Health endpoint (il primo ciclo TDD vero)

## Cosa è stato fatto

- `HealthControllerTest` (`src/test/.../adapter/in/web/HealthControllerTest.java`):
  primo test web del progetto, scritto **prima** del codice di produzione.
- `HealthController` (`src/main/.../adapter/in/web/HealthController.java`):
  `GET /health` → `{"status":"UP"}`.
- Con questi due file nasce il primo package della struttura esagonale:
  `adapter/in/web` (i package restanti — `domain`, `application`,
  `adapter/out` — appariranno man mano che arrivano le classi che li abitano).

## Perché

**Perché un endpoint di health "a mano" se Actuator ne fornisce già uno?**
`/actuator/health` resta attivo e più ricco (controlla anche la connessione
al DB). Questo `/health` minimale esiste perché: (1) è il contratto che la
ROADMAP definisce (Fase 1, settimana 5) e serve da "hello world" del ciclo
TDD; (2) dà un endpoint pubblico, stabile e senza dipendenze su cui load
balancer o smoke test possono contare anche se Actuator cambia formato.

**Perché il controller sta in `adapter/in/web`?** Nell'architettura
esagonale il controller è un *adapter di ingresso*: traduce il mondo HTTP
verso l'applicazione. Non contiene logica di business (qui non ce n'è
proprio); quando ne arriverà, vivrà nei servizi del layer `application`.

**Perché `@AutoConfigureMockMvc(addFilters = false)`?** Lo starter Security
è già nel classpath e, senza configurazione, blocca *tutte* le richieste.
La configurazione vera della security arriva in un commit dedicato (C06) —
disattivare i filtri qui mantiene il test focalizzato sul controller.
Quando la security sarà configurata, un test apposito verificherà che
`/health` sia davvero pubblico *con* i filtri attivi.

## Come funziona

`@WebMvcTest(HealthController.class)` avvia un contesto Spring "a fetta"
(slice test): solo il layer web — il controller indicato, i converter JSON,
la gestione degli errori MVC — senza database, senza servizi, senza il resto
dell'app. Per questo è velocissimo. `MockMvc` simula richieste HTTP senza
aprire una porta vera: `perform(get("/health"))` attraversa il dispatcher
di Spring MVC esattamente come farebbe una richiesta reale.

Nota Spring Boot 4: le annotazioni di test sono state riorganizzate in
package per modulo — `@WebMvcTest` ora sta in
`org.springframework.boot.webmvc.test.autoconfigure` (i tutorial per Boot
2/3 mostrano `org.springframework.boot.test.autoconfigure.web.servlet`).

Il controller restituisce `Map.of("status", "UP")`: Spring MVC la serializza
in JSON automaticamente tramite Jackson perché la classe è `@RestController`
(= `@Controller` + `@ResponseBody`).

## Il ciclo TDD in questo commit

1. **Rosso** — scritto `HealthControllerTest`; `./gradlew test` fallisce in
   *compilazione* (`HealthController` non esiste). Anche un errore di
   compilazione è un rosso legittimo: il test esprime un'aspettativa che il
   sistema non soddisfa ancora.
2. **Verde** — creato il controller più semplice possibile che soddisfa il
   test. Nessuna riga in più del necessario.
3. **Refactor** — niente da rifattorizzare su 10 righe; il valore del ciclo
   qui è l'abitudine.

## Concetti chiave

- **Slice test** (`@WebMvcTest`): testare un layer in isolamento caricando
  solo i bean che gli servono.
- **Adapter di ingresso** (hexagonal): il controller traduce HTTP ↔
  applicazione, mai logica di business.
- **Red-Green-Refactor**: il test detta l'esistenza del codice, non
  viceversa.
- **Test naming**: `should_comportamentoAtteso_when_condizione` — il nome
  descrive il comportamento, non l'implementazione.

## Per approfondire

- [Spring Boot — Testing the Web Layer](https://spring.io/guides/gs/testing-web)
- [MockMvc reference](https://docs.spring.io/spring-framework/reference/testing/mockmvc.html)
- [Test Driven Development by Example — Kent Beck] (il libro che ha definito Red-Green-Refactor)
- [Hexagonal architecture (Alistair Cockburn)](https://alistair.cockburn.us/hexagonal-architecture/)
- ROADMAP: Fase 1, Settimana 5 e kata 1.1 (REST API with Spring Boot)
