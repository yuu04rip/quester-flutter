// lib/widgets/pixel_button.dart

import 'package:flutter/material.dart';

/// Bottone stile pixel
class PixelButton extends StatelessWidget {
  final String text;
  final VoidCallback onClick;
  final bool enabled;
  final bool isArcade;

  const PixelButton({
    super.key,
    required this.text,
    required this.onClick,
    this.enabled = true,
    this.isArcade = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isArcade ? const Color(0xFF00FF41) : const Color(0xFFD4A84F);
    final textColor = isArcade ? const Color(0xFF0A0A0F) : const Color(0xFF0D0B14);

    return GestureDetector(
      onTap: enabled ? onClick : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isArcade ? 28 : 24,
          vertical: isArcade ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: bgColor, width: 3),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: textColor,
            fontSize: isArcade ? 20 : 18,
            fontWeight: FontWeight.bold,
            fontFamily: isArcade ? 'QuesterPixel' : 'QuesterFantasy',
            letterSpacing: isArcade ? 2 : 0,
          ),
        ),
      ),
    );
  }
}