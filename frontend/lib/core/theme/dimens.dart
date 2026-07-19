import 'generated_tokens.dart';

/// Scala di spaziature e raggi. I valori vivono in `tokens/tokens.json` e sono
/// generati in `generated_tokens.dart`: questa classe resta come nome storico
/// usato in tutta l'app.
abstract final class Dimens {
  static const xs = Tokens.xs;
  static const sm = Tokens.sm;
  static const md = Tokens.md;
  static const lg = Tokens.lg;
  static const xl = Tokens.xl;
  static const xxl = Tokens.xxl;

  static const radiusSm = Tokens.radiusSm;
  static const radiusMd = Tokens.radiusMd;
  static const radiusLg = Tokens.radiusLg;
}
