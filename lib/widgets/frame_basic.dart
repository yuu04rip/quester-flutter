// lib/widgets/frame_basic.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Cornice artistica in stile Fantasy/Medievale con borchie e intarsi
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
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Ombra e bagliore magico esterno
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),

          // 2. Bordo principale metallico lavorato (Gradiente Oro/Bronzo)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFF5C4033), // Bruno scuro
                  Color(0xFFD4AF37), // Oro
                  Color(0xFFFFD700), // Oro brillante
                  Color(0xFF8B6508), // Oro antico
                  Color(0xFF3A2810), // Ombra profonda
                  Color(0xFFD4AF37),
                  Color(0xFF5C4033),
                ],
              ),
            ),
          ),

          // 3. Anello dentellato / inciso interno (stile antico)
          Container(
            margin: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2A1B0A),
                width: 4,
              ),
            ),
          ),

          // 4. Sfondo interno scuro (pergamena o metallo brunito)
          Container(
            margin: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF140D07),
              border: Border.all(
                color: const Color(0xFFC5A059),
                width: 2,
              ),
            ),
          ),

          // 5. Borchie/Gemme decorative disposte in cerchio (Stile Fantasy)
          ..._buildDecorativeStuds(size),

          // 6. Contenitore finale per il widget (es. l'avatar)
          Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF000000),
                width: 2,
              ),
            ),
            child: ClipOval(child: child),
          ),
        ],
      ),
    );
  }

  /// Genera dinamicamente le borchie decorative lungo il cerchio
  List<Widget> _buildDecorativeStuds(double parentSize) {
    const int totalStuds = 8; // Numero di borchie lungo il bordo
    final List<Widget> studs = [];
    final double radius = (parentSize / 2) - 14; // Posizionate sul bordo intermedio

    for (int i = 0; i < totalStuds; i++) {
      final double angle = (i * 2 * math.pi) / totalStuds;

      // Calcolo coordinate polari per centrare le borchie
      final double x = math.cos(angle) * radius;
      final double y = math.sin(angle) * radius;

      studs.add(
        Transform.translate(
          offset: Offset(x, y),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFD700), Color(0xFF8B6508)],
                center: Alignment(-0.3, -0.3),
              ),
              border: Border.all(
                color: const Color(0xFF3A2810),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return studs;
  }
}