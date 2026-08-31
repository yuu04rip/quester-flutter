// lib/widgets/avatar_view.dart

import 'package:flutter/material.dart';
import '/repository/user_repository.dart';
import 'frame_basic.dart';
import 'frame_scifi.dart';
import 'frame_mago.dart';       // Importato il nuovo frame del Mago
import 'frame_cavaliere.dart';  // Importato il nuovo frame del Cavaliere

/// Vista avatar con cosmetici
class AvatarView extends StatelessWidget {
  final AvatarCosmetics cosmetics;
  final double size;
  final double scale;
  final double verticalOffset;
  final VoidCallback? onClick;

  const AvatarView({
    super.key,
    this.cosmetics = const AvatarCosmetics(),
    this.size = 200,
    this.scale = 1.0,
    this.verticalOffset = 0,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final Widget characterContent = ClipOval(
      child: Transform.scale(
        scale: scale,
        child: Transform.translate(
          offset: Offset(0, verticalOffset),
          child: Stack(
            children: [
              // 1. Arma equipaggiata
              Positioned.fill(
                child: Image.asset(
                  _getWeaponAsset(cosmetics.weapon),
                  fit: BoxFit.contain,
                ),
              ),
              // 2. Corpo
              Positioned.fill(
                child: Image.asset(
                  'assets/images/char_body.png',
                  fit: BoxFit.contain,
                ),
              ),
              // 3. Vestito
              Positioned.fill(
                child: Image.asset(
                  'assets/images/char_outfit.png',
                  fit: BoxFit.contain,
                ),
              ),
              // 4. Cappello / Elmo equipaggiato
              if (_getHatAsset(cosmetics.hat) != null)
                Positioned.fill(
                  child: Image.asset(
                    _getHatAsset(cosmetics.hat)!,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: onClick,
      child: _buildFrameWrapper(characterContent),
    );
  }

  /// Restituisce il percorso dell'immagine dell'arma in base al tipo
  String _getWeaponAsset(WeaponType weapon) {
    switch (weapon) {
      case WeaponType.gun:
        return 'assets/images/char_weapon_laser.png';
      case WeaponType.staff:
        return 'assets/images/char_weapon_staff.png';
      case WeaponType.sword:
        return 'assets/images/char_weapon_blade.png';
      case WeaponType.none:
        return 'assets/images/char_weapon_wood.png';
    }
  }

  /// Restituisce il percorso dell'immagine del cappello in base al tipo
  String? _getHatAsset(HatType hat) {
    switch (hat) {
      case HatType.scifi:
        return 'assets/images/char_visor.png';
      case HatType.mago:
        return 'assets/images/char_wizard.png';
      case HatType.cavaliere:
        return 'assets/images/char_helm.png';
      case HatType.none:
        return 'assets/images/char_hat.png';
    }
  }

  /// Seleziona la cornice corretta in base al tipo equipaggiato
  Widget _buildFrameWrapper(Widget child) {
    switch (cosmetics.frame) {
      case FrameType.basic:
        return FrameBasic(size: size, child: child);

      case FrameType.cavaliere:
        return FrameCavaliere(size: size, child: child); // Ora usa la cornice specifica del Cavaliere!

      case FrameType.mago:
        return FrameMago(size: size, child: child);       // Ora usa la cornice specifica del Mago!

      case FrameType.scifi:
        return FrameSciFi(size: size, child: child);

      case FrameType.none:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E1B2E),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: child,
        );
    }
  }
}