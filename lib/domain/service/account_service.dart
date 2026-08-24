// lib/domain/service/account_service.dart

import '../../data/session/session_manager.dart';
import '../../data/models/user.dart';
import '/repository/user_repository.dart';

class AccountService {
  final SessionManager sessionManager;
  final UserRepository userRepository;

  AccountService({
    required this.sessionManager,
    required this.userRepository,
  });

  /// Recupera l'utente attualmente attivo dalla sessione
  Future<User?> getCurrentUser() async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) return null;
    return userRepository.getUserById(userId);
  }

  /// Aggiorna lo username dell'utente loggato
  Future<void> updateUsername(String newUsername) async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) {
      throw Exception('Nessun utente autenticato');
    }

    if (newUsername.trim().isEmpty) {
      throw Exception('Username vuoto');
    }

    await userRepository.updateUsername(userId, newUsername.trim());
  }

  /// Elimina l'account dell'utente corrente e svuota la sessione
  Future<void> deleteAccountAndData() async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) {
      throw Exception('Nessun utente autenticato');
    }

    // Utilizziamo il metodo mirato per eliminare solo il singolo account e i suoi dati
    await userRepository.deleteAccount(userId);
    await sessionManager.clearSession();
  }
}