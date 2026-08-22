// lib/ui/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'colors.dart';

/// Tipo di tema
enum AppTheme {
  fantasy,
  arcade;

  static AppTheme fromString(String value) {
    return AppTheme.values.firstWhere(
          (theme) => theme.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AppTheme.fantasy,
    );
  }
}

/// Classe per la gestione del tema
class ThemeManager {
  ThemeManager._();

  static AppTheme _currentTheme = AppTheme.fantasy;
  static AppTheme get currentTheme => _currentTheme;

  static void setTheme(AppTheme theme) {
    _currentTheme = theme;
  }

  static bool isThemeOwned(AppTheme theme, List<String> ownedItems) {
    final themeId = switch (theme) {
      AppTheme.fantasy => 'theme_fantasy',
      AppTheme.arcade => 'theme_arcade',
    };
    return ownedItems.contains(themeId);
  }

  static String getThemeDisplayName(AppTheme theme) {
    return switch (theme) {
      AppTheme.fantasy => 'Fantasy',
      AppTheme.arcade => 'Arcade',
    };
  }
}

/// Tema dell'applicazione
class QuesterTheme {
  /// Ottiene il ThemeData per il tema specificato
  static ThemeData getThemeData({
    required AppTheme themeType,
    bool darkTheme = true,
  }) {
    final colorScheme = _getColorScheme(themeType, darkTheme);
    final textTheme = _getTextTheme(themeType);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,  // ✅ Usa surface invece di background
    );
  }

  /// Color scheme in base al tema
  static ColorScheme _getColorScheme(AppTheme themeType, bool darkTheme) {
    if (themeType == AppTheme.arcade) {
      return const ColorScheme.dark(
        primary: ArcadeGreen,
        onPrimary: ArcadeBackground,
        secondary: ArcadePink,
        onSecondary: ArcadeBackground,
        surface: ArcadeSurface,
        onSurface: ArcadeText,
        error: ArcadeError,
        onError: ArcadeBackground,
      );
    }

    // Fantasy
    return darkTheme
        ? const ColorScheme.dark(
      primary: FantasyPurple,
      onPrimary: FantasyText,
      secondary: FantasyGold,
      onSecondary: FantasyBackground,
      surface: FantasySurface,
      onSurface: FantasyText,
      error: FantasyError,
      onError: FantasyText,
    )
        : const ColorScheme.light(
      primary: FantasyLightPurple,
      onPrimary: FantasyLightText,
      secondary: FantasyLightGold,
      onSecondary: FantasyLightText,
      surface: FantasyLightSurface,
      onSurface: FantasyLightText,
      error: FantasyLightError,
      onError: FantasyLightSurface,
    );
  }

  /// Text theme in base al tema
  static TextTheme _getTextTheme(AppTheme themeType) {
    if (themeType == AppTheme.arcade) {
      return const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 14),
        bodyMedium: TextStyle(fontSize: 12),
        bodySmall: TextStyle(fontSize: 10),
        labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      );
    }

    return const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 12),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 11),
    );
  }
}