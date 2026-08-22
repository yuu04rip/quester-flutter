// lib/screens/avatar_customization_screen.dart

import 'package:flutter/material.dart';
import '/repository/user_repository.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '/utils/cosmetic_id_mapper.dart';

/// Schermata personalizzazione avatar
class AvatarCustomizationScreen extends StatefulWidget {
  final AvatarCosmetics initialCosmetics;
  final Set<String> ownedItemIds;
  final VoidCallback onBack;
  final Function(AvatarCosmetics) onSave;

  const AvatarCustomizationScreen({
    super.key,
    required this.initialCosmetics,
    required this.ownedItemIds,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<AvatarCustomizationScreen> createState() =>
      _AvatarCustomizationScreenState();
}

class _AvatarCustomizationScreenState extends State<AvatarCustomizationScreen> {
  late HatType _selectedHat;
  late WeaponType _selectedWeapon;
  late FrameType _selectedFrame;

  @override
  void initState() {
    super.initState();
    _selectedHat = widget.initialCosmetics.hat;
    _selectedWeapon = widget.initialCosmetics.weapon;
    _selectedFrame = widget.initialCosmetics.frame == FrameType.none
        ? FrameType.basic
        : widget.initialCosmetics.frame;
  }

  /// Verifica se ci sono modifiche
  bool get _hasChanges {
    return _selectedHat != widget.initialCosmetics.hat ||
        _selectedWeapon != widget.initialCosmetics.weapon ||
        _selectedFrame != widget.initialCosmetics.frame;
  }

  /// Reset allo stato iniziale
  void _reset() {
    setState(() {
      _selectedHat = widget.initialCosmetics.hat;
      _selectedWeapon = widget.initialCosmetics.weapon;
      _selectedFrame = widget.initialCosmetics.frame == FrameType.none
          ? FrameType.basic
          : widget.initialCosmetics.frame;
    });
  }

  /// Salva le modifiche
  void _save() {
    final cosmetics = AvatarCosmetics(
      hat: _selectedHat,
      weapon: _selectedWeapon,
      frame: _selectedFrame,
    );
    widget.onSave(cosmetics);
  }

  @override
  Widget build(BuildContext context) {
    final isArcade = ThemeManager.currentTheme == AppTheme.arcade;
    final accentColor = isArcade ? ArcadeGreen : FantasyGold;

    return Scaffold(
      backgroundColor:
      isArcade ? const Color(0xFF08080D) : const Color(0xFF100A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isArcade, accentColor),
              const SizedBox(height: 14),
              _buildAvatarPreview(context, isArcade, accentColor),
              const SizedBox(height: 16),
              _buildSelectionSummary(context, isArcade),
              const SizedBox(height: 16),
              _buildHatSection(context, isArcade),
              const SizedBox(height: 10),
              _buildWeaponSection(context, isArcade),
              const SizedBox(height: 10),
              _buildFrameSection(context, isArcade),
              const SizedBox(height: 20),
              _buildActionButtons(context, isArcade, accentColor),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Header con pulsante indietro
  Widget _buildHeader(BuildContext context, bool isArcade, Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: widget.onBack,
          icon: Icon(Icons.close, color: accentColor, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: accentColor.withValues(alpha: 0.08),
            side: BorderSide(color: accentColor.withValues(alpha: 0.35)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Column(
          children: [
            Text(
              'PERSONALIZZA',
              style: TextStyle(
                color: accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Avatar',
              style: TextStyle(
                color: isArcade ? const Color(0xFF66FF66) : FantasyTextSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(width: 42),
      ],
    );
  }

  /// Anteprima avatar
  Widget _buildAvatarPreview(BuildContext context, bool isArcade, Color accentColor) {
    return Center(
      child: Container(
        width: 210,
        height: 210,
        decoration: BoxDecoration(
          color: (isArcade ? const Color(0xFF111119) : FantasySurface)
              .withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.55),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.person,
            size: 120,
            color: accentColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  /// Riepilogo selezioni
  Widget _buildSelectionSummary(BuildContext context, bool isArcade) {
    return Card(
      color: (isArcade ? const Color(0xFF15151F) : FantasySurface)
          .withValues(alpha: 0.82),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: (isArcade ? ArcadeGreen : FantasyGold).withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSelectionBadge('Copricapo', _selectedHat.name, isArcade),
            _buildDivider(isArcade),
            _buildSelectionBadge('Arma', _selectedWeapon.name, isArcade),
            _buildDivider(isArcade),
            _buildSelectionBadge('Cornice', _selectedFrame.name, isArcade),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionBadge(String label, String value, bool isArcade) {
    final accentColor = isArcade ? const Color(0xFF66FF66) : FantasyGoldLight;

    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              color: isArcade ? const Color(0xFF66FF66) : FantasyTextSecondary,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isArcade) {
    return Container(
      width: 1,
      height: 28,
      color: (isArcade ? ArcadeGreen : FantasyGold).withValues(alpha: 0.15),
    );
  }

  /// Sezione Copricapo
  Widget _buildHatSection(BuildContext context, bool isArcade) {
    return _buildCustomizationSection(
      title: 'COPRICAPO',
      options: HatType.values.where((h) => h != HatType.none).toList(),
      isSelected: (hat) => _selectedHat == hat,
      isOwned: (hat) => _isOwned(hat),
      onSelect: (hat) {
        setState(() {
          _selectedHat = _selectedHat == hat ? HatType.none : hat;
        });
      },
      isArcade: isArcade,
    );
  }

  /// Sezione Arma
  Widget _buildWeaponSection(BuildContext context, bool isArcade) {
    return _buildCustomizationSection(
      title: 'ARMA',
      options: WeaponType.values.where((w) => w != WeaponType.none).toList(),
      isSelected: (weapon) => _selectedWeapon == weapon,
      isOwned: (weapon) => _isOwned(weapon),
      onSelect: (weapon) {
        setState(() {
          _selectedWeapon = _selectedWeapon == weapon ? WeaponType.none : weapon;
        });
      },
      isArcade: isArcade,
    );
  }

  /// Sezione Cornice
  Widget _buildFrameSection(BuildContext context, bool isArcade) {
    return _buildCustomizationSection(
      title: 'CORNICE',
      options: FrameType.values.where((f) => f != FrameType.none).toList(),
      isSelected: (frame) => _selectedFrame == frame,
      isOwned: (frame) => _isOwned(frame),
      onSelect: (frame) {
        setState(() {
          _selectedFrame = frame;
        });
      },
      isArcade: isArcade,
    );
  }

  /// Sezione generica
  Widget _buildCustomizationSection({
    required String title,
    required List<dynamic> options,
    required bool Function(dynamic) isSelected,
    required bool Function(dynamic) isOwned,
    required Function(dynamic) onSelect,
    required bool isArcade,
  }) {
    final accentColor = isArcade ? ArcadeGreen : FantasyGoldLight;

    return Card(
      color: (isArcade ? const Color(0xFF15151F) : FantasySurface)
          .withValues(alpha: 0.82),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: options.map((option) {
                  final selected = isSelected(option);
                  final owned = isOwned(option);
                  final name = option.toString().split('.').last;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildOptionChip(
                      displayName: name,
                      isSelected: selected,
                      isLocked: !owned,
                      onClick: () {
                        if (owned) onSelect(option);
                      },
                      isArcade: isArcade,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chip opzione
  Widget _buildOptionChip({
    required String displayName,
    required bool isSelected,
    required bool isLocked,
    required VoidCallback onClick,
    required bool isArcade,
  }) {
    final accentColor = isArcade ? ArcadeGreen : FantasyGold;

    final borderColor = isSelected
        ? accentColor
        : isLocked
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.15);

    final bgColor = isSelected
        ? accentColor.withValues(alpha: 0.16)
        : isLocked
        ? Colors.black.withValues(alpha: 0.25)
        : Colors.white.withValues(alpha: 0.03);

    return GestureDetector(
      onTap: isLocked ? null : onClick,
      child: Container(
        width: 100,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            displayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isArcade ? const Color(0xFF66FF66) : FantasyGoldLight)
                  : (isArcade ? const Color(0xFF66FF66) : FantasyTextSecondary),
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Pulsanti azione
  Widget _buildActionButtons(BuildContext context, bool isArcade, Color accentColor) {
    final buttonTextColor =
    isArcade ? const Color(0xFF071007) : const Color(0xFF0D0B14);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _reset,
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              side: BorderSide(color: accentColor.withValues(alpha: 0.65)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 48),
            ),
            child: const Text('Ripristina'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _hasChanges ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: buttonTextColor,
              disabledBackgroundColor: accentColor.withValues(alpha: 0.22),
              disabledForegroundColor: buttonTextColor.withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 48),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_hasChanges) ...[
                  const Icon(Icons.check, size: 17),
                  const SizedBox(width: 6),
                ],
                const Text(
                  'Salva',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Verifica se un cosmetico è posseduto
  bool _isOwned(dynamic option) {
    if (option == HatType.none ||
        option == WeaponType.none ||
        option == FrameType.none ||
        option == FrameType.basic) {
      return true;
    }

    String? shopId;
    if (option is HatType) shopId = CosmeticIdMapper.hatToShopId(option);
    if (option is WeaponType) shopId = CosmeticIdMapper.weaponToShopId(option);
    if (option is FrameType) shopId = CosmeticIdMapper.frameToShopId(option);

    final enumName = option.toString().split('.').last;

    return (shopId != null && widget.ownedItemIds.contains(shopId)) ||
        widget.ownedItemIds.contains(enumName);
  }
}