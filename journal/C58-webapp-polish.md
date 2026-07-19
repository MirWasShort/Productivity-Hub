# C58 — Rifiniture: gli errori che si annullavano in silenzio

## Cosa è stato fatto

- **`webapp/src/lib/query-client.ts`**: `createQueryClient()` come factory, con
  una `MutationCache` che mostra un avviso quando una mutazione fallisce.
- **`webapp/src/lib/api/error-message.ts`**: da eccezione a frase leggibile.
- **`webapp/src/lib/use-document-title.ts`** e il suo uso nelle quattro pagine
  principali.
- **`webapp/src/features/tasks/components/filter-bar.tsx`**: scorciatoia `/`
  per saltare alla ricerca.
- **`webapp/public/favicon.svg`**, `theme-color` e descrizione in `index.html`.
- **`webapp/src/test/render-app.tsx`**: monta anche le notifiche e usa la
  stessa configurazione di cache dell'app.
- Test: 4 sulle rifiniture.

## Perché

**Il difetto vero di questo commit era invisibile.** Dalla C47 le mutazioni
sono ottimistiche: la spunta appare subito e, se il server rifiuta, la
fotografia precedente viene rimessa. Funziona — ma dal punto di vista
dell'utente, una spunta che si accende e poi si spegne da sola, senza una
parola, è un'app che si comporta in modo inspiegabile. L'ottimismo senza
avviso non è ottimismo: è un'informazione persa.

Ora l'avviso c'è, e sta in **un posto solo**: la `MutationCache` della
`QueryClient`. Ogni mutazione — presente e futura — lo eredita, invece di
doversi ricordare un `onError` a ogni chiamata. L'unica eccezione è la sessione
scaduta, che manda già al login: un avviso in più sarebbe rumore su un evento
già evidente.

**Il titolo della scheda fa parte della navigazione.** Sul web distingue le
schede aperte, popola la cronologia e i preferiti. Lasciare "Smart TODO" ovunque
rende inutili tutte e tre le cose. Non ha equivalente sul mobile: è una di
quelle cose che sul web esistono e vanno usate.

**`/` per cercare** è la convenzione di fatto degli strumenti da tastiera. Il
listener ignora l'evento se si sta già scrivendo, altrimenti scriverebbe una
barra dentro il campo in uso.

## Come funziona

**Perché la cache diventa una factory.** Il primo tentativo di testare l'avviso
falliva: i test creavano una `QueryClient` propria, senza la `MutationCache`
configurata. Era un test che non provava niente — ma soprattutto è il sintomo di
un problema più generale: **una configurazione che vive solo in produzione non è
sotto test**. Ora `createQueryClient()` costruisce la cache configurata, l'app
ne usa un'istanza e i test ne creano una per caso, con l'unica differenza di
`retry` spento (altrimenti ogni errore atteso costerebbe tre tentativi).

Per lo stesso motivo `renderApp` monta anche il `Toaster`: se l'helper di test
non monta ciò che monta `main.tsx`, sta collaudando un'app diversa da quella
che si spedisce.

## Il ciclo TDD

Quattro test: il titolo della scheda cambia con la pagina; **una mutazione
fallita mostra il messaggio del backend** invece di annullarsi in silenzio;
`/` porta il cursore nella ricerca; `/` digitato dentro un campo resta una
barra e non ruba il fuoco.

L'ultimo è il test che rende la scorciatoia utilizzabile invece che fastidiosa:
senza, un titolo con una data (`Spesa 12/7`) diventerebbe impossibile da
scrivere.

## Concetti chiave

- **L'ottimismo va accompagnato da una spiegazione quando fallisce**, o diventa
  un comportamento arbitrario.
- **Le regole trasversali in un posto solo**: la `MutationCache` è il livello
  giusto per "cosa succede quando una scrittura fallisce".
- **Se i test non montano quello che monta l'app**, stanno collaudando
  qualcos'altro.
- **Le scorciatoie da tastiera devono farsi da parte** mentre si scrive.
- **Il titolo della scheda è interfaccia**, non decorazione.

## Per approfondire

- [TanStack Query — `MutationCache` e gestione globale degli errori](https://tanstack.com/query/latest/docs/framework/react/reference/MutationCache)
- [sonner](https://sonner.emilkowal.ski/)
