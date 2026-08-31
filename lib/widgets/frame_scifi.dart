// lib/widgets/frame_scifi.dart

import 'package:flutter/material.dart';

/// Cornice sci-fi futuristica e avanzata (Stile HUD / Cyberpunk) disegnata interamente via codice
class FrameSciFi extends StatelessWidget {
  final Widget child;
  final double size;

  const FrameSciFi({
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
        // Gradiente futuristico sul bordo esterno (dal ciano al verde neon)
        gradient: const SweepGradient(
          colors: [
            Color(0xFF00FFCC),
            Color(0xFF00FF66),
            Color(0xFF0099FF),
            Color(0xFF00FFCC),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00FFCC),
          width: 4,
        ),
        boxShadow: [
          // Bagliore esterno potente al neon
          BoxShadow(
            color: const Color(0xFF00FF66).withValues(alpha: 0.6),
            blurRadius: 24,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: const Color(0xFF0099FF).withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sfondo interno leggermente scuro con effetto display HUD
          Center(
            child: Container(
              width: size * 0.88,
              height: size * 0.88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF030E1A).withValues(alpha: 0.85),
                border: Border.all(
                  color: const Color(0xFF00FFCC).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Anello interno tratteggiato o sottile stile radar
          Center(
            child: Container(
              width: size * 0.78,
              height: size * 0.78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF88FFB0).withValues(alpha: 0.3),
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),

          // Dettagli HUD futuristici agli angoli (Tacche di mira)
          Positioned(top: size * 0.12, left: size * 0.5 - 1, child: _buildHudMarker(width: 2, height: 8)),
          Positioned(bottom: size * 0.12, left: size * 0.5 - 1, child: _buildHudMarker(width: 2, height: 8)),
          Positioned(left: size * 0.12, top: size * 0.5 - 1, child: _buildHudMarker(width: 8, height: 2)),
          Positioned(right: size * 0.12, top: size * 0.5 - 1, child: _buildHudMarker(width: 8, height: 2)),

          // Angoli geometrici tecnologici
          Positioned(top: size * 0.16, left: size * 0.16, child: _buildCornerBracket()),
          Positioned(top: size * 0.16, right: size * 0.16, child: _buildCornerBracket(isRight: true)),
          Positioned(bottom: size * 0.16, left: size * 0.16, child: _buildCornerBracket(isBottom: true)),
          Positioned(bottom: size * 0.16, right: size * 0.16, child: _buildCornerBracket(isRight: true, isBottom: true)),

          // Avatar al centro perfettamente mascherato
          Center(
            child: SizedBox(
              width: size * 0.82,
              height: size * 0.82,
              child: ClipOval(child: child),
            ),
          ),
        ],
      ),
    );
  }

  /// Piccole tacche di orientamento stile mirino HUD
  Widget _buildHudMarker({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF00FFCC),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00FFCC), blurRadius: 4),
        ],
      ),
    );
  }

  /// Parentesi geometriche angolari (stile visore sci-fi)
  Widget _buildCornerBracket({bool isRight = false, bool isBottom = false}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        border: Border(
          top: isBottom ? BorderSide.none : const BorderSide(color: Color(0xFF00FF66), width: 2),
          bottom: !isBottom ? BorderSide.none : const BorderSide(color: Color(0xFF00FF66), width: 2),
          left: isRight ? BorderSide.none : const BorderSide(color: Color(0xFF00FF66), width: 2),
          right: !isRight ? BorderSide.none : const BorderSide(color: Color(0xFF00FF66), width: 2),
        ),
      ),
    );
  }
}