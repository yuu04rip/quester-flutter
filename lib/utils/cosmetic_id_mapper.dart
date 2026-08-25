// lib/utils/cosmetic_id_mapper.dart

import '../repository/user_repository.dart';

/// Mappa gli ID dei cosmetici tra Shop e Avatar.
/// Equivalente a CosmeticIdMapper in Kotlin.
class CosmeticIdMapper {
  CosmeticIdMapper._(); // Costruttore privato (come object in Kotlin)

  // ===== HAT / COPRICAPO =====

  static String? hatToShopId(HatType hat) {
    switch (hat) {
      case HatType.none:
        return null;
      case HatType.mago:
        return 'hat_mago';
      case HatType.cavaliere:
        return 'hat_cavaliere'; // 💡 Aggiunto supporto elmo cavaliere
      case HatType.scifi:
        return 'visor_futuristico';
      default:
        return null;
    }
  }

  static HatType shopIdToHat(String? shopId) {
    if (shopId == null || shopId.isEmpty) return HatType.none;
    switch (shopId) {
      case 'hat_mago':
        return HatType.mago;
      case 'hat_cavaliere':
      case 'elmo_cavaliere':
        return HatType.cavaliere; // 💡 Aggiunto supporto elmo cavaliere
      case 'visor_futuristico':
        return HatType.scifi;
      default:
        return HatType.none;
    }
  }

  static HatType parseHatType(String? value) {
    if (value == null || value.isEmpty || value.toUpperCase() == 'NONE') {
      return HatType.none;
    }

    final fromShop = shopIdToHat(value);
    if (fromShop != HatType.none) return fromShop;

    for (final hat in HatType.values) {
      if (hat.name.toUpperCase() == value.toUpperCase()) return hat;
    }
    return HatType.none;
  }

  // ===== WEAPON / ARMA =====

  static String? weaponToShopId(WeaponType weapon) {
    switch (weapon) {
      case WeaponType.none:
        return null;
      case WeaponType.staff:
        return 'staff_mago';
      case WeaponType.sword:
        return 'sword_cavaliere';
      case WeaponType.gun:
        return 'gun_spaziale';
      default:
        return null;
    }
  }

  static WeaponType shopIdToWeapon(String? shopId) {
    if (shopId == null || shopId.isEmpty) return WeaponType.none;
    switch (shopId) {
      case 'staff_mago':
        return WeaponType.staff;
      case 'sword_cavaliere':
        return WeaponType.sword;
      case 'gun_spaziale':
        return WeaponType.gun;
      default:
        return WeaponType.none;
    }
  }

  static WeaponType parseWeaponType(String? value) {
    if (value == null || value.isEmpty || value.toUpperCase() == 'NONE') {
      return WeaponType.none;
    }

    final fromShop = shopIdToWeapon(value);
    if (fromShop != WeaponType.none) return fromShop;

    for (final weapon in WeaponType.values) {
      if (weapon.name.toUpperCase() == value.toUpperCase()) return weapon;
    }
    return WeaponType.none;
  }

  // ===== FRAME / CORNICE =====

  static String? frameToShopId(FrameType frame) {
    switch (frame) {
      case FrameType.none:
      case FrameType.basic:
        return null; // La base è di default, non si compra nello shop
      case FrameType.mago:
        return 'frame_mago';
      case FrameType.cavaliere:
        return 'frame_cavaliere';
      case FrameType.scifi:
        return 'frame_scifi';
      default:
        return null;
    }
  }

  static FrameType shopIdToFrame(String? shopId) {
    if (shopId == null || shopId.isEmpty) return FrameType.basic;
    switch (shopId) {
      case 'frame_basic':
        return FrameType.basic;
      case 'frame_mago':
        return FrameType.mago;
      case 'frame_cavaliere':
        return FrameType.cavaliere;
      case 'frame_scifi':
        return FrameType.scifi;
      default:
        return FrameType.basic;
    }
  }

  static FrameType parseFrameType(String? value) {
    if (value == null || value.isEmpty || value.toUpperCase() == 'NONE') {
      return FrameType.basic;
    }

    final fromShop = shopIdToFrame(value);
    if (fromShop != FrameType.basic) return fromShop;

    for (final frame in FrameType.values) {
      if (frame.name.toUpperCase() == value.toUpperCase()) return frame;
    }
    return FrameType.basic;
  }

  // ===== THEME / TEMI (Inclusi i temi speciali e regali) =====

  static String? themeToShopId(String? themeName) {
    if (themeName == null) return null;
    switch (themeName.toLowerCase()) {
      case 'arcade':
        return 'theme_arcade';
      case 'fantasy':
        return 'theme_fantasy';
      case 'regale':
      case 'reward_tema_regale':
        return 'reward_tema_regale';
      default:
        return themeName;
    }
  }

  static String shopIdToTheme(String? shopId) {
    if (shopId == null || shopId.isEmpty) return 'fantasy';
    switch (shopId) {
      case 'theme_arcade':
        return 'arcade';
      case 'reward_tema_regale':
        return 'regale';
      case 'theme_fantasy':
      default:
        return 'fantasy';
    }
  }
}
