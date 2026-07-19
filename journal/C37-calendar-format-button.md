# C37 — Il pulsante formato del calendario mostra la vista corrente

## Cosa è stato fatto

- **`calendar_screen.dart`**: aggiunto `headerStyle: HeaderStyle(formatButtonShowsNext: false)` al `TableCalendar`.
- **`calendar_screen_test.dart`**: nuovo widget test che fissa il contratto — il pulsante mostra l'etichetta del formato *attivo* e il tap continua a ciclare Mese → 2 settimane → Settimana.

## Perché

Il pulsante in alto a destra del calendario sembrava "sfasato": con la
vista mensile diceva "2 settimane", con la vista a due settimane diceva
"Settimana", e così via. La vista era sempre corretta — a mentire era
l'etichetta.

`table_calendar` per default usa `formatButtonShowsNext: true`: il
pulsante mostra il formato **a cui passerai** cliccando, come farebbe un
pulsante "prossima vista". È una scelta legittima ma controintuitiva
quando le etichette sono sostantivi ("Mese") e non azioni ("Passa a 2
settimane"): l'utente la legge come lo stato corrente. Con tre formati
disponibili l'effetto è un'etichetta sistematicamente in anticipo di uno
sul ciclo.

L'alternativa scartata: rinominare le etichette in forma di azione
("→ 2 settimane"). Avrebbe conservato il default della libreria ma
allungato il pulsante e restava meno leggibile di un'etichetta di stato.

## Come funziona

`FormatButton` dentro `table_calendar` sceglie il testo così
(`format_button.dart:58`): se `showsNextFormat` è true usa
`availableCalendarFormats[_nextFormat()]`, altrimenti il formato
corrente. Il tap chiama comunque `onTap(_nextFormat())` in entrambi i
casi: disattivare `formatButtonShowsNext` cambia solo l'etichetta, non
il comportamento di ciclo, che resta gestito da
`CalendarNotifier.setFormat`.

## Il ciclo TDD

1. **Rosso** — il nuovo test pompa la schermata (vista di default:
   mese) e si aspetta `find.text('Mese')` sul pulsante: falliva perché
   il pulsante diceva "2 settimane".
2. **Verde** — una riga di `headerStyle`. Il test verifica anche il tap
   (Mese → 2 settimane) per garantire che il ciclo non si sia rotto.

## Concetti chiave

- **I default delle librerie codificano un'ipotesi di UX**: qui "il
  pulsante è un'azione", nella nostra UI "il pulsante è uno stato". Il
  bug non era nel codice ma nel disallineamento tra le due letture.
- **Fissare il contratto, non l'implementazione**: il test asserisce
  cosa legge l'utente (etichetta = vista corrente, tap = vista
  successiva), non quale flag è impostato.

## Per approfondire

- [table_calendar — HeaderStyle](https://pub.dev/documentation/table_calendar/latest/table_calendar/HeaderStyle-class.html)
