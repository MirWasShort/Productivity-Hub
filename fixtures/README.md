# Golden fixture del dominio

Casi input/output condivisi dai due client. La stessa logica esiste due volte —
in Dart (`frontend/lib/features/**/domain`) e in TypeScript
(`webapp/src/features/**`) — e questi file sono la prova che le due
implementazioni si comportano **davvero** allo stesso modo, invece di
somigliarsi.

Ogni fixture è letta da entrambe le suite:

- `flutter test test/domain/golden_fixtures_test.dart`
- `npm test -- golden-fixtures` (da `webapp/`)

## Convenzione sulle date

Gli istanti sono scritti **senza fuso** (`2026-07-15T12:00:00`). Sia
`DateTime.parse` in Dart sia `new Date(...)` in JavaScript interpretano una
data-ora priva di offset come **ora locale**: le fixture descrivono quindi un
orario da orologio a muro, e i risultati non dipendono dal fuso di chi esegue i
test. Le date di solo giorno (`2026-07-13`) restano tali.

Aggiungere un caso qui significa aggiungerlo a entrambe le suite: è il punto.
