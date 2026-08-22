// lib/screens/profile_constants.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';  // ✅ Import per i colori

// ============================================================
// 1. SISTEMA XP E LIVELLI (LINEARE)
// ============================================================

const int XP_BASE = 100;
const int XP_INCREMENT = 50;

int getXpRequiredForLevel(int level) {
  return XP_BASE + (level - 1) * XP_INCREMENT;
}

int calculateLevelFromXp(int totalXp) {
  var remainingXp = totalXp;
  var level = 1;

  while (true) {
    final xpNeeded = getXpRequiredForLevel(level);
    if (remainingXp >= xpNeeded) {
      remainingXp -= xpNeeded;
      level++;
    } else {
      break;
    }
  }
  return level;
}

int getXpInCurrentLevel(int totalXp, [int? level]) {
  final currentLevel = level ?? calculateLevelFromXp(totalXp);
  var totalXpForPreviousLevels = 0;
  for (var i = 1; i < currentLevel; i++) {
    totalXpForPreviousLevels += getXpRequiredForLevel(i);
  }
  return totalXp - totalXpForPreviousLevels;
}

double getXpProgress(int totalXp, [int? level]) {
  final currentLevel = level ?? calculateLevelFromXp(totalXp);
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