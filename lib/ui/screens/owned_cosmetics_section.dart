// lib/screens/owned_cosmetics_section.dart

import 'package:flutter/material.dart';
import '/data/models/owned_cosmetic.dart';
import '/data/preferences/theme_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

/// Sezione cosmetici posseduti
class OwnedCosmeticsSection extends StatefulWidget {
  final List<OwnedCosmetic> ownedCosmetics;
  final VoidCallback onRefresh;
  final Function(AppTheme) onThemeApplied;

  const OwnedCosmeticsSection({
    super.key,
    required this.ownedCosmetics,
    this.onRefresh = _defaultRefresh,
    this.onThemeApplied = _defaultThemeApplied,
  });

  static void _defaultRefresh() {}
  static void _defaultThemeApplied(AppTheme theme) {}

  @override
  State<OwnedCosmeticsSection> createState() => _OwnedCosmeticsSectionState();
}

class _OwnedCosmeticsSectionState extends State<OwnedCosmeticsSection> {
  AppTheme _currentTheme = AppTheme.fantasy;

  static const List<String> _themeIds = [
    'theme_arcade',
    'theme_fantasy',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 14,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.65),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            Divider(color: theme.colorScheme.secondary.withValues(alpha: 0.35)),
            const SizedBox(height: 14),
            if (widget.ownedCosmetics.isEmpty)
              _buildEmptyState(context)
            else
              _buildCosmeticsGrid(context),
          ],
        ),
      ),
    );
  }

  /// Header con titolo e refresh
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'I Tuoi Cosmetici',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${widget.ownedCosmetics.length} oggetti posseduti',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: widget.onRefresh,
          icon: Icon(
            Icons.refresh,
            color: theme.colorScheme.secondary,
            size: 22,
          ),
        ),
      ],
    );
  }

  /// Stato vuoto
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            color: theme.colorScheme.secondary.withValues(alpha: 0.45),
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            'Nessun cosmetico acquistato',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Griglia cosmetici
  Widget _buildCosmeticsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: widget.ownedCosmetics.length,
      itemBuilder: (context, index) {
        final cosmetic = widget.ownedCosmetics[index];
        final isTheme = _themeIds.contains(cosmetic.itemId);
        final isSelected = isTheme && _isThemeActive(cosmetic.itemId);

        return _buildCosmeticItem(
          context,
          cosmetic.itemId,
          isTheme: isTheme,
          isSelected: isSelected,
        );
      },
    );
  }

  /// Singolo cosmetico
  Widget _buildCosmeticItem(
      BuildContext context,
      String itemId, {
        required bool isTheme,
        required bool isSelected,
      }) {
    final theme = Theme.of(context);
    final displayName = isTheme ? _getThemeDisplayName(itemId) : _formatCosmeticName(itemId);

    return Card(
      elevation: isSelected ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.secondary
              : theme.colorScheme.primary.withValues(alpha: 0.4),
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? theme.colorScheme.secondary.withValues(alpha: 0.15)
          : theme.colorScheme.surfaceVariant.withValues(alpha: 0.6),
      child: InkWell(
        onTap: () {
          if (isTheme) {
            final nextTheme = _getToggledTheme(itemId);
            setState(() => _currentTheme = nextTheme);
            widget.onThemeApplied(nextTheme);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 32,
              color: isSelected
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 6),
            Text(
              displayName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (isSelected && isTheme) ...[
              const SizedBox(height: 2),
              Text(
                'ATTIVO',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Verifica se il tema è attivo
  bool _isThemeActive(String itemId) {
    switch (itemId) {
      case 'theme_arcade':
        return _currentTheme == AppTheme.arcade;
      case 'theme_fantasy':
        return _currentTheme == AppTheme.fantasy;
      default:
        return false;
    }
  }

  /// Ottiene il tema toggle
  AppTheme _getToggledTheme(String itemId) {
    if (itemId == 'theme_arcade' || itemId == 'theme_fantasy') {
      return _currentTheme == AppTheme.arcade ? AppTheme.fantasy : AppTheme.arcade;
    }
    return AppTheme.fantasy;
  }

  /// Nome visualizzato del tema
  String _getThemeDisplayName(String itemId) {
    switch (itemId) {
      case 'theme_arcade':
        return 'Tema Arcade';
      case 'theme_fantasy':
        return 'Tema Fantasy';
      default:
        return _formatCosmeticName(itemId);
    }
  }

  /// Formatta il nome del cosmetico
  String _formatCosmeticName(String itemId) {
    return itemId
        .split('_')
        .map((word) => word.isEmpty
        ? word
        : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}