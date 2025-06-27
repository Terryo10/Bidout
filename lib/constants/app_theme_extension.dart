import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Custom color getters
  Color get surfaceContainer => theme.colorScheme.surface.withOpacity(0.8);
  Color get borderLight => theme.colorScheme.outline.withOpacity(0.2);
  Color get textPrimary => theme.colorScheme.onBackground;
  Color get textSecondary => theme.colorScheme.onBackground.withOpacity(0.7);
  Color get textTertiary => theme.colorScheme.onBackground.withOpacity(0.5);
  Color get success => const Color(0xFF4CAF50);
  Color get warning => const Color(0xFFFFA726);
  Color get info => const Color(0xFF2196F3);
  Color get error => theme.colorScheme.error;
}
