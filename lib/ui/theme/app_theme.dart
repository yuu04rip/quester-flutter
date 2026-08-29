// lib/ui/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'colors.dart';

/// Tipo di tema
enum AppTheme {
  basic,
  fantasy,
  arcade,
  regale;

  static AppTheme fromString(String value) {
    return AppTheme.values.firstWhere(
          (theme) => theme.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AppTheme.basic,
    );
  }
}

/// Classe per la gestione del tema in tempo reale
class ThemeManager {
  ThemeManager._();

  // Di default l'app parte con il tema basico
  static final ValueNotifier<AppTheme> themeNotifier =
  ValueNotifier<AppTheme>(AppTheme.basic);

  static AppTheme get currentTheme => themeNotifier.value;

  static void setTheme(AppTheme theme) {
    themeNotifier.value = theme;
  }

  static bool isThemeOwned(AppTheme theme, List<String> ownedItems) {
    final themeId = switch (theme) {
      AppTheme.basic => '', // Il tema base non si compra nello shop
      AppTheme.fantasy => 'theme_fantasy',
      AppTheme.arcade => 'theme_arcade',
      AppTheme.regale => 'reward_tema_regale',
    };
    if (themeId.isEmpty) return true; // Il base è sempre posseduto
    return ownedItems.contains(themeId);
  }

  static String getThemeDisplayName(AppTheme theme) {
    return switch (theme) {
      AppTheme.basic => 'Base',
      AppTheme.fantasy => 'Bacheca Fantasy',
      AppTheme.arcade => 'Arcade',
      AppTheme.regale => 'Regale 3D',
    };
  }
}

/// Tema dell'applicazione
class QuesterTheme {
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
      fontFamily: themeType == AppTheme.arcade ? 'QuesterPixel' : 'QuesterFantasy',

