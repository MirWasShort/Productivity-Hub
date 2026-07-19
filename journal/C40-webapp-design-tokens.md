# C40 — Design token e tema chiaro/scuro: lo stesso feeling, in CSS

## Cosa è stato fatto

- **`webapp/src/index.css`**: Tailwind v4 più i design token dell'app come
  custom property. `:root` e `.dark` definiscono colori di superficie, brand,
  bordi e i sei accenti di priorità; un blocco `@theme` ridefinisce la scala
  dei raggi (8/12/16); `@theme inline` espone tutto come utility Tailwind
  (`bg-card`, `text-priority-high-foreground`, …).
- **`webapp/src/lib/theme/theme-store.ts`**: store zustand con le tre modalità
  `light | dark | system`, persistenza in `localStorage` e applicazione della
  classe `dark` sull'elemento root; `initTheme()` si aggancia a `matchMedia`
  per seguire il sistema a caldo.
- **`webapp/src/lib/theme/list-colors.ts`**: gli otto swatch di liste e tag,
  `normalizeHex()` (ripiego su slate) e `withAlpha()` per gli sfondi tenui.
- **`webapp/src/components/theme-toggle.tsx`**: il pulsante sole/luna.
- **`webapp/components.json` + `src/components/ui/{button,card}.tsx`**:
  shadcn/ui inizializzato; primi due componenti.
- **`webapp/src/test/setup.ts`**: polyfill di `localStorage` per i test.
- **`webapp/.oxlintrc.json`**: i file generati da shadcn sono esclusi dalla
  regola `only-export-components`.

## Perché

Il vincolo era "stesso feeling, ma web nativo". Il rischio, con Tailwind, è
finire con l'aspetto generico di shadcn/ui — bello, ma di un'altra app.

I colori quindi non sono scelti a occhio: sono **esattamente quelli che
Material 3 genera** dal seed `#4F46E5` del client Flutter. Sono stati estratti
eseguendo `ColorScheme.fromSeed` dentro un test Flutter usa-e-getta e
trascritti come custom property. Ecco perché `--primary` in chiaro è `#5A5892`
e non `#4F46E5`: il seed non è il colore finale, M3 lo mappa su una palette
tonale e quello è il viola che l'app mobile mostra davvero.

Alternative valutate:

- **Ricalcolare l'algoritmo M3 in JS** (`@material/material-color-utilities`) —
  scartata: una dipendenza e un calcolo a runtime per ottenere valori che sono
  costanti. Meglio congelarli e, in C60, generarli una volta sola da un file di
  token condiviso.
- **`baseColor: slate` di shadcn** — scartata: è una palette neutra grigia,
  perde l'inclinazione violacea delle superfici M3 (`#FCF8FF`, non bianco).
- **`prefers-color-scheme` puro, senza classe** — scartata: non permette la
  scelta esplicita dell'utente, che nel client Flutter esiste ed è persistita.

## Come funziona

**Perché due blocchi `@theme` diversi.** In Tailwind v4 il tema è fatto di
custom property. Le variabili dichiarate in `@theme` sono *statiche*: Tailwind
le legge e genera le utility. Ma i colori devono cambiare tra chiaro e scuro,
e una variabile statica non può farlo. Da qui lo schema in due tempi:

1. `:root` e `.dark` dichiarano i **valori** (`--card: #ffffff` / `#201f25`);
2. `@theme inline` dichiara le **utility** che puntano a quelle variabili
   (`--color-card: var(--card)`).

`inline` è la parola chiave importante: senza, Tailwind copierebbe il valore al
momento della generazione e la classe `.dark` non avrebbe più effetto. Con
`inline`, l'utility emette `background-color: var(--card)` e la risoluzione
avviene nel browser, dove la cascata sa se `.dark` è attiva.

I raggi invece stanno in un `@theme` normale perché non cambiano col tema: qui
sovrascriviamo di proposito la scala di Tailwind, così `rounded-sm/md/lg`
significa già 8/12/16 come `Dimens` in Flutter, e nessun componente shadcn ha
bisogno di essere ritoccato per avere l'aria giusta.

**`@custom-variant dark`** dice a Tailwind che `dark:` va risolto guardando la
classe `.dark` su un antenato, invece che la media query di sistema: è la
classe che lo store pilota.

**Lo store del tema** replica la logica del `ThemeModeNotifier` Flutter, incluso
il dettaglio del `toggle()` da `system`: non passa a `light` per default, ma
va all'**opposto della preferenza di sistema**, così il primo click ha sempre
un effetto visibile. `initTheme()` viene chiamata in `main.tsx` prima del primo
render, perché applicare la classe dopo il mount produce un lampo di tema
sbagliato.

**Nota sull'ambiente di test**: Node 26 espone un `localStorage` sperimentale
disattivato di default, che oscura quello di jsdom lasciando il global a
`undefined`. `setup.ts` installa una `Storage` in memoria quando manca — più
prevedibile di quella vera, perché si azzera a ogni file di test.

## Il ciclo TDD

1. **Rosso** — `theme-store.test.ts` (7 casi: default `system`, persistenza,
   classe sul documento, `system` che segue `matchMedia`, `toggle` in entrambi
   i versi, `toggle` da `system`, valore salvato non valido) e
   `list-colors.test.ts` (4 casi: palette, hex valido, ripiego, canale alfa),
   scritti contro moduli inesistenti.
2. **Verde** — implementati `theme-store.ts` e `list-colors.ts`.
3. **Rosso** — `App.test.tsx` cerca il pulsante "Passa al tema scuro" e
   verifica che il click aggiunga la classe `dark`.
4. **Verde** — `ThemeToggle` e il montaggio in `App`.

Il test del ripiego su slate merita una nota: `color` è nullable lato backend
(`ListResponse.color`), quindi il caso "nessun colore" non è teorico. In
Flutter lo copre `colorFromHex`; qui lo copre `normalizeHex`, con gli stessi
casi limite (`#FFF` a tre cifre è invalido, non va espanso).

## Concetti chiave

- **Un design system si copia dai valori, non dall'impressione**: estrarre i
  colori reali dall'app esistente batte "un indigo simile".
- **`@theme inline` vs `@theme`**: la differenza tra un token che può cambiare
  a runtime e uno che viene inlinato in fase di build.
- **Il seed non è il colore**: in Material 3 il colore dichiarato è solo il
  punto di partenza di una palette tonale.
- **Il primo click deve fare qualcosa**: uno stato "automatico" va risolto
  prima di invertirlo.

## Per approfondire

- [Tailwind v4 — Theme variables](https://tailwindcss.com/docs/theme) e
  [dark mode con selettore](https://tailwindcss.com/docs/dark-mode)
- [Material 3 — Color roles](https://m3.material.io/styles/color/roles)
- [shadcn/ui — Vite](https://ui.shadcn.com/docs/installation/vite)
- [zustand](https://zustand.docs.pmnd.rs/)
- C22 (`C22-design-system-dark-mode.md`) — la versione Flutter di questo commit
