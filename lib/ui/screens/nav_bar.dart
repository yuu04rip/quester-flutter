// lib/screens/nav_bar.dart

import 'package:flutter/material.dart';
import '/data/dao/shop_dao.dart';
import '/repository/mission_repository.dart';
import '/repository/user_repository.dart';
import '/data/session/session_manager.dart';
import '/domain/service/auth_service.dart';
import '/domain/service/mission_service.dart';
import '/domain/service/shop_service.dart';
import 'nav_screens.dart';
import 'profile_screen.dart';
import 'mission/mission_list_screen.dart';
import 'shop_screen.dart';
import '/ui/customization/avatar_customization_screen.dart';  // ✅ Import aggiuntoo

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

  const NavBar({
    super.key,
    required this.services,
    required this.repositories,
    required this.sessionManager,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 1; // Inizia su "Missioni"
  bool _showCustomization = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Theme.of(context)
            .colorScheme
            .onSurfaceVariant
            .withValues(alpha: 0.7),
      ),
      body: _showCustomization ? _buildCustomization() : _buildBody(),
    );
  }

  /// ✅ Personalizzazione avatar (schermata reale)
  Widget _buildCustomization() {
    return AvatarCustomizationScreen(
      initialCosmetics: const AvatarCosmetics(),
      ownedItemIds: {},
      onBack: () {
        setState(() => _showCustomization = false);
      },
      onSave: (cosmetics) {
        setState(() => _showCustomization = false);
      },
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
            },
            onDeleteAccount: () async {
              await widget.services.authService.deleteAccount();
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