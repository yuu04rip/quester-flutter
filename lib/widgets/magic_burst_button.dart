// lib/widgets/magic_burst_button.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../ui/theme/colors.dart';
import '../ui/theme/app_theme.dart';

/// Bottone con effetto magico animato e supporto integrato per temi Fantasy, Arcade (Pixel) e Regale (3D)
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
  late Animation<double> _pressTranslateAnimation; // Animazione per l'effetto "pressione fisica" arcade

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

    // Sposta il bottone in basso di 4 pixel quando viene premuto (effetto pulsante meccanico)
    _pressTranslateAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
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
    final currentTheme = ThemeManager.currentTheme;
    final bool isArcade = widget.isArcadeOverride ?? (currentTheme == AppTheme.arcade);
    final bool isRegale = currentTheme == AppTheme.regale;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.width ?? double.infinity,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Effetto particelle (adattato al tema)
              if (_controller.value > 0.0 && _controller.value < 1.0)
                _buildParticles(isArcade, isRegale),

              // Bagliore magico
              if (_glowAnimation.value > 0.0)
                _buildGlow(isArcade, isRegale),

              // Bottone principale con transizione fisica di pressione
              Transform.translate(
                offset: Offset(0, isArcade ? _pressTranslateAnimation.value : 0),
                child: Transform.scale(
                  scale: isArcade ? 1.0 : _scaleAnimation.value,
                  child: SizedBox.expand(
                    child: _buildButton(isArcade, isRegale),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Particelle magiche (Supporta Arcade, Regale o Fantasy)
  Widget _buildParticles(bool isArcade, bool isRegale) {
    final progress = _particleAnimation.value;
    const particleCount = 16;

    return Positioned.fill(
      child: CustomPaint(
        painter: _ParticlePainter(
          progress: progress,
          particleCount: particleCount,
          isArcade: isArcade,
          isRegale: isRegale,
        ),
      ),
    );
  }

  /// Bagliore magico (colore dinamico in base al tema)
  Widget _buildGlow(bool isArcade, bool isRegale) {
    final glowOpacity = (1.0 - _glowAnimation.value) * 0.8;

    final Color primaryGlowColor;
    final Color secondaryGlowColor;

    if (isArcade) {
      primaryGlowColor = ArcadeGreen;
      secondaryGlowColor = const Color(0xFF00FFCC);
    } else if (isRegale) {
      primaryGlowColor = RegalGold;
      secondaryGlowColor = const Color(0xFFFFE7B0);
    } else {
      primaryGlowColor = FantasyGold;
      secondaryGlowColor = Colors.orange;
    }

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(isArcade ? 4 : (isRegale ? 16 : 14)),
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

  /// Bottone principale unificato (Pixel Arcade, Regale 3D o Fantasy)
  Widget _buildButton(bool isArcade, bool isRegale) {
    final Color textColor;
    final double borderRadius;

    if (isArcade) {
      textColor = const Color(0xFF0A0A0F);
      borderRadius = 4.0;
    } else if (isRegale) {
      textColor = const Color(0xFF2C220E); // Marrone scuro regale per contrasto perfetto sull'oro
      borderRadius = 16.0;
    } else {
      textColor = FantasyBackground;
      borderRadius = 14.0;
    }

    final isPressed = isArcade && _pressTranslateAnimation.value > 1.0;

    // Gestione decorazione speciale per il tema Regale (Gradiente Oro + Bordo doppio)
    final BoxDecoration buttonDecoration = isArcade
        ? BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: isPressed ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF008822),
          blurRadius: isPressed ? 2 : 2,
          offset: Offset(0, isPressed ? 1 : 5),
        ),
      ],
    )
        : isRegale
        ? BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFEE88), // Oro chiaro brillante in cima
          RegalGold,         // Oro medio principale
          Color(0xFFD4AF37), // Oro brunito/scuro in basso per effetto 3D metallico
        ],
        stops: [0.0, 0.5, 1.0],
      ),
      border: Border.all(
        color: const Color(0xFFFFF7C2), // Bordo interno lucido
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.amber.withValues(alpha: 0.35),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    )
        : BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: FantasyGold,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Opacity(
      opacity: widget.loading ? 0.6 : 1.0,
      child: DecoratedBox(
        decoration: buttonDecoration,
        child: ElevatedButton(
          onPressed: widget.loading ? null : _handleClick,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Trasparente per fare spazio al gradiente custom
            foregroundColor: textColor,
            shadowColor: Colors.transparent, // Rimuoviamo l'ombra nativa gestita dal DecoratedBox
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: isArcade
                  ? const BorderSide(color: Color(0xFF003311), width: 2)
                  : BorderSide.none,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isArcade ? 16 : 12,
            ),
            textStyle: TextStyle(
              inherit: true,
              fontSize: isArcade ? 18 : (isRegale ? 16 : 16),
              fontWeight: FontWeight.bold,
              fontFamily: isArcade
                  ? 'QuesterPixel'
                  : (isRegale ? 'QuesterFantasy' : 'QuesterFantasy'),
              letterSpacing: isArcade ? 2 : (isRegale ? 1.5 : 1.2),
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
            textAlign: TextAlign.center,
            style: isRegale
                ? TextStyle(
              color: textColor,
              shadows: [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  offset: const Offset(0, 1),
                  blurRadius: 0,
                ),
              ],
            )
                : null,
          ),
        ),
      ),
    );
  }
}

/// Painter per le particelle (Supporta Arcade, Regale o Fantasy)
class _ParticlePainter extends CustomPainter {
  final double progress;
  final int particleCount;
  final bool isArcade;
  final bool isRegale;

  _ParticlePainter({
    required this.progress,
    required this.particleCount,
    required this.isArcade,
    required this.isRegale,
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
      } else if (isRegale) {
        color = i % 2 == 0
            ? RegalGold.withValues(alpha: alpha)
            : const Color(0xFFFFE7B0).withValues(alpha: alpha * 0.8);
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
    return oldDelegate.progress != progress ||
        oldDelegate.isArcade != isArcade ||
        oldDelegate.isRegale != isRegale;
  }
}