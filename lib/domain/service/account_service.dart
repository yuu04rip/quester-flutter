// lib/domain/service/account_service.dart

import 'package:flutter/foundation.dart';
import '../../data/session/session_manager.dart';
import '../../data/models/user.dart';
import '/repository/user_repository.dart';
import 'sync_service.dart';

class AccountService {
  final SessionManager sessionManager;
  final UserRepository userRepository;
  final SyncService? syncService;

  AccountService({
    required this.sessionManager,
    required this.userRepository,
    this.syncService,
  });

  /// Recupera l'utente attualmente attivo dalla sessione
  Future<User?> getCurrentUser() async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) return null;
    return userRepository.getUserById(userId);
  }

  /// Aggiorna lo username dell'utente loggato e lo sincronizza
  Future<void> updateUsername(String newUsername) async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) {
      throw Exception('Nessun utente autenticato');
    }

    if (newUsername.trim().isEmpty) {
      throw Exception('Username vuoto');
    }

    final trimmedName = newUsername.trim();
    await userRepository.updateUsername(userId, trimmedName);

    // Sync immediato sul cloud
    final updatedUser = await userRepository.getUserById(userId);
    if (updatedUser != null && syncService != null) {
      await syncService!.pushUserToCloud(updatedUser);
    }
  }

  /// Elimina l'account dell'utente corrente e svuota la sessione
  Future<void> deleteAccountAndData() async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) {
      throw Exception('Nessun utente autenticato');
    }

    await userRepository.deleteAccount(userId);
    await sessionManager.clearSession();
  }
}