// lib/widgets/frame_mago.dart

import 'package:flutter/material.dart';

/// Cornice personalizzata per il Mago (con rune magiche e bagliore viola)
class FrameMago extends StatelessWidget {
  final double size;
  final Widget child;

  const FrameMago({
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
        gradient: const SweepGradient(
          colors: [
            Color(0xFF6B4C9A), // Viola Mago
            Color(0xFF9C27B0), // Viola brillante
            Color(0xFFFFD700), // Oro magico
            Color(0xFF6B4C9A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4C9A).withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF1E1B2E),
        ),
        child: ClipOval(
          child: child,
        ),
      ),
    );
  }
}