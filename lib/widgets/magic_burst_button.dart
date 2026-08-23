// lib/widgets/magic_burst_button.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../ui/theme/colors.dart';

/// Bottone con effetto magico animato
class MagicBurstButton extends StatefulWidget {
  final String text;
  final bool loading;
  final VoidCallback onClickAfterEffect;
  final double? width;

  const MagicBurstButton({
    super.key,
    required this.text,
    required this.loading,
    required this.onClickAfterEffect,
    this.width,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.width ?? double.infinity,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ✨ Effetto particelle
              if (_controller.value > 0.0 && _controller.value < 1.0)
                _buildParticles(),

              // ✨ Bagliore magico
              if (_glowAnimation.value > 0.0)
                _buildGlow(),

              // ✨ Bottone principale
              Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildButton(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ✨ Particelle magiche
  Widget _buildParticles() {
    final progress = _particleAnimation.value;
    final particleCount = 16;

    return Positioned.fill(
      child: CustomPaint(
        painter: _ParticlePainter(
          progress: progress,
          particleCount: particleCount,
          isArcade: false,
        ),
      ),
    );
  }

  /// ✨ Bagliore magico
  Widget _buildGlow() {
    final glowOpacity = (1.0 - _glowAnimation.value) * 0.8;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: FantasyGold.withValues(alpha: glowOpacity),
              blurRadius: 30 + 40 * _glowAnimation.value,
              spreadRadius: 5 + 10 * _glowAnimation.value,
            ),
            BoxShadow(
              color: Colors.orange.withValues(alpha: glowOpacity * 0.5),
              blurRadius: 20 + 30 * _glowAnimation.value,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// ✨ Bottone principale
  Widget _buildButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
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
          backgroundColor: FantasyGold,
          foregroundColor: FantasyBackground,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: widget.loading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: FantasyBackground,
          ),
        )
            : Text(
          widget.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

/// ✨ Painter per le particelle
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

      final color = i % 2 == 0
          ? FantasyGold.withValues(alpha: alpha)
          : Colors.orange.withValues(alpha: alpha * 0.7);

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
          Paint()..color = FantasyGold.withValues(alpha: trailAlpha),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}