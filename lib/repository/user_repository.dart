// lib/data/repository/user_repository.dart

import '/data/dao/user_dao.dart';
import '/data/dao/owned_cosmetic_dao.dart';
import '/data/models/user.dart';
import '/data/models/owned_cosmetic.dart';

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

class UserRepository {
  static const int xpBase = 100;
  static const int xpIncrement = 50;
  static const int maxLevel = 50;
  static const int absoluteMaxXp = 63750; // 🛡️ Valore massimo assoluto fisso

  final UserDao userDao;
  final OwnedCosmeticDao? ownedCosmeticDao;

  UserRepository({required this.userDao, this.ownedCosmeticDao});

  /// Utente per ID con controllo di sicurezza automatico al livello 50
  Future<User?> getUserById(int userId) async {
    final user = await userDao.getUserById(userId);
    if (user != null) {
      final maxXp = getTotalXpRequiredForLevel(maxLevel);

      // 🛡️ CONTROLLO CORRETTIVO: Se l'utente ha più XP del massimo consentito
      if (user.xpTotale > maxXp || user.livello > maxLevel) {
        final correctedUser = user.copyWith(
          xpTotale: maxXp,
          livello: maxLevel,
        );
        await userDao.updateUser(correctedUser);
        await unlockCosmetic(userId, 'reward_corona');
        await unlockCosmetic(userId, 'reward_tema_regale');
        return correctedUser;
      }

      final currentLevel = calculateLevelFromXp(user.xpTotale);
      if (currentLevel >= maxLevel) {
        await unlockCosmetic(userId, 'reward_corona');
        await unlockCosmetic(userId, 'reward_tema_regale');
      }
    }
    return user;
  }

  /// XP richiesti per un livello
  int getXpRequiredForLevel(int level) {
    return xpBase + (level - 1) * xpIncrement;
  }

  /// XP totale necessario per raggiungere un livello specifico.
  int getTotalXpRequiredForLevel(int level) {
    if (level >= maxLevel) return absoluteMaxXp; // 🛡️ Ritorna direttamente 63750 per il livello 50
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
    var remainingXp = cappedXp;
    var level = 1;

    while (level < maxLevel) {
      final xpNeeded = getXpRequiredForLevel(level);
      if (remainingXp >= xpNeeded) {
        remainingXp -= xpNeeded;
        level++;
      } else {
        break;
      }
    }

    return level >= maxLevel ? maxLevel : level.clamp(1, maxLevel);
  }

  /// XP nel livello corrente
  int getXpInCurrentLevel(int totalXp, [int? level]) {
    final currentLevel = level ?? calculateLevelFromXp(totalXp);
    if (currentLevel >= maxLevel) {
      return getXpRequiredForLevel(maxLevel);
    }

    var xpForPreviousLevels = 0;
    for (var i = 1; i < currentLevel; i++) {
      xpForPreviousLevels += getXpRequiredForLevel(i);
    }
    return (totalXp - xpForPreviousLevels) < 0
        ? 0
        : (totalXp - xpForPreviousLevels);
  }

  /// Progresso XP (0.0 - 1.0) -> Al livello massimo restituisce sempre 1.0 (barra piena)
  double getXpProgress(int totalXp, [int? level]) {
    final currentLevel = level ?? calculateLevelFromXp(totalXp);
    if (currentLevel >= maxLevel) {
      return 1.0;
    }
    final xpInCurrent = getXpInCurrentLevel(totalXp, currentLevel);
    final xpNeeded = getXpRequiredForLevel(currentLevel);
    return (xpInCurrent / xpNeeded).clamp(0.0, 1.0);
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

  /// ✅ Aggiungi XP con sblocco automatico al livello 50
  Future<void> addXp(int userId, int xpGained) async {
    if (xpGained <= 0) return;

    final current = await getUserById(userId);
    if (current == null) return;

    final currentLevel = calculateLevelFromXp(current.xpTotale);
    if (currentLevel >= maxLevel) {
      final cappedXp = getTotalXpRequiredForLevel(maxLevel);
      if (current.xpTotale != cappedXp || current.livello != maxLevel) {
        await userDao.updateUser(
          current.copyWith(xpTotale: cappedXp, livello: maxLevel),
        );
      }
      return;
    }

    final oldLevel = currentLevel;
    final maxXp = getTotalXpRequiredForLevel(maxLevel);
    final newXpTotal = (current.xpTotale + xpGained).clamp(0, maxXp);
    final newLevel = calculateLevelFromXp(newXpTotal);

    var updatedUser = current.copyWith(
      xpTotale: newLevel >= maxLevel ? maxXp : newXpTotal,
      livello: newLevel,
    );

    if (newLevel > oldLevel) {
      final coinsEarned = getLevelUpCoins(newLevel);
      updatedUser = updatedUser.copyWith(
        coins: updatedUser.coins + coinsEarned,
      );
    }

    await userDao.updateUser(updatedUser);

    // 🛡️ CONTROLLO DI SICUREZZA UNIVERSALE:
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
  }

  /// Spendi monete
  Future<bool> spendCoins(int userId, int amount) async {
    if (amount <= 0) return false;
    final current = await getUserById(userId);
    if (current == null) return false;
    if (current.coins < amount) return false;

    await userDao.updateUser(current.copyWith(coins: current.coins - amount));
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
    if (value == null || value.isEmpty || value.contains('NONE'))
      return HatType.none;
    return HatType.values.firstWhere(
          (e) => e.name == value.toLowerCase(),
      orElse: () => HatType.none,
    );
  }

  /// Parser per Weapon
  WeaponType _parseWeapon(String? value) {
    if (value == null || value.isEmpty || value.contains('NONE'))
      return WeaponType.none;
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