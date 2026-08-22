// lib/domain/service/currency_service.dart

import '../../data/session/session_manager.dart';
import '/repository/user_repository.dart';

class CurrencyService {
  final UserRepository userRepository;
  final SessionManager sessionManager;

  CurrencyService({
    required this.userRepository,
    required this.sessionManager,
  });

  /// Monete per ogni livello guadagnato
  int coinsForLevel(int levelsGained) {
    return levelsGained < 0 ? 0 : levelsGained * 50;
  }

  /// Al level-up, assegna monete
  Future<void> onLevelUp(int beforeLevel, int afterLevel) async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) return;

    final gained = (afterLevel - beforeLevel) < 0 ? 0 : (afterLevel - beforeLevel);
    final coins = coinsForLevel(gained);
    await userRepository.addCoins(userId, coins);
  }

  /// Evento speciale, assegna monete
  Future<void> onSpecialEvent(int coins) async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) return;

    await userRepository.addCoins(userId, coins < 0 ? 0 : coins);
  }
}