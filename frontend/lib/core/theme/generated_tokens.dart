// GENERATO da tokens/generate.mjs — non modificare a mano.
// Fonte: tokens/tokens.json
import 'package:flutter/material.dart';

/// Token del design system condivisi con la webapp.
abstract final class Tokens {
  static const seed = Color(0xFF4F46E5);

  // Spaziature (multipli di 4).
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  // Raggi.
  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;

  /// Colori preimpostati di liste e tag.
  static const listSwatches = <String>[
    '#4F46E5',
    '#0EA5E9',
    '#10B981',
    '#F59E0B',
    '#EF4444',
    '#EC4899',
    '#8B5CF6',
    '#64748B',
  ];

  /// Colore di ripiego quando il backend non ne manda uno valido.
  static const fallbackColor = Color(0xFF64748B);
}

/// Accenti di priorità, per luminosità del tema.
abstract final class PriorityTokens {
  static const lightLowBackground = Color(0xFFE1F4E3);
  static const lightLowForeground = Color(0xFF1B5E20);
  static const lightMediumBackground = Color(0xFFFFF3D6);
  static const lightMediumForeground = Color(0xFF8A5A00);
  static const lightHighBackground = Color(0xFFFDE3E1);
  static const lightHighForeground = Color(0xFFB3251E);

  static const darkLowBackground = Color(0xFF1F3B23);
  static const darkLowForeground = Color(0xFFA5D6A7);
  static const darkMediumBackground = Color(0xFF453411);
  static const darkMediumForeground = Color(0xFFFFD54F);
  static const darkHighBackground = Color(0xFF4A1F1D);
  static const darkHighForeground = Color(0xFFEF9A9A);
}
