// lib/widgets/magic_burst_button.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../ui/theme/colors.dart';
import '../ui/theme/app_theme.dart';

/// Bottone con effetto magico animato e supporto integrato per tema Fantasy / Arcade (Pixel)
class MagicBurstButton extends StatefulWidget {
  final String text;
  final bool loading;
  final VoidCallback onClickAfterEffect;
  final double? width;
  final bool? isArcadeOverride; // Opzionale per forzare lo stile arcade

  const MagicBurstButton({
    super.key,
    required this.text,
    required this.loading,
    required this.onClickAfterEffect,
    this.width,
    this.isArcadeOverride,
  });

  @override
  State<MagicBurstButton> createState() => _MagicBurstButtonState();
}

class _MagicBurstButtonState extends State<MagicBurstButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleClick() async {
    if (widget.loading) return;

    // Riproduci l'animazione
    await _controller.forward(from: 0);

    // Esegui l'azione
    widget.onClickAfterEffect();

    // Resetta l'animazione
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    // Rileva dinamicamente se siamo in modalità arcade o fantasy
    final bool isArcade = widget.isArcadeOverride ?? (ThemeManager.currentTheme == AppTheme.arcade);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.width ?? double.infinity,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ✨ Effetto particelle (adattato al tema)
              if (_controller.value > 0.0 && _controller.value < 1.0)
                _buildParticles(isArcade),

              // ✨ Bagliore magico
              if (_glowAnimation.value > 0.0)
                _buildGlow(isArcade),

              // ✨ Bottone principale
              Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildButton(isArcade),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ✨ Particelle magiche o pixelate
  Widget _buildParticles(bool isArcade) {
    final progress = _particleAnimation.value;
    const particleCount = 16;

    return Positioned.fill(
      child: CustomPaint(
        painter: _ParticlePainter(
          progress: progress,
          particleCount: particleCount,
          isArcade: isArcade,
        ),
      ),
    );
  }

  /// ✨ Bagliore magico (colore dinamico in base al tema)
  Widget _buildGlow(bool isArcade) {
    final glowOpacity = (1.0 - _glowAnimation.value) * 0.8;
    final primaryGlowColor = isArcade ? ArcadeGreen : FantasyGold;
    final secondaryGlowColor = isArcade ? const Color(0xFF00FFCC) : Colors.orange;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(isArcade ? 4 : 14),
          boxShadow: [
            BoxShadow(
              color: primaryGlowColor.withValues(alpha: glowOpacity),
              blurRadius: 30 + 40 * _glowAnimation.value,
              spreadRadius: 5 + 10 * _glowAnimation.value,
            ),
            BoxShadow(
              color: secondaryGlowColor.withValues(alpha: glowOpacity * 0.5),
              blurRadius: 20 + 30 * _glowAnimation.value,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// ✨ Bottone principale unificato (Stile Pixel / Fantasy + Effetto Burst)
  Widget _buildButton(bool isArcade) {
    final bgColor = isArcade ? const Color(0xFF00FF41) : FantasyGold;
    final textColor = isArcade ? const Color(0xFF0A0A0F) : FantasyBackground;
    final borderRadius = isArcade ? 4.0 : 14.0;

    return Opacity(
      opacity: widget.loading ? 0.6 : 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.loading ? null : _handleClick,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: textColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(
                color: isArcade ? bgColor : Colors.white.withValues(alpha: 0.5),
                width: isArcade ? 3 : 1.5,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isArcade ? 28 : 24,
              vertical: isArcade ? 16 : 12,
            ),
          ),
          child: widget.loading
              ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: textColor,
            ),
          )
              : Text(
            widget.text.toUpperCase(),
            style: TextStyle(
              fontSize: isArcade ? 18 : 16,
              fontWeight: FontWeight.bold,
              fontFamily: isArcade ? 'QuesterPixel' : 'QuesterFantasy',
              letterSpacing: isArcade ? 2 : 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// ✨ Painter per le particelle (Supporta colori Arcade o Fantasy)
class _ParticlePainter extends CustomPainter {
  final double progress;
  final int particleCount;
  final bool isArcade;

  _ParticlePainter({
    required this.progress,
    required this.particleCount,
    required this.isArcade,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final random = math.Random(42);

    for (int i = 0; i < particleCount; i++) {
      final angle = (2 * math.pi * i / particleCount) + random.nextDouble() * 0.5;
      final distance = 20 + 80 * progress;
      final px = centerX + math.cos(angle) * distance;
      final py = centerY + math.sin(angle) * distance;

      final alpha = (1.0 - progress).clamp(0.0, 1.0);
      final particleSize = 3 + random.nextDouble() * 4;

      final Color color;
      if (isArcade) {
        color = i % 2 == 0
            ? const Color(0xFF00FF41).withValues(alpha: alpha)
            : const Color(0xFF00FFCC).withValues(alpha: alpha * 0.8);
      } else {
        color = i % 2 == 0
            ? FantasyGold.withValues(alpha: alpha)
            : Colors.orange.withValues(alpha: alpha * 0.7);
      }

      canvas.drawCircle(
        Offset(px, py),
        particleSize,
        Paint()..color = color,
      );

      // Piccola scia
      if (progress > 0.3) {
        final trailAlpha = alpha * 0.3;
        canvas.drawCircle(
            Offset(px - 5, py - 5),
            particleSize * 0.6,
            Paint()..color = color.withValues(alpha: trailAlpha),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isArcade != isArcade;
  }
}