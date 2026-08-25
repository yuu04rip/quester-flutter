// lib/ui/theme/widgets/royal_background.dart

import 'package:flutter/material.dart';
import '/ui/theme/app_theme.dart';

class RoyalBackground extends StatelessWidget {
  final Widget child;

  const RoyalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isRegal = ThemeManager.currentTheme == AppTheme.regale;

    if (!isRegal) {
      return child;
    }

    return Stack(
      children: [
        // Sfondo pixelato regale
        Positioned.fill(
          child: Image.asset(
            'assets/images/bg_royal_pixel.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF0D0904),
            ),
          ),
        ),
        // Leggera patina scura per far risaltare i contenuti in primo piano
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
          ),
        ),
        // Trasparenza sullo scaffold per lasciare spazio allo sfondo
        Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: Colors.transparent,
          ),
          child: child,
        ),
      ],
    );
  }
}