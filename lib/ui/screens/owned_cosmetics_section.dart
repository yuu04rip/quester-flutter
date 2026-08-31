// lib/screens/owned_cosmetics_section.dart

import 'package:flutter/material.dart';
import '/data/models/owned_cosmetic.dart';
import '/data/preferences/theme_preferences.dart';
import '../theme/app_theme.dart';

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
  late AppTheme _currentTheme;
  final ThemePreferences _themePreferences = ThemePreferences();

  // Lista di ID dei temi supportati con l'ID standardizzato 'reward_tema_regale'
  static const List<String> _themeIds = [
    'theme_arcade',
    'theme_fantasy',
    'reward_tema_regale',
  ];

  @override
  void initState() {
    super.initState();
    _currentTheme = ThemeManager.currentTheme;
    // Ascolta i cambiamenti globali del tema per aggiornare l'UI in tempo reale
    ThemeManager.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeManager.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        _currentTheme = ThemeManager.currentTheme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filtriamo e teniamo solo i cosmetici che l'utente possiede veramente
    final validCosmetics = widget.ownedCosmetics;

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
            _buildHeader(context, validCosmetics.length),
            const SizedBox(height: 10),
            Divider(color: theme.colorScheme.secondary.withValues(alpha: 0.35)),
            const SizedBox(height: 14),
            if (validCosmetics.isEmpty)
              _buildEmptyState(context)
            else
              _buildCosmeticsGrid(context, validCosmetics),
          ],
        ),
      ),
    );
  }

  /// Header con titolo e refresh
  Widget _buildHeader(BuildContext context, int count) {
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
              '$count oggetti posseduti',
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

  /// Griglia cosmetici filtrati
  Widget _buildCosmeticsGrid(BuildContext context, List<OwnedCosmetic> cosmetics) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: cosmetics.length,
      itemBuilder: (context, index) {
        final cosmetic = cosmetics[index];
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
      key: ValueKey('owned_item_$itemId'),
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
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: InkWell(
        onTap: () {
          if (isTheme) {
            final AppTheme targetTheme;
            if (_isThemeActive(itemId)) {
              targetTheme = AppTheme.basic;
            } else {
              targetTheme = _getTargetTheme(itemId);
            }

            ThemeManager.setTheme(targetTheme);
            _themePreferences.saveTheme(targetTheme);
            widget.onThemeApplied(targetTheme);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 36,
                child: Center(
                  child: _buildCosmeticIcon(context, itemId, isSelected),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 9,
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface,
                ),
              ),
              if (isSelected && isTheme) ...[
                const SizedBox(height: 1),
                Text(
                  'ATTIVO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Icona dinamica che mappa gli asset esattamente come definiti nel main.dart
  Widget _buildCosmeticIcon(BuildContext context, String itemId, bool isSelected) {
    final theme = Theme.of(context);

    // Mappatura basata sugli iconName definiti nel main.dart
    final String? assetName = switch (itemId) {
      'hat_mago' => 'ic_char_wizard',
      'staff_mago' => 'ic_char_weapon_staff',
      'gun_spaziale' => 'ic_gun_spaziale',
      'sword_cavaliere' => 'ic_char_weapon_blade',
      'hat_cavaliere' => 'ic_char_helm',
      'visor_futuristico' => 'ic_visor_futuristico',
      'theme_arcade' => 'ic_theme_arcade',
      'theme_fantasy' => 'ic_dragon',
      'reward_corona' => 'ic_crown',
      'reward_tema_regale' => 'ic_throne',
      _ => null,
    };

    // Se troviamo un asset associato, proviamo a caricarlo con Image.asset
    if (assetName != null) {
      return Image.asset(
        'assets/images/$assetName.png',
        width: 36,
        height: 36,
        fit: BoxFit.contain,
        color: isSelected ? Colors.grey : null,
        colorBlendMode: isSelected ? BlendMode.saturation : null,
        errorBuilder: (context, error, stackTrace) => _fallbackIcon(itemId, isSelected, theme),
      );
    }

    // Per le cornici o altri elementi non basati su asset image standard
    return switch (itemId) {
      'frame_mago' => _buildFrameIcon(const Color(0xFF6B4C9A)),
      'frame_cavaliere' => _buildFrameIcon(const Color(0xFFD4AF37)),
      'frame_scifi' => _buildFrameIcon(const Color(0xFF00FF66)),
      'frame_basic' => _buildFrameIcon(const Color(0xFFD4AF37)),
      _ => _fallbackIcon(itemId, isSelected, theme),
    };
  }

  /// Fallback grafico nel caso in cui l'asset immagine non venga trovato
  Widget _fallbackIcon(String itemId, bool isSelected, ThemeData theme) {
    final color = isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurface;

    IconData iconData = Icons.auto_awesome;
    if (itemId.contains('hat')) iconData = Icons.shield;
    if (itemId.contains('staff') || itemId.contains('sword') || itemId.contains('gun')) iconData = Icons.flash_on;
    if (itemId.contains('theme')) iconData = Icons.palette;
    if (itemId.contains('corona')) iconData = Icons.workspace_premium;

    return Icon(
      iconData,
      size: 32,
      color: color,
    );
  }

  /// Icona cornice disegnata geometricamente
  Widget _buildFrameIcon(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
      ),
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
        ),
      ),
    );
  }

  bool _isThemeActive(String itemId) {
    switch (itemId) {
      case 'theme_arcade':
        return _currentTheme == AppTheme.arcade;
      case 'theme_fantasy':
        return _currentTheme == AppTheme.fantasy;
      case 'reward_tema_regale':
        return _currentTheme == AppTheme.regale;
      default:
        return false;
    }
  }

  AppTheme _getTargetTheme(String itemId) {
    switch (itemId) {
      case 'theme_arcade':
        return AppTheme.arcade;
      case 'theme_fantasy':
        return AppTheme.fantasy;
      case 'reward_tema_regale':
        return AppTheme.regale;
      default:
        return AppTheme.basic;
    }
  }

  String _getThemeDisplayName(String itemId) {
    switch (itemId) {
      case 'theme_arcade':
        return 'Tema Arcade';
      case 'theme_fantasy':
        return 'Tema Fantasy';
      case 'reward_tema_regale':
        return 'Tema Regale';
      default:
        return 'Tema Base';
    }
  }

  String _formatCosmeticName(String itemId) {
    return itemId
        .split('_')
        .map((word) => word.isEmpty
        ? word
        : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}