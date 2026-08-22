// lib/data/session/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

/// Gestione della sessione utente.
/// Equivalente a SessionManager in Kotlin.
class SessionManager {

  // Chiavi per il salvataggio della sessione
  static const String LOGGED_USER_ID = 'logged_user_id';
  static const String IS_LOGGED_IN = 'is_logged_in';

  /// Verifica se l'utente è loggato
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_LOGGED_IN) ?? false;
  }

  /// Ottiene l'ID dell'utente loggato
  Future<int?> loggedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(LOGGED_USER_ID);
  }

  /// Crea una nuova sessione
  Future<void> createSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    // Puliamo eventuali rimasugli prima di scrivere la nuova sessione
    await prefs.clear();
    await prefs.setInt(LOGGED_USER_ID, userId);
    await prefs.setBool(IS_LOGGED_IN, true);
  }

  /// Cancella la sessione corrente
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    // Svuota completamente le preferenze
    await prefs.clear();
  }
}