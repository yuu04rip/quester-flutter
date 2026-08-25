// lib/screens/profile_constants.dart

// ============================================================
// 1. SISTEMA XP E LIVELLI (LINEARE CON CAP A 50)
// ============================================================

const int XP_BASE = 100;
const int XP_INCREMENT = 50;
const int MAX_LEVEL = 50; // 🛡️ Limite massimo imposto

int getXpRequiredForLevel(int level) {
  return XP_BASE + (level - 1) * XP_INCREMENT;
}

/// Calcola il totale esatto di XP necessari per arrivare al livello massimo
int getTotalXpRequiredForLevel(int level) {
  var total = 0;
  for (var i = 1; i < level; i++) {
    total += getXpRequiredForLevel(i);
  }
  return total;
}

int calculateLevelFromXp(int totalXp) {
  final maxXp = getTotalXpRequiredForLevel(MAX_LEVEL);
  // Se gli XP superano il cap massimo, blocca direttamente al livello 50
  if (totalXp >= maxXp) return MAX_LEVEL;

  var remainingXp = totalXp;
  var level = 1;

  while (level < MAX_LEVEL) {
    final xpNeeded = getXpRequiredForLevel(level);
    if (remainingXp >= xpNeeded) {
      remainingXp -= xpNeeded;
      level++;
    } else {
      break;
    }
  }
  return level.clamp(1, MAX_LEVEL);
}

int getXpInCurrentLevel(int totalXp, [int? level]) {
  final currentLevel = level ?? calculateLevelFromXp(totalXp);
  if (currentLevel >= MAX_LEVEL) {
    return getXpRequiredForLevel(MAX_LEVEL); // Barra piena al massimo livello
  }

  var totalXpForPreviousLevels = 0;
  for (var i = 1; i < currentLevel; i++) {
    totalXpForPreviousLevels += getXpRequiredForLevel(i);
  }
  return totalXp - totalXpForPreviousLevels;
}

double getXpProgress(int totalXp, [int? level]) {
  final currentLevel = level ?? calculateLevelFromXp(totalXp);
  if (currentLevel >= MAX_LEVEL) {
    return 1.0; // 🛡️ Barra sempre al 100% una volta raggiunto il livello 50
  }
  final xpInCurrent = getXpInCurrentLevel(totalXp, currentLevel);
  final xpNeeded = getXpRequiredForLevel(currentLevel);
  return (xpInCurrent / xpNeeded).clamp(0.0, 1.0);
}

// ============================================================
// 2. RICOMPENSE MISSIONI
// ============================================================

const int XP_DAILY = 30;
const int XP_WEEKLY = 120;
const int XP_SPECIAL = 400;

const int COINS_DAILY = 1;
const int COINS_WEEKLY = 5;
const int COINS_SPECIAL = 15;

int getLevelUpCoins(int level) {
  if (level >= 1 && level <= 10) return 3;
  if (level >= 11 && level <= 20) return 5;
  if (level >= 21 && level <= 30) return 8;
  if (level >= 31 && level <= 40) return 12;
  if (level >= 41 && level <= 50) return 20;
  return 0;
}

// ============================================================
// 3. COSMETICI E PREZZI
// ============================================================

const int PRICE_FRAME = 30;
const int PRICE_COSMETIC = 100;
const int PRICE_THEME = 500;

const List<String> FRAME_NAMES = [
  'Cornice del Mago',
  'Cornice del Cavaliere',
  'Cornice Sci-Fi',
];

const List<String> COSMETIC_NAMES = [
  'Cappello del Mago',
  'Bastone del Mago',
  'Pistola Spaziale',
  'Spada del Cavaliere',
  'Elmo del Cavaliere',
  'Visore Futuristico',
];

const List<String> THEME_NAMES = [
  'Arcade',
  'Bacheca Fantasy',
];