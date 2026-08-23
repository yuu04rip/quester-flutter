// lib/screens/profile_components.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Barra di progresso XP
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Liv. $livello', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('$xpInCurrentLevel / $xpNeededForLevel XP',
                style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('Liv. ${livello + 1}', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: xpProgress,
            minHeight: 12,
            backgroundColor: FantasyPurpleDark.withValues(alpha: 0.5),
            valueColor: AlwaysStoppedAnimation<Color>(FantasyGold),
          ),
        ),
      ],
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
        // ✅ Usa coin.png
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