// lib/widgets/regal_crown_badge.dart

import 'package:flutter/material.dart';
import '/ui/theme/colors.dart';

class RegalCrownBadge extends StatelessWidget {
  final double size;
  final bool isUnlocked; // 🛡️ Parametro per decidere se mostrarla o meno

  const RegalCrownBadge({
    super.key,
    this.size = 46.0,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    // Se non è sbloccata (livello < 50), non mostra nulla
    if (!isUnlocked) {
      return const SizedBox.shrink();
    }

    // Se è sbloccata, mostra la corona con l'aura luminosa
    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: RegalGold.withValues(alpha: 0.6),
            blurRadius: 18,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/images/regal_crown.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          cacheWidth: 400,
          cacheHeight: 400,
        ),
      ),
    );
  }
}