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
      case AppTheme.basic:
        return _basicButtonStyle;
      case AppTheme.fantasy:
        return _fantasyButtonStyle;
      case AppTheme.arcade:
        return _arcadeButtonStyle;
      case AppTheme.regale:
        return _regaleButtonStyle;
    }
  }

  /// Stile Base
  static final ButtonStyle _basicButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(const Color(0xFF7C4DFF)),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    textStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
    ),
  );

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
    // Lunghezza aumentata con horizontal padding a 40
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
    // Lunghezza aumentata con horizontal padding a 40
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
    ),
  );

  /// Stile Regale (Oro brillante e dettagli imperiali)
  static final ButtonStyle _regaleButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(RegalGold),
    foregroundColor: WidgetStateProperty.all(RegalBackground),
    elevation: WidgetStateProperty.all(8),
    shadowColor: WidgetStateProperty.all(RegalGold.withValues(alpha: 0.5)),
    textStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        fontFamily: 'QuesterFantasy',
      ),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: RegalGoldLight,
          width: 1.5,
        ),
      ),
    ),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
    ),
  );
}