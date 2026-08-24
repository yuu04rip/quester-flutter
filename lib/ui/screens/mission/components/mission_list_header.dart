// lib/screens/mission/components/mission_list_header.dart

import 'package:flutter/material.dart';

class MissionListHeader extends StatelessWidget {
  final String username;
  final int activeMissionsCount;
  final VoidCallback onAddPressed;

  const MissionListHeader({
    super.key,
    required this.username,
    required this.activeMissionsCount,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '✦ Registro di $username ✦',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$activeMissionsCount missioni attive da compiere',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          FloatingActionButton(
            onPressed: onAddPressed,
            backgroundColor: accentColor,
            foregroundColor: theme.colorScheme.onSecondary,
            elevation: 4,
            mini: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.add_rounded, size: 24),
          ),
        ],
      ),
    );
  }
}