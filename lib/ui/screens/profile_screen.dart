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
import '/widgets/magic_burst_button.dart';  // ✅ Import per MagicBurstButton
import 'owned_cosmetics_section.dart';      // ✅ Import per la sezione cosmetici ufficiale

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

  /// Carica i dati dell'utente in modo sicuro e reattivo
  Future<void> _loadUserData() async {
    final userId = await widget.sessionManager.loggedUserId();
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final user = await widget.userRepository.getUserById(userId);
    final owned = await widget.userRepository.getOwnedCosmetics(userId);
    final equipped = await widget.userRepository.getEquippedCosmetics(userId);

    final displayCosmetics = AvatarCosmetics(
      hat: equipped.hat,
      weapon: equipped.weapon,
      frame: equipped.frame == FrameType.none ? FrameType.basic : equipped.frame,
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return const Center(child: Text('Utente non trovato'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileCard(context),
          const SizedBox(height: 16),
          // ✅ Sezione cosmetici e temi
          OwnedCosmeticsSection(
            ownedCosmetics: _ownedCosmetics,
            onRefresh: _loadUserData,
            onThemeApplied: (theme) {
              // Aggiorna lo stato per applicare subito il cambio di tema sul profilo
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(height: 16),
          // ✅ Pulsante logout con MagicBurstButton
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
    );
  }

  /// Card principale del profilo
  Widget _buildProfileCard(BuildContext context) {
    final user = _user!;
    final theme = Theme.of(context);

    return Card(
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.65),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ✅ Avatar reale con cosmetici (cliccabile per aprire la personalizzazione)
            GestureDetector(
              onTap: () async {
                widget.callbacks.onShowCustomization();
                // Ricarica i dati non appena si torna dalla schermata di personalizzazione
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
            // Username con pulsante modifica
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '✦ ${user.username} ✦',
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
                    color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Livello
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'Livello ${user.livello}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.secondary.withValues(alpha: 0.35)),
            const SizedBox(height: 16),
            // XP Progress
            FantasyXpProgress(
              xpTotale: user.xpTotale,
              livello: user.livello,
              xpProgress: getXpProgress(user.xpTotale, user.livello),
              xpInCurrentLevel: getXpInCurrentLevel(user.xpTotale, user.livello),
              xpNeededForLevel: getXpRequiredForLevel(user.livello),
            ),
            const SizedBox(height: 4),
            Text(
              'Prossimo level-up: +${getLevelUpCoins(user.livello)} monete',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // Statistiche
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FantasyStatItem(
                  icon: Icons.star,
                  value: '${user.xpTotale}',
                  label: 'XP TOTALI',
                  color: FantasyGold,
                ),
                FantasyCoinStatItem(value: '${user.coins}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Pulsante elimina account
  Widget _buildDeleteButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _showDeleteAccountDialog(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.withValues(alpha: 0.7),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Lascia il Regno'),
    );
  }

  /// Dialog modifica username
  void _showEditUsernameDialog(BuildContext context) {
    final controller = TextEditingController(text: _user?.username ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modifica Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nuovo username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUsername = controller.text.trim();
              if (newUsername.isNotEmpty && newUsername.length >= 3) {
                widget.callbacks.onUpdateUsername(newUsername);
                Navigator.pop(dialogContext);
                await _loadUserData(); // Aggiorna i dati sul momento
              }
            },
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }

  /// Dialog elimina account
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Elimina Account'),
        content: const Text('Sei sicuro di voler eliminare il tuo account? Questa azione è irreversibile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
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
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}