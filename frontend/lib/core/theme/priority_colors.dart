import 'package:flutter/material.dart';

import '../../features/task/domain/entities/task.dart';
import 'generated_tokens.dart';

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

  // I valori arrivano da tokens/tokens.json, condiviso con la webapp.
  static const light = PriorityColors(
    lowBackground: PriorityTokens.lightLowBackground,
    lowForeground: PriorityTokens.lightLowForeground,
    mediumBackground: PriorityTokens.lightMediumBackground,
    mediumForeground: PriorityTokens.lightMediumForeground,
    highBackground: PriorityTokens.lightHighBackground,
    highForeground: PriorityTokens.lightHighForeground,
  );

  static const dark = PriorityColors(
    lowBackground: PriorityTokens.darkLowBackground,
    lowForeground: PriorityTokens.darkLowForeground,
    mediumBackground: PriorityTokens.darkMediumBackground,
    mediumForeground: PriorityTokens.darkMediumForeground,
    highBackground: PriorityTokens.darkHighBackground,
    highForeground: PriorityTokens.darkHighForeground,
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
