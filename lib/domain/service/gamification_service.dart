// lib/domain/service/gamification_service.dart

import '../../data/session/session_manager.dart';
import '/repository/user_repository.dart';

class GamificationService {
  final UserRepository userRepository;
  final SessionManager sessionManager;

  GamificationService({
    required this.userRepository,
    required this.sessionManager,
  });

  /// Assegna valuta per level-up
  Future<void> awardCurrencyForLevelUp(int levelsGained) async {
    if (levelsGained <= 0) return;
    final userId = await sessionManager.loggedUserId();
    if (userId == null) return;

    final bonus = levelsGained * 50;
    await userRepository.addCoins(userId, bonus);
  }

  /// Assegna valuta per evento speciale
  Future<void> awardCurrencyForSpecialEvent(int amount) async {
    if (amount < 0) throw Exception('Amount deve essere >= 0');
    final userId = await sessionManager.loggedUserId();
    if (userId == null) return;

    await userRepository.addCoins(userId, amount);
  }
}