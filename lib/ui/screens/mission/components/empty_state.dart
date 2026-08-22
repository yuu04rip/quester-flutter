// lib/screens/mission/components/empty_state.dart

import 'package:flutter/material.dart';

/// Stato vuoto per la lista missioni
class EmptyState extends StatelessWidget {
  final String searchQuery;

  const EmptyState({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        searchQuery.isNotEmpty
            ? 'Nessuna missione trovata.'
            : 'Nessuna missione presente.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}