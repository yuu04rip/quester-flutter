// lib/screens/nav_bar.dart

import 'package:flutter/material.dart';
import '/data/dao/shop_dao.dart';
import '/repository/mission_repository.dart';
import '/repository/user_repository.dart';
import '/data/session/session_manager.dart';
import '/domain/service/auth_service.dart';
import '/domain/service/mission_service.dart';
import '/domain/service/shop_service.dart';
import '/ui/theme/app_theme.dart';
import '/widgets/arcade_background.dart';
import '/widgets/royal_background.dart';
import 'nav_screens.dart';
import 'profile_screen.dart';
import '../screens/mission/mission_list_screen.dart';
import 'shop_screen.dart';
import '../customization/avatar_customization_screen.dart';

/// Servizi necessari per la navigazione
class NavServices {
  final MissionService missionService;
  final AuthService authService;
  final ShopService shopService;

  NavServices({
    required this.missionService,
    required this.authService,
    required this.shopService,
  });
}

/// Repository necessari per la navigazione
class NavRepositories {
  final MissionRepository missionRepository;
  final UserRepository userRepository;
  final ShopDao shopDao;

  NavRepositories({
    required this.missionRepository,
    required this.userRepository,
    required this.shopDao,
  });
}

/// Barra di navigazione principale
class NavBar extends StatefulWidget {
  final NavServices services;
  final NavRepositories repositories;
  final SessionManager sessionManager;
  final VoidCallback onLogout;  // ✅ Callback per il logout

  const NavBar({
    super.key,
    required this.services,
    required this.repositories,
    required this.sessionManager,
    required this.onLogout,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 1;
  bool _showCustomization = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Controlliamo quale tema speciale è attivo
    final isArcade = ThemeManager.currentTheme == AppTheme.arcade;
    final isRegal = ThemeManager.currentTheme == AppTheme.regale;

    // 💡 Definiamo lo Scaffold principale con sfondo completamente trasparente
    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: _showCustomization
          ? null
          : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: navScreensList.map((screen) {
          return BottomNavigationBarItem(
            icon: Icon(screen.icon),
            label: screen.title,
          );
        }).toList(),
        backgroundColor: isRegal
            ? const Color(0xE01A150E) // Sfumatura dorata scura per regale
            : const Color(0xA90D0B14), // Sfumatura arcade/fantasy
        selectedItemColor: theme.colorScheme.secondary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        type: BottomNavigationBarType.fixed,
      ),
      body: SafeArea(
        child: _showCustomization ? _buildCustomization() : _buildBody(),
      ),
    );

    // 👑 Avvolgiamo lo Scaffold nel widget di sfondo corretto in base al tema attivo
    if (isArcade) {
      return ArcadeBackground(child: scaffold);
    } else if (isRegal) {
      return RoyalBackground(child: scaffold);
    }

    // Se il tema è Fantasy standard
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: scaffold.body,
      bottomNavigationBar: scaffold.bottomNavigationBar,
    );
  }

  /// ✅ Personalizzazione avatar con dati reali
  Widget _buildCustomization() {
    return FutureBuilder<({AvatarCosmetics cosmetics, Set<String> ownedIds})>(
      future: _loadCosmeticData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Errore caricamento dati'));
        }

        final data = snapshot.data!;
        return AvatarCustomizationScreen(
          initialCosmetics: data.cosmetics,
          ownedItemIds: data.ownedIds,
          onBack: () {
            setState(() => _showCustomization = false);
          },
          onSave: (cosmetics) async {
            final userId = await widget.sessionManager.loggedUserId();
            if (userId != null) {
              await widget.repositories.userRepository
                  .saveEquippedCosmetics(userId, cosmetics);
            }
            if (mounted) {
              setState(() => _showCustomization = false);
            }
          },
        );
      },
    );
  }

  /// ✅ Carica i dati reali dei cosmetici
  Future<({AvatarCosmetics cosmetics, Set<String> ownedIds})>
  _loadCosmeticData() async {
    final userId = await widget.sessionManager.loggedUserId();
    if (userId == null) {
      return (cosmetics: const AvatarCosmetics(), ownedIds: <String>{});
    }

    final cosmetics = await widget.repositories.userRepository
        .getEquippedCosmetics(userId);
    final owned = await widget.repositories.userRepository
        .getOwnedCosmetics(userId);

    return (
    cosmetics: cosmetics,
    ownedIds: owned.map((o) => o.itemId).toSet().cast<String>(),
    );
  }

  /// Costruisce il corpo in base all'indice selezionato
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return ProfileScreen(
          userRepository: widget.repositories.userRepository,
          sessionManager: widget.sessionManager,
          callbacks: ProfileCallbacks(
            onLogout: () async {
              await widget.services.authService.logout();
              widget.onLogout();
            },
            onDeleteAccount: () async {
              await widget.services.authService.deleteAccount();
              widget.onLogout();
            },
            onUpdateUsername: (newUsername) async {
              await widget.services.authService.updateUsername(newUsername);
            },
            onShowCustomization: () {
              setState(() => _showCustomization = true);
            },
          ),
        );
      case 1:
        return MissionListScreen(
          missionService: widget.services.missionService,
          missionRepository: widget.repositories.missionRepository,
          userRepository: widget.repositories.userRepository,
          sessionManager: widget.sessionManager,
        );
      case 2:
        return ShopScreen(
          shopService: widget.services.shopService,
          shopDao: widget.repositories.shopDao,
          userRepository: widget.repositories.userRepository,
          sessionManager: widget.sessionManager,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}