// lib/widgets/frame_basic.dart

import 'package:flutter/material.dart';

/// Cornice base dorata (equivalente a frame_basic.xml)
class FrameBasic extends StatelessWidget {
  final Widget child;
  final double size;

  const FrameBasic({
    super.key,
    required this.child,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD4AF37), // Oro
          width: 26,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF4A3510), // Bordo scuro
            width: 4,
          ),
        ),
        child: ClipOval(child: child),
      ),
    );
  }
}