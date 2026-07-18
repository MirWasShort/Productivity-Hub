# C22 — Design system, dark mode e tema persistito

## Cosa è stato fatto

- **`core/theme/app_theme.dart`**: i due temi dell'app (light/dark)
  costruiti da un **unico seed** indigo (`#4F46E5`) con
  `ColorScheme.fromSeed`. Sul tema base: card outlined raggio 16 senza
  elevazione, input filled raggio 12, chip/navbar/FAB/snackbar
  coordinati, transizioni di pagina fade, type scale ritoccata
  (`titleMedium` semibold). `theme/dimens.dart` fissa la scala di
  spaziatura (multipli di 4).
- **`core/theme/priority_colors.dart`**: i colori delle priorità come
  **`ThemeExtension<PriorityColors>`** — coppie background/foreground
  *diverse per brightness* (rosso-700 su rosso-50 in light, rosso-200 su
  rosso scuro in dark).
- **`core/theme/theme_mode_notifier.dart`** + **`core/storage/preferences.dart`**:
  `Notifier<ThemeMode>` che legge/scrive `shared_preferences`
  (`SharedPreferencesWithCache`); toggle nell'appbar (`Key('theme_toggle')`).
- `main.dart` crea le preferences **prima** di `runApp` e le inietta con
  `ProviderScope(overrides:)`; `app.dart` monta `theme`/`darkTheme`/`themeMode`.
- 6 test scritti prima: default system, persistenza, rilettura al
  riavvio, toggle (incluso il caso "da system"), tema dark applicato.

## Perché

**Perché un solo seed e non una palette disegnata a mano?** Material 3
deriva dall'unico colore seme 30+ ruoli tonali coerenti per *entrambe* le
brightness: contrasti corretti gratis, dark mode che non sembra un tema
diverso. Una palette artigianale su due modi è il modo più rapido per
avere accostamenti illeggibili. Il seed si può cambiare in una riga.

**Perché `ThemeExtension` per le priorità?** I chip attuali usavano
`Colors.red/orange/green` raw: in dark mode rosso-700 su una superficie
scura è fango illeggibile. L'estensione porta i colori semantici *dentro*
il tema: il widget chiede `Theme.of(context).extension<PriorityColors>()`
e riceve automaticamente la variante giusta per la brightness attiva.
Stesso meccanismo dei ruoli M3, esteso al dominio dell'app — e in C35 i
grafici riuseranno le stesse coppie, così legenda e card combaciano.

**Perché le preferences si creano in `main()` e si iniettano, invece di
un provider async?** Con un `FutureProvider` il primo frame non sa ancora
il tema salvato → flash di tema sbagliato all'avvio. Creandole prima di
`runApp`, `ThemeModeNotifier.build()` è **sincrono**: il primissimo frame
è già del colore giusto. Il costo (un `await` in main) è invisibile.

**Perché `shared_preferences` e non il `TokenStorage`?** Il secure
storage è per i *segreti* (cifratura hardware, costi di accesso). Il tema
è una preferenza non sensibile: `shared_preferences` è il posto giusto.
Strumenti diversi per sensibilità diverse.

## Come funziona

- `SharedPreferencesWithCache` (l'API attuale del pacchetto, consigliata
  rispetto alla legacy `SharedPreferences`) tiene una cache in memoria:
  letture sincrone, scritture async verso la piattaforma.
- Nei test la piattaforma vera non c'è: si monta
  `InMemorySharedPreferencesAsync` come `SharedPreferencesAsyncPlatform.instance`
  (il mock legacy `setMockInitialValues` serve solo la vecchia API — 
  scoperto col rosso "The SharedPreferencesAsyncPlatform instance must
  be set").
- `themeMode` in `MaterialApp` decide quale dei due temi è attivo:
  `system` segue il sistema operativo; il toggle da `system` va
  all'*opposto* della brightness corrente, così il primo tap ha sempre
  effetto visibile.
- Insidia Flutter 3.44 incontrata: `CupertinoPageTransitionsBuilder` non
  esiste più nel scope material — `FadeForwardsPageTransitionsBuilder`
  (il nuovo default M3) su tutte le piattaforme.

## Il ciclo TDD in questo commit

1. **Rosso** — i 4 test del notifier non compilavano; poi rosso runtime
   sulla piattaforma prefs mancante nei test (istruttivo di suo).
2. **Verde** — tema, estensione, notifier, iniezione in main, toggle.
3. **Refactor** — costanti di spaziatura estratte in `dimens.dart` da
   subito: i magic number di layout hanno vita breve in un design system.

## Concetti chiave

- **Seed-based theming**: un colore, due temi coerenti; la palette è
  derivata, non disegnata.
- **ThemeExtension**: colori semantici di dominio dentro il tema, con
  varianti per brightness.
- **Niente flash di tema**: stato persistito disponibile *prima* del
  primo frame via override sincrono.
- **Storage per sensibilità**: secure storage per i segreti, preferences
  per le preferenze.

## Per approfondire

- [Material 3 — Color system](https://m3.material.io/styles/color/system/overview) e [dynamic color from seed](https://m3.material.io/styles/color/dynamic/choosing-a-source)
- [Flutter — ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)
- [shared_preferences — SharedPreferencesWithCache](https://pub.dev/packages/shared_preferences)
- [Flutter — Theming codelab](https://docs.flutter.dev/cookbook/design/themes)
- ROADMAP: Fase 9, Settimana 39 (Dark mode & theming)
