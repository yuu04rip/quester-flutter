// lib/widgets/frame_scifi.dart

import 'package:flutter/material.dart';

/// Cornice sci-fi animata (equivalente a ic_frame_scifi.xml)
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
        border: Border.all(
          color: const Color(0xFF00FF66), // Verde neon
          width: 6,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF66).withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cerchio interno
          Center(
            child: Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF88FFB0).withValues(alpha: 0.67),
                  width: 2,
                ),
              ),
            ),
          ),
          // Puntini ai 4 angoli
          Positioned(
            top: size * 0.15,
            left: size * 0.15,
            child: _buildCornerDot(),
          ),
          Positioned(
            top: size * 0.15,
            right: size * 0.15,
            child: _buildCornerDot(),
          ),
          Positioned(
            bottom: size * 0.15,
            left: size * 0.15,
            child: _buildCornerDot(),
          ),
          Positioned(
            bottom: size * 0.15,
            right: size * 0.15,
            child: _buildCornerDot(),
          ),
          // Child al centro
          Center(child: ClipOval(child: child)),
        ],
      ),
    );
  }

  Widget _buildCornerDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF00FF66),
        shape: BoxShape.rectangle,
      ),
    );
  }
}