      // PERSONALIZZAZIONI PER IL TEMA FANTASY (Acquistabile)
      cardTheme: themeType == AppTheme.fantasy
          ? CardThemeData(
        color: const Color(0xFF161122),
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF6A4FA5), width: 1.2),
        ),
      )
          : themeType == AppTheme.regale
          ? CardThemeData(
        color: const Color(0xFF181109),
        elevation: 10,
        shadowColor: const Color(0xFF000000).withValues(alpha: 0.50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFD7B46A), width: 1.2),
        ),
      )
          : null,

      appBarTheme: themeType == AppTheme.fantasy
          ? const AppBarTheme(
        backgroundColor: Color(0xFF130E1D),
        foregroundColor: FantasyGold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'QuesterFantasy',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: FantasyGold,
        ),
      )
          : themeType == AppTheme.regale
          ? const AppBarTheme(
        backgroundColor: Color(0xFF120D08),
        foregroundColor: Color(0xFFF4C95D),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'QuesterFantasy',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Color(0xFFF4C95D),
        ),
      )
          : null,

      dialogTheme: themeType == AppTheme.fantasy
          ? DialogThemeData(
        backgroundColor: const Color(0xFF181226),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF7A59C2), width: 1.5),
        ),
      )
          : themeType == AppTheme.regale
          ? DialogThemeData(
        backgroundColor: const Color(0xFF151008),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFD7B46A), width: 1.5),
        ),
      )
          : null,

      elevatedButtonTheme: themeType == AppTheme.fantasy
          ? ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FantasyGold,
          foregroundColor: FantasyBackground,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'QuesterFantasy',
          ),
        ),
      )
          : themeType == AppTheme.regale
          ? ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF4C95D),
          foregroundColor: const Color(0xFF1A1208),
          disabledBackgroundColor: const Color(0xFF5E4A26),
          disabledForegroundColor: const Color(0xFFC7B38A),
          elevation: 6,
          shadowColor: const Color(0xFF000000).withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFFFF0CA), width: 1.0),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
            letterSpacing: 0.9,
            fontFamily: 'QuesterFantasy',
          ),
        ),
      )
          : null,

      inputDecorationTheme: themeType == AppTheme.fantasy
          ? InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF130E1D),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5E4399), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A3478), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FantasyGold, width: 1.5),
        ),
        labelStyle: const TextStyle(color: FantasyText, fontFamily: 'QuesterFantasy'),
        hintStyle: const TextStyle(color: Color(0xFF8A79B0), fontFamily: 'QuesterFantasy'),
      )
          : themeType == AppTheme.regale
          ? InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF140F09),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF8B6A33), width: 1.1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF705427), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF4C95D), width: 1.8),
        ),
        labelStyle: const TextStyle(color: Color(0xFFE0C489), fontFamily: 'QuesterFantasy'),
        hintStyle: const TextStyle(color: Color(0xFF9D7B43), fontFamily: 'QuesterFantasy'),
      )
          : null,

      chipTheme: themeType == AppTheme.fantasy
          ? ChipThemeData(
        backgroundColor: const Color(0xFF1E172F),
        selectedColor: const Color(0xFF3B2A66),
        labelStyle: const TextStyle(color: FantasyText, fontFamily: 'QuesterFantasy'),
        secondaryLabelStyle: const TextStyle(color: FantasyGold, fontFamily: 'QuesterFantasy'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF5A438F), width: 1),
        ),
      )
          : themeType == AppTheme.regale
          ? ChipThemeData(
        backgroundColor: const Color(0xFF1C140B),
        selectedColor: const Color(0xFF33230F),
        labelStyle: const TextStyle(color: Color(0xFFFFEEC8), fontFamily: 'QuesterFantasy'),
        secondaryLabelStyle: const TextStyle(color: Color(0xFFF4C95D), fontFamily: 'QuesterFantasy'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
          side: const BorderSide(color: Color(0xFFB8914B), width: 1),
        ),
      )
          : null,

      floatingActionButtonTheme: themeType == AppTheme.fantasy
          ? const FloatingActionButtonThemeData(
        backgroundColor: FantasyGold,
        foregroundColor: FantasyBackground,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      )
          : themeType == AppTheme.regale
          ? const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFF4C95D),
        foregroundColor: Color(0xFF1A1208),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFFFE7B0), width: 1.2),
        ),
      )
          : null,

      navigationBarTheme: themeType == AppTheme.fantasy
          ? const NavigationBarThemeData(
        backgroundColor: Color(0xFF130E1D),
        indicatorColor: Color(0xFF3A2B5E),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'QuesterFantasy',
            fontWeight: FontWeight.w600,
            color: FantasyGold,
          ),
        ),
      )
          : themeType == AppTheme.regale
          ? const NavigationBarThemeData(
        backgroundColor: Color(0xFF120D08),
        indicatorColor: Color(0xFF3A2A12),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'QuesterFantasy',
            fontWeight: FontWeight.w600,
            color: Color(0xFFF4C95D),
          ),
        ),
      )
          : null,

      dividerTheme: themeType == AppTheme.fantasy
          ? const DividerThemeData(
        color: Color(0xFF42306B),
        thickness: 0.8,
        space: 1,
      )
          : themeType == AppTheme.regale
          ? const DividerThemeData(
        color: Color(0xFF4D3A1C),
        thickness: 0.8,
        space: 1,
      )
          : null,
    );
  }

  static ColorScheme _getColorScheme(AppTheme themeType, bool darkTheme) {
    if (themeType == AppTheme.arcade) {
      return const ColorScheme.dark(
        primary: Color(0xFF00FF66),
        onPrimary: Color(0xFF0D0221),
        secondary: Color(0xFFFF007F),
        onSecondary: Color(0xFF0D0221),
        surface: Color(0xFF100323),
        onSurface: Color(0xFF00FFFF),
        error: Color(0xFFFF2222),
        onError: Color(0xFF0D0221),
      );
    }

    if (themeType == AppTheme.regale) {
      return const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: Color(0xFFF4C95D),
        onPrimary: Color(0xFF1A1208),
        primaryContainer: Color(0xFF3A2A12),
        onPrimaryContainer: Color(0xFFFFF4D6),
        secondary: Color(0xFFE0A93B),
        onSecondary: Color(0xFF1A1208),
        secondaryContainer: Color(0xFF2A1C0C),
        onSecondaryContainer: Color(0xFFFFE7B0),
        tertiary: Color(0xFFCBA15C),
        onTertiary: Color(0xFF1A1208),
        surface: Color(0xFF0B0805),
        onSurface: Color(0xFFF8ECD1),
        surfaceContainerLowest: Color(0xFF090705),
        surfaceContainerLow: Color(0xFF120D08),
        surfaceContainer: Color(0xFF181109),
        surfaceContainerHigh: Color(0xFF21170C),
        surfaceContainerHighest: Color(0xFF2B1D0F),
        outline: Color(0xFF6E552B),
        outlineVariant: Color(0xFF4D3A1C),
        error: Color(0xFFFF5A7A),
        onError: Color(0xFF1A0A0E),
      );
    }

    if (themeType == AppTheme.fantasy) {
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

    // Tema Base / Default (quello classico iniziale dell'app)
    return darkTheme
        ? const ColorScheme.dark(
      primary: Color(0xFF7C4DFF),
      onPrimary: Colors.white,
      secondary: Color(0xFFFFD700),
      onSecondary: Colors.black,
      surface: Color(0xFF121212),
      onSurface: Colors.white,
    )
        : const ColorScheme.light(
      primary: Color(0xFF6200EE),
      onPrimary: Colors.white,
      secondary: Color(0xFF03DAC6),
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  }

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

    if (themeType == AppTheme.regale) {
      return const TextTheme(
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFFF4C95D), letterSpacing: 1.5, fontFamily: 'QuesterFantasy'),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFFF4D6), letterSpacing: 1.2, fontFamily: 'QuesterFantasy'),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFFF4C95D), fontFamily: 'QuesterFantasy'),
        titleMedium: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: Color(0xFFE0C489), fontFamily: 'QuesterFantasy'),
        titleSmall: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFFFFF4D6), fontFamily: 'QuesterFantasy'),
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFFFF4D6), fontFamily: 'QuesterFantasy'),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFCBA15C), fontFamily: 'QuesterFantasy'),
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF9D7B43), fontFamily: 'QuesterFantasy'),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFF4C95D), letterSpacing: 1.2, fontFamily: 'QuesterFantasy'),
        labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFFFF4D6), fontFamily: 'QuesterFantasy'),
        labelSmall: TextStyle(fontSize: 11, color: Color(0xFFE0C489), fontFamily: 'QuesterFantasy'),
      );
    }

    if (themeType == AppTheme.fantasy) {
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

    // Tema Base / Default
    return const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 12),
    );
  }
}