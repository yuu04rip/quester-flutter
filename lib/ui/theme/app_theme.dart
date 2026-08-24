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

/// Classe per la gestione del tema in tempo reale
class ThemeManager {
  ThemeManager._();

  static final ValueNotifier<AppTheme> themeNotifier = ValueNotifier<AppTheme>(AppTheme.fantasy);

  static AppTheme get currentTheme => themeNotifier.value;

  static void setTheme(AppTheme theme) {
    themeNotifier.value = theme;
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
      scaffoldBackgroundColor: colorScheme.surface,
      // Imposta il font globale in base al tema attivo
      fontFamily: themeType == AppTheme.arcade ? 'QuesterPixel' : 'QuesterFantasy',
    );
  }

  /// Color scheme in base al tema (Arcade potenziato con colori Neon)
  static ColorScheme _getColorScheme(AppTheme themeType, bool darkTheme) {
    if (themeType == AppTheme.arcade) {
      return const ColorScheme.dark(
        primary: Color(0xFF00FF66),     // Verde Neon vivido arcade
        onPrimary: Color(0xFF0D0221),
        secondary: Color(0xFFFF007F),   // Rosa Magenta Neon
        onSecondary: Color(0xFF0D0221),
        surface: Color(0xFF100323),     // Sfondo scuro sala giochi
        onSurface: Color(0xFF00FFFF),   // Testo Cyan brillante
        error: Color(0xFFFF2222),
        onError: Color(0xFF0D0221),
      );
    }

    // Fantasy
    return darkTheme
        ? const ColorScheme.dark(
      primary: FantasyPurple,
      onPrimary:FantasyText,
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

  /// Text theme in base al tema con i font espliciti
  static TextTheme _getTextTheme(AppTheme themeType) {
    if (themeType == AppTheme.arcade) {
      return const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'QuesterPixel'),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'QuesterPixel'),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF00FFFF), fontFamily: 'QuesterPixel'),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF00FFFF), fontFamily: 'QuesterPixel'),
        bodyLarge: TextStyle(fontSize: 14, color: Color(0xFFE0FFFF), fontFamily: 'QuesterPixel'),
        bodyMedium: TextStyle(fontSize: 12, color: Color(0xFFE0FFFF), fontFamily: 'QuesterPixel'),
        bodySmall: TextStyle(fontSize: 10, color: Color(0xFFB0EEEE), fontFamily: 'QuesterPixel'),
        labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'QuesterPixel'),
      );
    }

    // Tema Fantasy: Riabilitiamo il font QuesterFantasy
    return const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'QuesterFantasy'),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'QuesterFantasy'),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, fontFamily: 'QuesterFantasy'),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'QuesterFantasy'),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'QuesterFantasy'),
      bodyLarge: TextStyle(fontSize: 16, fontFamily: 'QuesterFantasy'),
      bodyMedium: TextStyle(fontSize: 14, fontFamily: 'QuesterFantasy'),
      bodySmall: TextStyle(fontSize: 12, fontFamily: 'QuesterFantasy'),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'QuesterFantasy'),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'QuesterFantasy'),
      labelSmall: TextStyle(fontSize: 11, fontFamily: 'QuesterFantasy'),
    );
  }
}