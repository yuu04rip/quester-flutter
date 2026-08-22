// lib/screens/mission/search_bar.dart

import 'package:flutter/material.dart';

/// Barra di ricerca missioni
class SearchBar extends StatelessWidget {
  final String query;
  final Function(String) onQueryChange;

  const SearchBar({
    super.key,
    required this.query,
    required this.onQueryChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        onChanged: onQueryChange,
        decoration: InputDecoration(
          hintText: 'Cerca missione...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => onQueryChange(''),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          isDense: true,
        ),
      ),
    );
  }
}