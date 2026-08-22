// lib/screens/shop_screen.dart

import 'package:flutter/material.dart';
import '/data/dao/shop_dao.dart';
import '/data/models/shop_item.dart';
import '/repository/user_repository.dart';
import '/data/session/session_manager.dart';
import '/domain/service/shop_service.dart';
import '/ui/theme/colors.dart';

/// Schermata negozio
class ShopScreen extends StatefulWidget {
  final ShopService shopService;
  final ShopDao shopDao;
  final UserRepository userRepository;
  final SessionManager sessionManager;

  const ShopScreen({
    super.key,
    required this.shopService,
    required this.shopDao,
    required this.userRepository,
    required this.sessionManager,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<ShopItem> _shopItems = [];
  Set<String> _ownedItemIds = {};
  int _userCoins = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  /// Carica i dati del negozio
  Future<void> _loadShopData() async {
    final userId = await widget.sessionManager.loggedUserId();

    final items = await widget.shopDao.getAllItems();
    final owned = userId != null
        ? await widget.userRepository.getOwnedCosmetics(userId)
        : [];
    final user = userId != null
        ? await widget.userRepository.getUserById(userId)
        : null;

    setState(() {
      _shopItems = items;
      _ownedItemIds = owned.map((o) => o.itemId).toSet().cast<String>();
      _userCoins = user?.coins ?? 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildHeader(context),
        ),
        Expanded(
          child: _buildShopGrid(context),
        ),
      ],
    );
  }

  /// Header con monete
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.65),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '✦ Negozio ✦',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/coin.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_userCoins',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Oggetti posseduti: ${_ownedItemIds.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Griglia degli oggetti
  Widget _buildShopGrid(BuildContext context) {
    if (_shopItems.isEmpty) {
      return Center(
        child: Text(
          '✦ Nessun oggetto disponibile ✦',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _shopItems.length,
      itemBuilder: (context, index) {
        final item = _shopItems[index];
        final isOwned = _ownedItemIds.contains(item.itemId);
        return _buildShopItemCard(context, item, isOwned);
      },
    );
  }

  /// Card singolo oggetto
  Widget _buildShopItemCard(BuildContext context, ShopItem item, bool isOwned) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOwned
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.secondary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildShopItemIcon(context, item, isOwned),
            const SizedBox(height: 8),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOwned
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if (isOwned)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 14, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(
                    'Posseduto',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/coin.png',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.price}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FantasyGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 30,
                child: ElevatedButton(
                  onPressed: () => _handleBuyItem(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'ACQUISTA',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Icona dinamica in base all'item
  Widget _buildShopItemIcon(BuildContext context, ShopItem item, bool isOwned) {
    final theme = Theme.of(context);
    final iconName = item.iconName;

    // Mappa iconName → Widget
    return switch (iconName) {
    // PNG esistenti
      'ic_gun_spaziale' => Image.asset(
        'assets/images/ic_gun_spaziale.png',
        width: 40,
        height: 40,
        color: isOwned ? Colors.grey : null,
        colorBlendMode: isOwned ? BlendMode.saturation : null,
      ),
      'ic_theme_arcade' => Image.asset(
        'assets/images/ic_theme_arcade.png',
        width: 40,
        height: 40,
        color: isOwned ? Colors.grey : null,
        colorBlendMode: isOwned ? BlendMode.saturation : null,
      ),
      'ic_visor_futuristico' => Image.asset(
        'assets/images/ic_visor_futuristico.png',
        width: 40,
        height: 40,
        color: isOwned ? Colors.grey : null,
        colorBlendMode: isOwned ? BlendMode.saturation : null,
      ),

    // Cornici (disegnate con Container)
      'ic_frame_scifi' => _buildFrameIcon(
        color: const Color(0xFF00FF66),
        isOwned: isOwned,
        hasGlow: true,
      ),
      'frame_mago' => _buildFrameIcon(
        color: const Color(0xFF6B4C9A),
        isOwned: isOwned,
      ),
      'frame_cavaliere' => _buildFrameIcon(
        color: const Color(0xFFD4AF37),
        isOwned: isOwned,
      ),
      'frame_basic' => _buildFrameIcon(
        color: const Color(0xFFD4AF37),
        isOwned: isOwned,
      ),

    // Cappelli e armi (usa le immagini avatar)
      'hat_mago' => _buildAvatarPartIcon(
        assetPath: 'assets/images/char_hat.png',
        isOwned: isOwned,
      ),
      'elmo_cavaliere' => _buildAvatarPartIcon(
        assetPath: 'assets/images/char_hat.png',
        isOwned: isOwned,
      ),
      'staff_mago' => _buildAvatarPartIcon(
        assetPath: 'assets/images/char_weapon_wood.png',
        isOwned: isOwned,
      ),
      'sword_cavaliere' => _buildAvatarPartIcon(
        assetPath: 'assets/images/char_weapon_wood.png',
        isOwned: isOwned,
      ),

    // Fallback: icona shopping cart
      _ => Icon(
        Icons.shopping_cart,
        size: 40,
        color: isOwned
            ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
            : theme.colorScheme.secondary,
      ),
    };
  }

  /// Icona cornice (disegnata)
  Widget _buildFrameIcon({
    required Color color,
    required bool isOwned,
    bool hasGlow = false,
  }) {
    final displayColor = isOwned ? Colors.grey : color;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: displayColor,
          width: 4,
        ),
        boxShadow: hasGlow && !isOwned
            ? [
          BoxShadow(
            color: displayColor.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ]
            : null,
      ),
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: displayColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  /// Icona parte avatar (cappello, arma)
  Widget _buildAvatarPartIcon({
    required String assetPath,
    required bool isOwned,
  }) {
    return Image.asset(
      assetPath,
      width: 40,
      height: 40,
      color: isOwned ? Colors.grey : null,
      colorBlendMode: isOwned ? BlendMode.saturation : null,
      fit: BoxFit.contain,
    );
  }

  /// Gestione acquisto
  Future<void> _handleBuyItem(ShopItem item) async {
    final success = await widget.shopService.buyItem(item.itemId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✦ ${item.name} acquistato! ✦'
              : '✗ Monete insufficienti o già posseduto!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    if (success) {
      _loadShopData();
    }
  }
}