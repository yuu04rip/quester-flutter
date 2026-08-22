// lib/widgets/avatar_view.dart

import 'package:flutter/material.dart';
import '/repository/user_repository.dart';
import 'frame_basic.dart';
import 'frame_scifi.dart';

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
    final avatarContent = _buildAvatarContent();

    return GestureDetector(
      onTap: onClick,
      child: _buildFrame(avatarContent),
    );
  }

  /// Costruisce il contenuto dell'avatar
  Widget _buildAvatarContent() {
    return Transform.scale(
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
    );
  }

  /// Costruisce la cornice in base al tipo
  Widget _buildFrame(Widget child) {
    switch (cosmetics.frame) {
      case FrameType.basic:
        return FrameBasic(child: child, size: size);
      case FrameType.scifi:
        return FrameSciFi(child: child, size: size);
      case FrameType.mago:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF6B4C9A), // Viola
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B4C9A).withValues(alpha: 0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipOval(child: child),
        );
      case FrameType.cavaliere:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFD4AF37), // Oro
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipOval(child: child),
        );
      case FrameType.none:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E1B2E),
          ),
          child: ClipOval(child: child),
        );
    }
  }
}