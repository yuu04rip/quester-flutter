// lib/data/repository/user_repository.dart

import 'package:flutter/foundation.dart';
import 'package:Quester/data/dao/user_dao.dart';
import 'package:Quester/data/dao/owned_cosmetic_dao.dart';
import 'package:Quester/data/models/user.dart';
import 'package:Quester/data/models/owned_cosmetic.dart';

/// Enum per i cosmetici equipaggiabili
enum HatType { none, mago, cavaliere, scifi }

enum WeaponType { none, staff, sword, gun }

enum FrameType { basic, none, mago, cavaliere, scifi }

/// Classe per i cosmetici avatar
class AvatarCosmetics {
  final HatType hat;
  final WeaponType weapon;
  final FrameType frame;

  const AvatarCosmetics({
    this.hat = HatType.none,
    this.weapon = WeaponType.none,
    this.frame = FrameType.none,
  });
}

class UserRepository extends ChangeNotifier {
  static const int xpBase = 100;
  static const int xpIncrement = 50;
  static const int maxLevel = 50;
  static const int absoluteMaxXp = 63750; // Valore massimo assoluto fisso

  final UserDao userDao;
  final OwnedCosmeticDao? ownedCosmeticDao;

  UserRepository({required this.userDao, this.ownedCosmeticDao});

  /// Notifica i listener del cambiamento dei dati
  void refresh() {
    notifyListeners();
  }

  /// Utente per ID con controllo di sicurezza automatico e self-healing
  Future<User?> getUserById(int userId) async {
    final user = await userDao.getUserById(userId);
    if (user == null) return null;

    final calculatedLevel = calculateLevelFromXp(user.xpTotale);
    final maxXp = getTotalXpRequiredForLevel(maxLevel);

    // Self-healing: correzione se XP o livello sono incoerenti o superano i limiti
    if (user.xpTotale > maxXp || user.livello != calculatedLevel) {
      final correctedUser = user.copyWith(
        xpTotale: user.xpTotale.clamp(0, maxXp),
        livello: calculatedLevel,
      );
      await userDao.updateUser(correctedUser);
      notifyListeners();
      
      if (calculatedLevel >= maxLevel) {
        await unlockCosmetic(userId, 'reward_corona');
        await unlockCosmetic(userId, 'reward_tema_regale');
      }
      return correctedUser;
    }

    if (calculatedLevel >= maxLevel) {
      await unlockCosmetic(userId, 'reward_corona');
      await unlockCosmetic(userId, 'reward_tema_regale');
    }
    
    return user;
  }

  /// XP richiesti per un livello
  int getXpRequiredForLevel(int level) {
    return xpBase + (level - 1) * xpIncrement;
  }

  /// XP totale necessario per raggiungere un livello specifico.
  int getTotalXpRequiredForLevel(int level) {
    if (level >= maxLevel) return absoluteMaxXp;
    var total = 0;
    for (var i = 1; i < level; i++) {
      total += getXpRequiredForLevel(i);
    }
    return total;
  }

  int _capXpAtMaxLevel(int totalXp) {
    return totalXp >= absoluteMaxXp ? absoluteMaxXp : totalXp;
  }

  /// Calcola livello da XP totali (Bloccato rigorosamente a maxLevel = 50)
  int calculateLevelFromXp(int totalXp) {
    final cappedXp = _capXpAtMaxLevel(totalXp);
    
    if (cappedXp >= absoluteMaxXp) return maxLevel;

    var level = 1;
    while (level < maxLevel) {
      final nextLevelXp = getTotalXpRequiredForLevel(level + 1);
      if (cappedXp < nextLevelXp) {
        break;
      }
      level++;
    }

    return level.clamp(1, maxLevel);
  }

  /// XP nel livello corrente
  int getXpInCurrentLevel(int totalXp, [int? level]) {
    final currentLevel = level ?? calculateLevelFromXp(totalXp);
    if (currentLevel >= maxLevel) {
      return getXpRequiredForLevel(maxLevel);
    }

    final currentLevelStart = getTotalXpRequiredForLevel(currentLevel);
    return (totalXp - currentLevelStart).clamp(0, totalXp);
  }

  /// Progresso XP (0.0 - 1.0) -> Al livello massimo restituisce sempre 1.0 (barra piena)
  double getXpProgress(int totalXp, [int? level]) {
    final currentLevel = level ?? calculateLevelFromXp(totalXp);
    if (currentLevel >= maxLevel) {
      return 1.0;
    }
    
    final xpInLevel = getXpInCurrentLevel(totalXp, currentLevel);
    final currentLevelStart = getTotalXpRequiredForLevel(currentLevel);
    final nextLevelStart = getTotalXpRequiredForLevel(currentLevel + 1);
    final xpNeededForLevel = nextLevelStart - currentLevelStart;
    
    if (xpNeededForLevel <= 0) return 1.0;
    return (xpInLevel / xpNeededForLevel).clamp(0.0, 1.0);
  }

  /// Monete per level-up
  int getLevelUpCoins(int level) {
    if (level >= 1 && level <= 10) return 3;
    if (level >= 11 && level <= 20) return 5;
    if (level >= 21 && level <= 30) return 8;
    if (level >= 31 && level <= 40) return 12;
    if (level >= 41 && level <= 50) return 20;
    return 0;
  }

