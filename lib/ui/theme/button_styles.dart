// lib/ui/button_styles.dart

import 'package:flutter/material.dart';
import 'colors.dart';
import 'app_theme.dart';

/// Stile per i bottoni in base al tema
class ButtonStyleFactory {
  ButtonStyleFactory._();

  /// Ottiene lo stile del bottone in base al tema
  static ButtonStyle getButtonStyle(AppTheme theme) {
    switch (theme) {
      case AppTheme.fantasy:
        return _fantasyButtonStyle;
      case AppTheme.arcade:
        return _arcadeButtonStyle;
      default:
        return _fantasyButtonStyle;
    }
  }

  /// Stile Fantasy
  static final ButtonStyle _fantasyButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(FantasyGold),
    foregroundColor: WidgetStateProperty.all(FantasyBackground),
    textStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        fontFamily: 'serif',
      ),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    // Lunghezza aumentata modificando l'horizontal padding da 24 a 40
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
    ),
  );

  /// Stile Arcade
  static final ButtonStyle _arcadeButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.white),
    foregroundColor: WidgetStateProperty.all(Colors.black),
    textStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
    ),
    // Lunghezza aumentata modificando l'horizontal padding da 24 a 40
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
    ),
  );
}