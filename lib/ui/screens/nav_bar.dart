// lib/screens/nav_bar.dart

import 'package:flutter/material.dart';
import '/data/dao/shop_dao.dart';
import '/repository/mission_repository.dart';
import '/repository/user_repository.dart';
import '/data/session/session_manager.dart';
import '/domain/service/auth_service.dart';
import '/domain/service/mission_service.dart';
import '/domain/service/shop_service.dart';
import '/widgets/arcade_background.dart'; // ✅ Importato lo sfondo arcade
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
    required this.onLogout,  // ✅ Obbligatorio
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

    return ArcadeBackground(
      child: Scaffold(
        // ✅ Rimosso Colors.transparent fisso: i temi normali useranno il proprio colore di sfondo,
        // mentre in modalità arcade ci penserà ArcadeBackground a rendere lo sfondo trasparente.
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
          backgroundColor: const Color(0xA90D0B14),
          selectedItemColor: theme.colorScheme.secondary,
          unselectedItemColor: theme.colorScheme.onSurfaceVariant
              .withValues(alpha: 0.7),
        ),
        body: _showCustomization ? _buildCustomization() : _buildBody(),
      ),
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
              widget.onLogout();  // ✅ Torna al login
            },
            onDeleteAccount: () async {
              await widget.services.authService.deleteAccount();
              widget.onLogout();  // ✅ Torna al login
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