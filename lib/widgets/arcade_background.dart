// lib/ui/theme/widgets/arcade_background.dart

import 'package:flutter/material.dart';
import '/ui/theme/app_theme.dart';

class ArcadeBackground extends StatelessWidget {
  final Widget child;

  const ArcadeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isArcade = ThemeManager.currentTheme == AppTheme.arcade;

    if (!isArcade) {
      return child;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/bg_arcade_pixel.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF100323),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
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