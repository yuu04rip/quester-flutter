// lib/data/preferences/theme_preferences.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../ui/theme/app_theme.dart';  // Import da app_theme.dart

/// Classe per la gestione delle preferenze del tema.
/// Equivalente a ThemePreferences in Kotlin.
class ThemePreferences {
  // Chiave per il salvataggio del tema
  static const String THEME_KEY = 'selected_theme';

  /// Salva il tema nelle SharedPreferences
  Future<void> saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(THEME_KEY, theme.name);
  }

  /// Legge il tema salvato (con fallback a FANTASY)
  Future<AppTheme> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(THEME_KEY) ?? AppTheme.fantasy.name;

    try {
      return AppTheme.fromString(themeName);
    } catch (_) {
      return AppTheme.fantasy;
    }
  }
}