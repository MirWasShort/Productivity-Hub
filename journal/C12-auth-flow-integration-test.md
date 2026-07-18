# C12 — AuthFlowIT: il viaggio completo su HTTP reale

## Cosa è stato fatto

Un unico test d'integrazione (`AuthFlowIT`) che percorre l'intero sistema
su HTTP vero (`@SpringBootTest(webEnvironment = RANDOM_PORT)` +
`TestRestTemplate`) contro un PostgreSQL vero (Testcontainers):

1. Alice si registra → 201 con coppia di token
2. Alice crea un task → 201
3. Alice lo vede nella sua lista
4. Bob si registra → il task di Alice per lui è **404**, la sua lista è
   **vuota** (isolamento tra utenti)
5. Alice fa refresh → nuova coppia; il **vecchio** refresh token riusato →
   **401** (rotazione)
6. Col nuovo access token porta il task a DONE → 200
7. DELETE → 204; il task non esiste più → 404

Dipendenza aggiunta: `spring-boot-starter-restclient` in test scope —
in Boot 4 `TestRestTemplate` vive nel modulo `resttestclient` e richiede
`RestTemplateBuilder` dal modulo `restclient` (scoperto via
`ClassNotFoundException` alla prima esecuzione).

## Perché

**Perché serve, se ogni pezzo è già testato?** I test unit e slice
verificano i pezzi *in isolamento con dei mock ai bordi*. Nessuno di loro
verifica che i pezzi siano **cablati** giusto: che il filtro JWT legga
davvero i token emessi dall'AuthService, che la transazione committi, che
la serializzazione JSON di andata e ritorno combaci. Questo test è
l'assicurazione sul cablaggio — se passa, il sistema *fa* quello che i
pezzi promettono.

**Perché uno solo e non dieci?** Piramide dei test: i test end-to-end sono
i più lenti (contesto completo + container + HTTP reale) e i più fragili.
Il loro valore è nel coprire il *percorso*, non i casi limite — quelli
stanno già negli unit test. Un viaggio ben scelto tocca tutte le
integrazioni critiche; dieci viaggi toccherebbero le stesse integrazioni
dieci volte, pagando dieci volte il costo.

**Perché il test è una storia con due personaggi?** "Alice crea, Bob non
vede" è la formulazione eseguibile del requisito di sicurezza più
importante dell'app (ROADMAP Fase 3: "User A cannot read User B's tasks").
Le asserzioni sull'isolamento e sulla rotazione qui girano sull'app
*intera*, filtri inclusi — non su un service mockato.

## Come funziona

- `webEnvironment = RANDOM_PORT` avvia un Tomcat vero su una porta libera;
  `TestRestTemplate` è preconfigurato per puntarci e, a differenza di
  `RestTemplate`, non lancia eccezioni sui 4xx/5xx — restituisce la
  risposta, che è ciò che un test vuole asserire.
- A differenza di MockMvc (che simula le richieste dentro il dispatcher),
  qui i byte passano da un socket TCP: vengono esercitati anche i
  converter HTTP, i filtri servlet reali e la configurazione del server.
- Il body JSON viene letto come `Map<String, Object>`: per un test di
  contratto end-to-end non servono DTO tipizzati — anzi, usare i DTO del
  server nasconderebbe errori di serializzazione.

## Il ciclo TDD in questo commit

Commit di solo test: il "rosso" qui sarebbe stato un bug di cablaggio.
Ne è emerso uno *di build*: la dipendenza mancante di `TestRestTemplate`
(Boot 4 ha spacchettato i moduli HTTP client). Risolto, il viaggio è
passato al primo colpo — com'era giusto aspettarsi, visto che ogni tratto
era già coperto dai commit precedenti. Un E2E che passa subito è la
ricompensa del TDD fatto a monte.

## Concetti chiave

- **Test di cablaggio vs test di logica**: i mock verificano i pezzi, gli
  E2E verificano le giunture.
- **Piramide**: molti unit, alcuni slice/IT, *pochissimi* E2E ben scelti.
- **RANDOM_PORT**: HTTP vero senza conflitti di porta, parallelizzabile.
- **Il requisito di sicurezza come storia eseguibile**: l'isolamento tra
  utenti non è un commento, è un'asserzione.

## Per approfondire

- [Spring Boot — Testing web servers](https://docs.spring.io/spring-boot/reference/testing/spring-boot-applications.html)
- [Martin Fowler — Integration Test](https://martinfowler.com/bliki/IntegrationTest.html) e [Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html)
- ROADMAP: Fase 3, Testing Strategy (full HTTP roundtrip con Testcontainers)
