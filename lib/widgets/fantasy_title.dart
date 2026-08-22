// lib/widgets/fantasy_title.dart

import 'package:flutter/material.dart';
import '/ui/theme/app_theme.dart';

/// Titolo con font dinamico in base al tema
class FantasyTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final FontWeight fontWeight;

  const FantasyTitle({
    super.key,
    required this.text,
    this.style,
    this.color,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    final isArcade = ThemeManager.currentTheme == AppTheme.arcade;
    final letterFont = isArcade ? 'QuesterPixel' : 'QuesterFantasy';
    final numberFont = isArcade ? 'QuesterPixel' : 'sans-serif';

    // Se il testo contiene numeri, usa font misti
    if (_containsNumbers(text)) {
      return Text.rich(
        _buildAnnotatedText(text, letterFont, numberFont),
        style: style?.copyWith(
          fontWeight: fontWeight,
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      );
    }

    return Text(
      text,
      style: (style ?? Theme.of(context).textTheme.titleLarge)?.copyWith(
        fontFamily: _isAllDigits(text) ? numberFont : letterFont,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  bool _containsNumbers(String text) {
    return text.contains(RegExp(r'[0-9]'));
  }

  bool _isAllDigits(String text) {
    return text.isNotEmpty && text.runes.every((r) => r >= 48 && r <= 57);
  }

  TextSpan _buildAnnotatedText(String text, String letterFont, String numberFont) {
    final spans = <TextSpan>[];
    var currentPart = '';
    var currentIsDigit = text[0].contains(RegExp(r'[0-9]'));

    for (final char in text.split('')) {
      final isDigit = char.contains(RegExp(r'[0-9]'));
      if (isDigit == currentIsDigit) {
        currentPart += char;
      } else {
        if (currentPart.isNotEmpty) {
          spans.add(TextSpan(
            text: currentPart,
            style: TextStyle(
              fontFamily: currentIsDigit ? numberFont : letterFont,
              fontWeight: fontWeight,
              color: color,
            ),
          ));
        }
        currentPart = char;
        currentIsDigit = isDigit;
      }
    }

    if (currentPart.isNotEmpty) {
      spans.add(TextSpan(
        text: currentPart,
        style: TextStyle(
          fontFamily: currentIsDigit ? numberFont : letterFont,
          fontWeight: fontWeight,
          color: color,
        ),
      ));
    }

    return TextSpan(children: spans);
  }
}