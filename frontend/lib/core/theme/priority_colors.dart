import 'package:flutter/material.dart';

import '../../features/task/domain/entities/task.dart';

/// Priority accent colors as a theme extension: each brightness gets its
/// own container/on-container pairs, so chips and charts stay legible in
/// both light and dark mode. Access via `Theme.of(context).extension`.
@immutable
class PriorityColors extends ThemeExtension<PriorityColors> {
  const PriorityColors({
    required this.lowBackground,
    required this.lowForeground,
    required this.mediumBackground,
    required this.mediumForeground,
    required this.highBackground,
    required this.highForeground,
  });

  final Color lowBackground;
  final Color lowForeground;
  final Color mediumBackground;
  final Color mediumForeground;
  final Color highBackground;
  final Color highForeground;

  static const light = PriorityColors(
    lowBackground: Color(0xFFE1F4E3),
    lowForeground: Color(0xFF1B5E20),
    mediumBackground: Color(0xFFFFF3D6),
    mediumForeground: Color(0xFF8A5A00),
    highBackground: Color(0xFFFDE3E1),
    highForeground: Color(0xFFB3251E),
  );

  static const dark = PriorityColors(
    lowBackground: Color(0xFF1F3B23),
    lowForeground: Color(0xFFA5D6A7),
    mediumBackground: Color(0xFF453411),
    mediumForeground: Color(0xFFFFD54F),
    highBackground: Color(0xFF4A1F1D),
    highForeground: Color(0xFFEF9A9A),
  );

  Color backgroundOf(TaskPriority priority) => switch (priority) {
        TaskPriority.low => lowBackground,
        TaskPriority.medium => mediumBackground,
        TaskPriority.high => highBackground,
      };

  Color foregroundOf(TaskPriority priority) => switch (priority) {
        TaskPriority.low => lowForeground,
        TaskPriority.medium => mediumForeground,
        TaskPriority.high => highForeground,
      };

  @override
  PriorityColors copyWith({
    Color? lowBackground,
    Color? lowForeground,
    Color? mediumBackground,
    Color? mediumForeground,
    Color? highBackground,
    Color? highForeground,
  }) {
    return PriorityColors(
      lowBackground: lowBackground ?? this.lowBackground,
      lowForeground: lowForeground ?? this.lowForeground,
      mediumBackground: mediumBackground ?? this.mediumBackground,
      mediumForeground: mediumForeground ?? this.mediumForeground,
      highBackground: highBackground ?? this.highBackground,
      highForeground: highForeground ?? this.highForeground,
    );
  }

  @override
  PriorityColors lerp(PriorityColors? other, double t) {
    if (other == null) {
      return this;
    }
    return PriorityColors(
      lowBackground: Color.lerp(lowBackground, other.lowBackground, t)!,
      lowForeground: Color.lerp(lowForeground, other.lowForeground, t)!,
      mediumBackground:
          Color.lerp(mediumBackground, other.mediumBackground, t)!,
      mediumForeground:
          Color.lerp(mediumForeground, other.mediumForeground, t)!,
      highBackground: Color.lerp(highBackground, other.highBackground, t)!,
      highForeground: Color.lerp(highForeground, other.highForeground, t)!,
    );
  }
}
