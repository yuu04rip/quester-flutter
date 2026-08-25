// lib/screens/profile_components.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '/ui/theme/app_theme.dart';

/// Barra di progresso XP (Dinamica: classica per Fantasy, segmentata a blocchi per Arcade)
class FantasyXpProgress extends StatelessWidget {
  final int xpTotale;
  final int livello;
  final double xpProgress;
  final int xpInCurrentLevel;
  final int xpNeededForLevel;

  const FantasyXpProgress({
    super.key,
    required this.xpTotale,
    required this.livello,
    required this.xpProgress,
    required this.xpInCurrentLevel,
    required this.xpNeededForLevel,
  });

  @override
  Widget build(BuildContext context) {
    final isArcade = ThemeManager.currentTheme == AppTheme.arcade;
    final isMaxLevel = livello >= 50;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isArcade ? 'Stage $livello' : 'Liv. $livello',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              isMaxLevel ? 'MAX XP' : '$xpInCurrentLevel / $xpNeededForLevel XP',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              isMaxLevel
                  ? (isArcade ? 'STAGE MAX' : 'MAX')
                  : (isArcade ? 'Stage ${livello + 1}' : 'Liv. ${livello + 1}'),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Se è Arcade disegniamo i blocchetti separati, altrimenti la barra lineare classica
        isArcade
            ? _buildArcadeSegmentedBar(context)
            : ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: isMaxLevel ? 1.0 : xpProgress,
            minHeight: 12,
            backgroundColor: FantasyPurpleDark.withValues(alpha: 0.5),
            valueColor: AlwaysStoppedAnimation<Color>(FantasyGold),
          ),
        ),
      ],
    );
  }

  /// Costruisce una barra a trattini in stile pixel/arcade
  Widget _buildArcadeSegmentedBar(BuildContext context) {
    const totalSegments = 10; // Numero di blocchetti totali della barra
    final isMaxLevel = livello >= 50;
    final activeSegments = isMaxLevel ? totalSegments : (xpProgress * totalSegments).round();

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.5), width: 1.5),
        borderRadius: BorderRadius.circular(4),
        color: theme.colorScheme.surface,
      ),
      child: Row(
        children: List.generate(totalSegments, (index) {
          final isActive = index < activeSegments;
          return Expanded(
            child: Container(
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                // I blocchi attivi usano il colore Primario Neon, quelli vuoti sono scuri
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Statistica con icona
class FantasyStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const FantasyStatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

/// Statistica monete
class FantasyCoinStatItem extends StatelessWidget {
  final String value;

  const FantasyCoinStatItem({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/coin.png',
          width: 28,
          height: 28,
        ),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FantasyGold)),
        Text('MONETE', style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}