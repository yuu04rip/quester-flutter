// lib/screens/mission/components/filter_chips.dart

import 'package:flutter/material.dart';
import 'filter_status.dart';

/// Filtri per le missioni
class FilterChips extends StatelessWidget {
  final FilterStatus selectedFilter;
  final Function(FilterStatus) onFilterSelected;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: FilterStatus.values.map((status) {
          final isSelected = selectedFilter == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status.label),
              selected: isSelected,
              onSelected: (_) => onFilterSelected(status),
            ),
          );
        }).toList(),
      ),
    );
  }
}