// lib/data/session/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

/// Gestione della sessione utente.
/// Equivalente a SessionManager in Kotlin.
class SessionManager {

  // Chiavi per il salvataggio della sessione
  static const String loggedUserIdKey = 'logged_user_id';
  static const String isLoggedInKey = 'is_logged_in';

  /// Verifica se l'utente è loggato
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  /// Ottiene l'ID dell'utente loggato
  Future<int?> loggedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(loggedUserIdKey);
  }

  /// Crea una nuova sessione
  Future<void> createSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    // Imposta direttamente i dati di sessione senza cancellare altre preferenze (es. temi)
    await prefs.setInt(loggedUserIdKey, userId);
    await prefs.setBool(isLoggedInKey, true);
  }

  /// Cancella la sessione corrente
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    // Rimuove solo le chiavi della sessione, preservando il resto delle preferenze
    await prefs.remove(loggedUserIdKey);
    await prefs.remove(isLoggedInKey);
  }
}