  /// Aggiungi XP con sblocco automatico al livello 50
  Future<void> addXp(int userId, int xpGained) async {
    if (xpGained <= 0) return;

    final current = await getUserById(userId);
    if (current == null) return;

    final currentLevel = calculateLevelFromXp(current.xpTotale);
    final maxXp = getTotalXpRequiredForLevel(maxLevel);

    if (currentLevel >= maxLevel) {
      if (current.xpTotale != maxXp || current.livello != maxLevel) {
        await userDao.updateUser(
          current.copyWith(xpTotale: maxXp, livello: maxLevel),
        );
      }
      return;
    }

    final oldLevel = currentLevel;
    final newXpTotal = (current.xpTotale + xpGained).clamp(0, maxXp);
    final newLevel = calculateLevelFromXp(newXpTotal);

    var totalCoinsGained = 0;
    // Ciclo per accumulare monete di ogni livello superato
    for (var l = oldLevel + 1; l <= newLevel; l++) {
      totalCoinsGained += getLevelUpCoins(l);
    }

    final updatedUser = current.copyWith(
      xpTotale: newXpTotal,
      livello: newLevel,
      coins: current.coins + totalCoinsGained,
    );

    await userDao.updateUser(updatedUser);
    notifyListeners();

    if (newLevel >= maxLevel) {
      await unlockCosmetic(userId, 'reward_corona');
      await unlockCosmetic(userId, 'reward_tema_regale');
    }
  }

  /// Aggiungi monete
  Future<void> addCoins(int userId, int amount) async {
    if (amount <= 0) return;
    final current = await getUserById(userId);
    if (current == null) return;
    await userDao.updateUser(current.copyWith(coins: current.coins + amount));
    notifyListeners();
  }

  /// Spendi monete
  Future<bool> spendCoins(int userId, int amount) async {
    if (amount <= 0) return false;
    final current = await getUserById(userId);
    if (current == null) return false;
    if (current.coins < amount) return false;

    await userDao.updateUser(current.copyWith(coins: current.coins - amount));
    notifyListeners();
    return true;
  }

  /// Aggiorna username
  Future<bool> updateUsername(int userId, String newUsername) async {
    final clean = newUsername.trim().toLowerCase();
    if (clean.isEmpty || clean.length < 3) return false;

    final existing = await userDao.getUserByUsername(clean);
    if (existing != null && existing.id != userId) return false;

    final current = await getUserById(userId);
    if (current == null) return false;

    await userDao.updateUser(current.copyWith(username: clean));
    return true;
  }

  /// Elimina account specifico
  Future<bool> deleteAccount(int userId) async {
    if (await getUserById(userId) == null) return false;
    await ownedCosmeticDao?.deleteAllForUser(userId);
    await userDao.deleteUser(userId);
    return true;
  }

  /// Sblocca cosmetico
  Future<void> unlockCosmetic(int userId, String itemId) async {
    var resolvedId = itemId;
    if (resolvedId == 'elmo_cavaliere') {
      resolvedId = 'hat_cavaliere';
    } else if (resolvedId == 'theme_regale') {
      resolvedId = 'reward_tema_regale';
    }
    await ownedCosmeticDao?.insertOwned(
      OwnedCosmetic(userId: userId, itemId: resolvedId),
    );
  }

  /// Cosmetici posseduti (con normalizzazione ed eliminazione duplicati)
  Future<List<OwnedCosmetic>> getOwnedCosmetics(int userId) async {
    final rawOwned = await ownedCosmeticDao?.getOwnedByUser(userId) ?? [];

    final Map<String, OwnedCosmetic> uniqueMap = {};
    for (var cosmetic in rawOwned) {
      String resolvedId = cosmetic.itemId;
      if (resolvedId == 'elmo_cavaliere') {
        resolvedId = 'hat_cavaliere';
      } else if (resolvedId == 'theme_regale') {
        resolvedId = 'reward_tema_regale';
      }
      uniqueMap[resolvedId] = OwnedCosmetic(
        userId: cosmetic.userId,
        itemId: resolvedId,
      );
    }

    return uniqueMap.values.toList();
  }

  /// Cosmetici equipaggiati
  Future<AvatarCosmetics> getEquippedCosmetics(int userId) async {
    final user = await getUserById(userId);
    if (user == null) return const AvatarCosmetics();

    return AvatarCosmetics(
      hat: _parseHat(user.equippedHat),
      weapon: _parseWeapon(user.equippedWeapon),
      frame: _parseFrame(user.equippedFrame),
    );
  }

  /// Salva cosmetici equipaggiati
  Future<void> saveEquippedCosmetics(
      int userId,
      AvatarCosmetics cosmetics,
      ) async {
    final current = await getUserById(userId);
    if (current == null) return;

    await userDao.updateUser(
      current.copyWith(
        equippedHat: cosmetics.hat.name,
        equippedWeapon: cosmetics.weapon.name,
        equippedFrame: cosmetics.frame.name,
      ),
    );
  }

  /// Parser per Hat
  HatType _parseHat(String? value) {
    if (value == null || value.isEmpty || value.contains('NONE')) {
      return HatType.none;
    }
    return HatType.values.firstWhere(
          (e) => e.name == value.toLowerCase(),
      orElse: () => HatType.none,
    );
  }

  /// Parser per Weapon
  WeaponType _parseWeapon(String? value) {
    if (value == null || value.isEmpty || value.contains('NONE')) {
      return WeaponType.none;
    }
    return WeaponType.values.firstWhere(
          (e) => e.name == value.toLowerCase(),
      orElse: () => WeaponType.none,
    );
  }

  /// Parser per Frame
  FrameType _parseFrame(String? value) {
    if (value == null || value.isEmpty || value.contains('NONE')) {
      return FrameType.basic;
    }
    return FrameType.values.firstWhere(
          (e) => e.name == value.toLowerCase(),
      orElse: () => FrameType.basic,
    );
  }
}