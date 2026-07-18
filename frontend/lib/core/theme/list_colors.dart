import 'package:flutter/material.dart';

/// Eight preset swatches for lists and tags — no free color picker.
const listColorSwatches = <String>[
  '#4F46E5', // indigo
  '#0EA5E9', // sky
  '#10B981', // emerald
  '#F59E0B', // amber
  '#EF4444', // red
  '#EC4899', // pink
  '#8B5CF6', // violet
  '#64748B', // slate
];

/// Parses a `#RRGGBB` string into a Color, falling back to grey.
Color colorFromHex(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
    return const Color(0xFF64748B);
  }
  return Color(int.parse('FF${hex.substring(1)}', radix: 16));
}
