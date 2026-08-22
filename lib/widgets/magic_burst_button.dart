// lib/widgets/magic_burst_button.dart

import 'package:flutter/material.dart';
import '/ui/theme/app_theme.dart';

/// Bottone con effetto magico
class MagicBurstButton extends StatefulWidget {
  final String text;
  final bool loading;
  final Future<void> Function() onClickAfterEffect;
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

class _MagicBurstButtonState extends State<MagicBurstButton> {
  bool _playEffect = false;

  Future<void> _handleClick() async {
    if (widget.loading) return;

    setState(() => _playEffect = true);
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => _playEffect = false);
    await widget.onClickAfterEffect();
  }

  @override
  Widget build(BuildContext context) {
    final isArcade = ThemeManager.currentTheme == AppTheme.arcade;
    final bgColor = isArcade ? const Color(0xFF00FF41) : const Color(0xFFD4A84F);
    final textColor = isArcade ? const Color(0xFF0A0A0F) : const Color(0xFF1B1408);

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: isArcade ? 60 : 54,
      child: ElevatedButton(
        onPressed: widget.loading ? null : _handleClick,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isArcade ? 4 : 8),
          ),
        ),
        child: widget.loading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Text(
          widget.text,
          style: TextStyle(
            fontFamily: isArcade ? 'QuesterPixel' : 'QuesterFantasy',
            fontWeight: FontWeight.bold,
            fontSize: isArcade ? 18 : 16,
            letterSpacing: isArcade ? 2 : 0,
          ),
        ),
      ),
    );
  }
}