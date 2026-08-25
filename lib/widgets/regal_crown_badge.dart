// lib/widgets/regal_crown_badge.dart

import 'package:flutter/material.dart';
import '/ui/theme/colors.dart';

class RegalCrownBadge extends StatelessWidget {
  final double size;

  const RegalCrownBadge({
    super.key,
    this.size = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Nessun colore di sfondo o bordo circolare pieno: solo l'aura luminosa e l'ombra
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
          'assets/images/regal_crown.png', // La tua corona PNG ad altissima risoluzione
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