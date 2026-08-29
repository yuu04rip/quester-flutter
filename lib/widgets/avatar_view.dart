// lib/widgets/avatar_view.dart

import 'package:flutter/material.dart';
import '/repository/user_repository.dart';
import 'frame_basic.dart';
import 'frame_scifi.dart'; // Importato il file della cornice Sci-Fi

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
    // Contenuto interno dell'avatar (il personaggio con vestiti, armi, ecc.)
    final Widget characterContent = ClipOval(
      child: Transform.scale(
        scale: scale,
        child: Transform.translate(
          offset: Offset(0, verticalOffset),
          child: Stack(
            children: [
              // Arma
              Positioned.fill(
                child: Image.asset(
                  cosmetics.weapon == WeaponType.gun
                      ? 'assets/images/char_weapon_laser.png'
                      : 'assets/images/char_weapon_wood.png',
                  fit: BoxFit.contain,
                ),
              ),
              // Corpo
              Positioned.fill(
                child: Image.asset(
                  'assets/images/char_body.png',
                  fit: BoxFit.contain,
                ),
              ),
              // Vestito
              Positioned.fill(
                child: Image.asset(
                  'assets/images/char_outfit.png',
                  fit: BoxFit.contain,
                ),
              ),
              // Cappello
              Positioned.fill(
                child: Image.asset(
                  cosmetics.hat == HatType.scifi
                      ? 'assets/images/char_visor.png'
                      : 'assets/images/char_hat.png',
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

  /// Seleziona la cornice corretta in base al tipo equipaggiato
  Widget _buildFrameWrapper(Widget child) {
    switch (cosmetics.frame) {
      case FrameType.basic:
      case FrameType.cavaliere:
        return FrameBasic(size: size, child: child);

      case FrameType.mago:
        return FrameBasic(size: size, child: child);

      case FrameType.scifi:
        return FrameSciFi(size: size, child: child); // Adesso mostra la cornice sci-fi!

      case FrameType.none:
      default:
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