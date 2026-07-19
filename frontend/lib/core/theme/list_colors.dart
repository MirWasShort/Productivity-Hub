import 'package:flutter/material.dart';

import 'generated_tokens.dart';

/// Gli otto colori preimpostati di liste e tag — nessun selettore libero.
/// Definiti in `tokens/tokens.json`, condivisi con la webapp.
const listColorSwatches = Tokens.listSwatches;

/// Converte una stringa `#RRGGBB` in Color, con ripiego sullo slate.
Color colorFromHex(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
    return Tokens.fallbackColor;
  }
  return Color(int.parse('FF${hex.substring(1)}', radix: 16));
}
