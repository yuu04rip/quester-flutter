// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '/data/models/user.dart';
import '/data/models/owned_cosmetic.dart';
import '/repository/user_repository.dart';
import '/data/session/session_manager.dart';
import '../theme/colors.dart';
import 'profile_components.dart';
import 'profile_constants.dart';
import '/widgets/avatar_view.dart';
import '/widgets/magic_burst_button.dart';
import 'owned_cosmetics_section.dart';
import '/ui/theme/app_theme.dart';
import '/widgets/arcade_mini_game_widget.dart';

/// Callback per le azioni del profilo
class ProfileCallbacks {
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final Function(String) onUpdateUsername;
  final VoidCallback onShowCustomization;

  ProfileCallbacks({
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onUpdateUsername,
    required this.onShowCustomization,
  });
}

/// Schermata profilo utente
class ProfileScreen extends StatefulWidget {
  final UserRepository userRepository;
  final SessionManager sessionManager;
  final ProfileCallbacks callbacks;

  const ProfileScreen({
    super.key,
    required this.userRepository,
    required this.sessionManager,
    required this.callbacks,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  List<OwnedCosmetic> _ownedCosmetics = [];
  AvatarCosmetics _equippedCosmetics = const AvatarCosmetics();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Restituisce il titolo arcade in base al livello (Max Level 50)
  String _getPlayerTitle(int livello) {
    if (livello >= 50) return '★ GALAXY COMMANDER ★';
    if (livello >= 40) return '★ ELITE VETERAN ★';
    if (livello >= 25) return '★ SPACE ACE ★';
    if (livello >= 10) return '★ SPACE CADET ★';
    return '★ NOOB PILOT ★';
  }

  /// Carica i dati dell'utente in modo sicuro e reattivo
  Future<void> _loadUserData() async {
    final userId = await widget.sessionManager.loggedUserId();

    if (userId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final user = await widget.userRepository.getUserById(userId);
    final owned = await widget.userRepository.getOwnedCosmetics(userId);
    final equipped = await widget.userRepository.getEquippedCosmetics(userId);

    final displayCosmetics = AvatarCosmetics(
      hat: equipped.hat,
      weapon: equipped.weapon,
      frame: equipped.frame == FrameType.none
          ? FrameType.basic
          : equipped.frame,
    );

    if (mounted) {
      setState(() {
        _user = user;
        _ownedCosmetics = owned;
        _equippedCosmetics = displayCosmetics;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_user == null) {
      return const Center(
        child: Text('Utente non trovato'),
      );
    }

    final isArcade = ThemeManager.currentTheme == AppTheme.arcade;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ============================================================
        // CONTENUTO PRINCIPALE DEL PROFILO
        // ============================================================
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileCard(context),

              const SizedBox(height: 16),

              // Sezione cosmetici e temi
              OwnedCosmeticsSection(
                ownedCosmetics: _ownedCosmetics,
                onRefresh: _loadUserData,
                onThemeApplied: (theme) {
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),

              const SizedBox(height: 16),

              // Pulsante logout
              MagicBurstButton(
                text: 'ESCI DAL REGNO',
                loading: false,
                onClickAfterEffect: () async {
                  widget.callbacks.onLogout();
                },
              ),

              const SizedBox(height: 8),

              _buildDeleteButton(context),
            ],
          ),
        ),

        // ============================================================
        // 🕹️ ARCADE MINI GAME
        // ============================================================
        if (isArcade)
          const Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.32,
                child: ArcadeMiniGameWidget(),
              ),
            ),
          ),
      ],
    );
  }

  /// Card principale del profilo
  Widget _buildProfileCard(BuildContext context) {
    final user = _user!;
    final theme = Theme.of(context);
    final isArcade = ThemeManager.currentTheme == AppTheme.arcade;

    return Container(
      decoration: isArcade
          ? BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(
              alpha: 0.35,
            ),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      )
          : null,
      child: Card(
        elevation: isArcade ? 0 : 24,
        color: isArcade
            ? theme.colorScheme.surface.withValues(alpha: 0.9)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            isArcade ? 8 : 28,
          ),
          side: BorderSide(
            color: theme.colorScheme.primary.withValues(
              alpha: isArcade ? 1.0 : 0.65,
            ),
            width: isArcade ? 2.5 : 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ========================================================
              // HEADER ARCADE (Titolo dinamico basato sul livello)
              // ========================================================
              if (isArcade) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    _getPlayerTitle(user.livello),
                    style: TextStyle(
                      fontFamily: 'QuesterPixel',
                      fontSize: 10,
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],

              // ========================================================
              // AVATAR
              // ========================================================
              GestureDetector(
                onTap: () async {
                  widget.callbacks.onShowCustomization();
                  await _loadUserData();
                },
                child: AvatarView(
                  cosmetics: _equippedCosmetics,
                  size: 140,
                  scale: 1.2,
                  verticalOffset: 4,
                ),
              ),

              const SizedBox(height: 12),

              // ========================================================
              // USERNAME
              // ========================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isArcade
                        ? '[ ${user.username} ]'
                        : '✦ ${user.username} ✦',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: () => _showEditUsernameDialog(context),
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: theme.colorScheme.secondary.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ========================================================
              // LIVELLO / STAGE
              // ========================================================
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isArcade ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: isArcade
                      ? theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.8)
                      : theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(
                    isArcade ? 4 : 12,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(
                      alpha: isArcade ? 0.7 : 0.5,
                    ),
                    width: isArcade ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  isArcade
                      ? 'STAGE ${user.livello} / 50'
                      : 'Livello ${user.livello}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    letterSpacing: isArcade ? 1.5 : 0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Divider(
                color: theme.colorScheme.secondary.withValues(
                  alpha: 0.35,
                ),
              ),

              const SizedBox(height: 16),

              // ========================================================
              // XP PROGRESS
              // ========================================================
              FantasyXpProgress(
                xpTotale: user.xpTotale,
                livello: user.livello,
                xpProgress: getXpProgress(
                  user.xpTotale,
                  user.livello,
                ),
                xpInCurrentLevel: getXpInCurrentLevel(
                  user.xpTotale,
                  user.livello,
                ),
                xpNeededForLevel: getXpRequiredForLevel(
                  user.livello,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                isArcade
                    ? 'NEXT STAGE BONUS: +${getLevelUpCoins(user.livello)} COINS'
                    : 'Prossimo level-up: +${getLevelUpCoins(user.livello)} monete',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),

              // ========================================================
              // STATISTICHE
              // ========================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FantasyStatItem(
                    icon: Icons.star,
                    value: '${user.xpTotale}',
                    label: isArcade
                        ? 'SCORE'
                        : 'XP TOTALI',
                    color: FantasyGold,
                  ),

                  FantasyCoinStatItem(
                    value: '${user.coins}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pulsante elimina account
  Widget _buildDeleteButton(BuildContext context) {
    final isArcade = ThemeManager.currentTheme == AppTheme.arcade;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showDeleteAccountDialog(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.withValues(
            alpha: 0.8,
          ),
          side: BorderSide(
            color: Colors.red.withValues(alpha: 0.6),
            width: isArcade ? 1.5 : 1,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              isArcade ? 4 : 12,
            ),
          ),
        ),
        child: Text(
          isArcade
              ? 'GAME OVER (DELETE)'
              : 'Lascia il Regno',
          style: TextStyle(
            fontFamily: isArcade
                ? 'QuesterPixel'
                : null,
          ),
        ),
      ),
    );
  }

  /// Dialog modifica username
  void _showEditUsernameDialog(BuildContext context) {
    final controller = TextEditingController(
      text: _user?.username ?? '',
    );

    final isArcade =
        ThemeManager.currentTheme == AppTheme.arcade;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isArcade
              ? Theme.of(context).colorScheme.surface
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              isArcade ? 6 : 24,
            ),
            side: isArcade
                ? BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .secondary,
              width: 2,
            )
                : BorderSide.none,
          ),
          title: Text(
            'Modifica Username',
            style: TextStyle(
              fontFamily: isArcade
                  ? 'QuesterPixel'
                  : null,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Nuovo username',
              filled: isArcade,
              fillColor: isArcade
                  ? Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.4)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  isArcade ? 4 : 12,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annulla'),
            ),

            ElevatedButton(
              onPressed: () async {
                final newUsername =
                controller.text.trim();

                if (newUsername.isNotEmpty &&
                    newUsername.length >= 3) {
                  widget.callbacks.onUpdateUsername(
                    newUsername,
                  );

                  Navigator.pop(dialogContext);

                  await _loadUserData();
                }
              },
              child: const Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  /// Dialog elimina account
  void _showDeleteAccountDialog(BuildContext context) {
    final isArcade =
        ThemeManager.currentTheme == AppTheme.arcade;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isArcade
              ? Theme.of(context).colorScheme.surface
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              isArcade ? 6 : 24,
            ),
            side: isArcade
                ? const BorderSide(
              color: Colors.red,
              width: 2,
            )
                : BorderSide.none,
          ),
          title: Text(
            'Elimina Account',
            style: TextStyle(
              fontFamily: isArcade
                  ? 'QuesterPixel'
                  : null,
            ),
          ),
          content: const Text(
            'Sei sicuro di voler eliminare il tuo account? '
                'Questa azione è irreversibile.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annulla'),
            ),

            ElevatedButton(
              onPressed: () {
                widget.callbacks.onDeleteAccount();
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    isArcade ? 4 : 8,
                  ),
                ),
              ),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
  }
}