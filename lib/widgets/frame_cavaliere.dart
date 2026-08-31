// lib/widgets/frame_cavaliere.dart

import 'package:flutter/material.dart';

import '../ui/theme/colors.dart';

/// Cornice personalizzata per il Cavaliere (stile metallico/dorato con bordi robusti)
class FrameCavaliere extends StatelessWidget {
  final double size;
  final Widget child;

  const FrameCavaliere({
    super.key,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FantasyGold,
            const Color(0xFF8C7335), // Bronzo / Scuro
            FantasyGold,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: FantasyGold.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF4A3B1C),
            width: 2,
          ),
          color: const Color(0xFF1E1B2E),
        ),
        child: ClipOval(
          child: child,
        ),
      ),
    );
  }
}