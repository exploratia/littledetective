import 'package:flutter/material.dart';

const _accentColor = Color(0xFF0086C5);

class AppTheme {
  const AppTheme._();

  static ThemeData build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accentColor,
      brightness: brightness,
    );
    final barBackgroundColor = colorScheme.surfaceContainerLow;

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: barBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: barBackgroundColor,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: colorScheme.onSurface),
        ),
      ),
      useMaterial3: false,
    );
  }
}
