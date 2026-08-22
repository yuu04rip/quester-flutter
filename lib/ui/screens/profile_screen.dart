// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '/data/models/user.dart';
import '/data/models/owned_cosmetic.dart';
import '/repository/user_repository.dart';
import '/data/session/session_manager.dart';
import '../theme/colors.dart';
import 'profile_components.dart';
import 'profile_constants.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carica i dati dell'utente
  Future<void> _loadUserData() async {
    final userId = await widget.sessionManager.loggedUserId();
    if (userId == null) return;

    final user = await widget.userRepository.getUserById(userId);
    final owned = await widget.userRepository.getOwnedCosmetics(userId);

    setState(() {
      _user = user;
      _ownedCosmetics = owned;
      _isLoading = false;
    });
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
          _buildOwnedCosmetics(context),
          const SizedBox(height: 16),
          _buildLogoutButton(context),
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
            // Avatar (placeholder)
            GestureDetector(
              onTap: widget.callbacks.onShowCustomization,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                  border: Border.all(
                    color: theme.colorScheme.secondary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: theme.colorScheme.secondary,
                ),
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

  /// Sezione cosmetici posseduti
  Widget _buildOwnedCosmetics(BuildContext context) {
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
            Row(
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
                    Text(
                      '${_ownedCosmetics.length} oggetti posseduti',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: theme.colorScheme.secondary,
                  ),
                  onPressed: _loadUserData,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: theme.colorScheme.secondary.withValues(alpha: 0.35)),
            const SizedBox(height: 14),
            if (_ownedCosmetics.isEmpty)
              Center(
                child: Column(
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
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: _ownedCosmetics.length,
                itemBuilder: (context, index) {
                  final cosmetic = _ownedCosmetics[index];
                  return _buildCosmeticItem(context, cosmetic);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Singolo cosmetico
  Widget _buildCosmeticItem(BuildContext context, OwnedCosmetic cosmetic) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          size: 32,
        ),
      ),
    );
  }

  /// Pulsante logout
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.callbacks.onLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: FantasyGold,
          foregroundColor: FantasyBackground,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'ESCI DAL REGNO',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
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
            onPressed: () {
              final newUsername = controller.text.trim();
              if (newUsername.isNotEmpty && newUsername.length >= 3) {
                widget.callbacks.onUpdateUsername(newUsername);
                Navigator.pop(dialogContext);
                _loadUserData();
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