# 📓 Journal di sviluppo

Questa directory racconta la riscrittura del progetto **commit per commit**.
Ogni file corrisponde a un commit e spiega *cosa* è stato fatto, *perché*,
*come funziona*, e dove approfondire. È pensato per essere letto in ordine,
affiancando il diff del commit corrispondente:

```bash
git log --oneline               # trova l'hash del commit
git show <hash>                 # guarda il diff mentre leggi la entry
```

## Come è organizzata ogni entry

- **Cosa è stato fatto** — i file toccati e il comportamento introdotto
- **Perché** — le decisioni, le alternative scartate, i trade-off
- **Come funziona** — il meccanismo spiegato da zero
- **Il ciclo TDD** — quale test è nato prima (rosso), cosa lo ha fatto passare (verde)
- **Concetti chiave** — da portare a casa
- **Per approfondire** — documentazione ufficiale e riferimenti alla ROADMAP

## Indice

| # | Entry | Tema |
|---|-------|------|
| C01 | [Ristrutturazione monorepo](C01-monorepo-restructure.md) | Git, layout del repo |
| C02 | [Bootstrap backend](C02-backend-bootstrap.md) | Spring Boot, Gradle, Docker, Testcontainers |
| C03 | [Health endpoint](C03-health-endpoint.md) | TDD, @WebMvcTest, adapter esagonali |
| C04 | [Persistenza User](C04-user-persistence.md) | Flyway, port & adapter, @DataJpaTest |
| C05 | [JwtTokenProvider](C05-jwt-token-provider.md) | JWT, jjwt, unit test puri |

*(l'indice cresce con i commit)*
