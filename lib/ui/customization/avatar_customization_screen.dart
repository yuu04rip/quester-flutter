// lib/screens/avatar_customization_screen.dart

import 'package:flutter/material.dart';
import '/repository/user_repository.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '/utils/cosmetic_id_mapper.dart';
import '/widgets/avatar_view.dart';

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

  /// Cosmetici attualmente selezionati
  AvatarCosmetics get _currentCosmetics => AvatarCosmetics(
    hat: _selectedHat,
    weapon: _selectedWeapon,
    frame: _selectedFrame,
  );

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
    widget.onSave(_currentCosmetics);
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isArcade, accentColor),
              const SizedBox(height: 20),
              _buildAvatarPreview(context, isArcade, accentColor),
              const SizedBox(height: 20),
              _buildSelectionSummary(context, isArcade),
              const SizedBox(height: 24),
              _buildHatSection(context, isArcade),
              const SizedBox(height: 16),
              _buildWeaponSection(context, isArcade),
              const SizedBox(height: 16),
              _buildFrameSection(context, isArcade),
              const SizedBox(height: 32),
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
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Gestione Equipaggiamento',
              style: TextStyle(
                color: isArcade ? const Color(0xFF66FF66) : FantasyTextSecondary,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  /// Anteprima avatar artistica e rifinita
  Widget _buildAvatarPreview(BuildContext context, bool isArcade, Color accentColor) {
    return Center(
      child: Container(
        width: 190,
        height: 190,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: isArcade
                ? [const Color(0xFF00FF66), const Color(0xFF003311), const Color(0xFF00FF66)]
                : [const Color(0xFF5C4033), const Color(0xFFFFD700), const Color(0xFF8B6508), const Color(0xFF5C4033)],
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.35),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isArcade ? const Color(0xFF0A0A12) : const Color(0xFF140D07),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.7),
              width: 2.5,
            ),
          ),
          child: Center(
            child: AvatarView(
              cosmetics: _currentCosmetics,
              size: 150,
              scale: 1.4,
              verticalOffset: 4,
            ),
          ),
        ),
      ),
    );
  }

  /// Riepilogo selezioni
  Widget _buildSelectionSummary(BuildContext context, bool isArcade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: (isArcade ? const Color(0xFF15151F) : FantasySurface)
            .withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isArcade ? ArcadeGreen : FantasyGold).withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSelectionBadge('Copricapo', _getHatDisplayName(), isArcade),
          _buildDivider(isArcade),
          _buildSelectionBadge('Arma', _getWeaponDisplayName(), isArcade),
          _buildDivider(isArcade),
          _buildSelectionBadge('Cornice', _getFrameDisplayName(), isArcade),
        ],
      ),
    );
  }

  String _getHatDisplayName() {
    switch (_selectedHat) {
      case HatType.none:
        return 'Base';
      case HatType.mago:
        return 'Cap. Mago';
      case HatType.cavaliere:
        return 'Elmo Cav.';
      case HatType.scifi:
        return 'Vis. Futur.';
    }
  }

  String _getWeaponDisplayName() {
    switch (_selectedWeapon) {
      case WeaponType.none:
        return 'Base';
      case WeaponType.staff:
        return 'Bastone';
      case WeaponType.sword:
        return 'Spada';
      case WeaponType.gun:
        return 'Pistola';
    }
  }

  String _getFrameDisplayName() {
    switch (_selectedFrame) {
      case FrameType.none:
      case FrameType.basic:
        return 'Base';
      case FrameType.mago:
        return 'Mago';
      case FrameType.cavaliere:
        return 'Caval.';
      case FrameType.scifi:
        return 'Sci-Fi';
    }
  }

  Widget _buildSelectionBadge(String label, String value, bool isArcade) {
    final accentColor = isArcade ? const Color(0xFF66FF66) : FantasyGoldLight;

    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              color: isArcade ? const Color(0xFF66FF66) : FantasyTextSecondary,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isArcade) {
    return Container(
      width: 1,
      height: 32,
      color: (isArcade ? ArcadeGreen : FantasyGold).withValues(alpha: 0.2),
    );
  }

  /// Sezione Copricapo (Includiamo HatType.none e HatType.cavaliere)
  Widget _buildHatSection(BuildContext context, bool isArcade) {
    final options = [HatType.none, ...HatType.values.where((h) => h != HatType.none)];

    return _buildCustomizationSection(
      title: 'COPRICAPO',
      subtitle: 'Seleziona un copricapo per il tuo avatar',
      options: options,
      isSelected: (hat) => _selectedHat == hat,
      isOwned: (hat) => _isOwned(hat),
      onSelect: (hat) {
        setState(() {
          _selectedHat = hat;
        });
      },
      isArcade: isArcade,
    );
  }

  /// Sezione Arma
  Widget _buildWeaponSection(BuildContext context, bool isArcade) {
    final options = [WeaponType.none, ...WeaponType.values.where((w) => w != WeaponType.none)];

    return _buildCustomizationSection(
      title: 'ARMA',
      subtitle: 'Scegli l\'arma da impugnare',
      options: options,
      isSelected: (weapon) => _selectedWeapon == weapon,
      isOwned: (weapon) => _isOwned(weapon),
      onSelect: (weapon) {
        setState(() {
          _selectedWeapon = weapon;
        });
      },
      isArcade: isArcade,
    );
  }

  /// Sezione Cornice
  Widget _buildFrameSection(BuildContext context, bool isArcade) {
    final options = [FrameType.basic, ...FrameType.values.where((f) => f != FrameType.none && f != FrameType.basic)];

    return _buildCustomizationSection(
      title: 'CORNICE',
      subtitle: 'Personalizza il bordo esterno del profilo',
      options: options,
      isSelected: (frame) => _selectedFrame == frame || (_selectedFrame == FrameType.none && frame == FrameType.basic),
      isOwned: (frame) => _isOwned(frame),
      onSelect: (frame) {
        setState(() {
          _selectedFrame = frame;
        });
      },
      isArcade: isArcade,
    );
  }

  /// Sezione generica stilizzata
  Widget _buildCustomizationSection({
    required String title,
    required String subtitle,
    required List<dynamic> options,
    required bool Function(dynamic) isSelected,
    required bool Function(dynamic) isOwned,
    required Function(dynamic) onSelect,
    required bool isArcade,
  }) {
    final accentColor = isArcade ? ArcadeGreen : FantasyGoldLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isArcade ? const Color(0xFF15151F) : FantasySurface)
            .withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: isArcade ? const Color(0xFF888899) : FantasyTextSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: options.map((option) {
                final selected = isSelected(option);
                final owned = _isOwned(option);
                final name = _getOptionDisplayName(option);

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
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
    );
  }

  String _getOptionDisplayName(dynamic option) {
    if (option is HatType) {
      switch (option) {
        case HatType.none:
          return 'Base';
        case HatType.mago:
          return 'Cap. Mago';
        case HatType.cavaliere:
          return 'Elmo Cav.';
        case HatType.scifi:
          return 'Vis. Futur.';
      }
    }
    if (option is WeaponType) {
      switch (option) {
        case WeaponType.none:
          return 'Base';
        case WeaponType.staff:
          return 'Bastone';
        case WeaponType.sword:
          return 'Spada';
        case WeaponType.gun:
          return 'Pistola';
      }
    }
    if (option is FrameType) {
      switch (option) {
        case FrameType.none:
        case FrameType.basic:
          return 'Base';
        case FrameType.mago:
          return 'Mago';
        case FrameType.cavaliere:
          return 'Caval.';
        case FrameType.scifi:
          return 'Sci-Fi';
      }
    }
    return option.toString().split('.').last;
  }

  /// Chip opzione migliorata
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
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.15);

    final bgColor = isSelected
        ? accentColor.withValues(alpha: 0.2)
        : isLocked
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.04);

    return GestureDetector(
      onTap: isLocked ? null : onClick,
      child: Opacity(
        opacity: isLocked ? 0.35 : 1.0,
        child: Container(
          constraints: const BoxConstraints(minWidth: 105),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.25),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ]
                : null,
          ),
          child: Center(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isArcade ? const Color(0xFF66FF66) : FantasyGoldLight)
                    : (isArcade ? const Color(0xFF88CC99) : FantasyTextSecondary),
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  /// Pulsanti azione inferiori
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
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: const Size(0, 50),
            ),
            child: const Text(
              'Ripristina',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _hasChanges ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: buttonTextColor,
              disabledBackgroundColor: accentColor.withValues(alpha: 0.2),
              disabledForegroundColor: buttonTextColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: const Size(0, 50),
              elevation: 4,
            ),
            child: Text(
              'Salva Modifiche',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: _hasChanges ? buttonTextColor : buttonTextColor.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

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