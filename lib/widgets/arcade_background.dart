// lib/widgets/arcade_background.dart

import 'package:flutter/material.dart';
import '/ui/theme/app_theme.dart';
import '/ui/theme/colors.dart';

/// Sfondo arcade/fantasy
class ArcadeBackground extends StatelessWidget {
  final Widget child;

  const ArcadeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isArcade = ThemeManager.currentTheme == AppTheme.arcade;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isArcade
              ? [
            const Color(0xFF0A0A0F),
            const Color(0xFF12121A),
            const Color(0xFF1A1A2E),
          ]
              : [
            const Color(0xFF0D0B14),
            const Color(0xFF171321),
            const Color(0xFF0B0813),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (isArcade)
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_arcade_pixel.png',
                fit: BoxFit.cover,
              ),
            ),
          child,
        ],
      ),
    );
  }
}