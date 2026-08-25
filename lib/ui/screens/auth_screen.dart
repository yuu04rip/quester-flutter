// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/magic_burst_button.dart';
import '/repository/auth_repository.dart';
import '/domain/service/auth_service.dart';
import '/utils/string_utils.dart';
import '/ui/theme/app_theme.dart';
import '/widgets/arcade_background.dart';
import '/widgets/royal_background.dart';

/// Schermata di autenticazione (login/registrazione)
class AuthScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onAuthSuccess;

  const AuthScreen({
    super.key,
    required this.authService,
    required this.onAuthSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _usernameError = _validateIdentity(_usernameController.text.trim());
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    return _usernameError == null && _emailError == null && _passwordError == null;
  }

  String? _validateIdentity(String identity) {
    if (identity.isEmpty) {
      return _isRegisterMode ? 'Username obbligatorio' : 'Username o email obbligatorio';
    }
    if (_isRegisterMode && identity.length < 3) {
      return 'Username troppo corto (minimo 3 caratteri)';
    }
    return null;
  }

  String? _validateEmail(String email) {
    if (_isRegisterMode && email.isNotEmpty) {
      final emailRegex = RegExp(r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$');
      if (!emailRegex.hasMatch(email.trim())) {
        return 'Email non valida';
      }
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password obbligatoria';
    if (password.length < 8) return 'Password troppo corta (minimo 8 caratteri)';
    if (!password.contains(RegExp(r'[0-9]'))) return 'La password deve contenere almeno 1 numero';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'La password deve contenere almeno 1 maiuscola';
    return null;
  }

  String _toFantasyError(String? message) {
    if (message == null || message.isEmpty) {
      return '✦ Un oscuro incantesimo ha interrotto il rituale.';
    }

    final m = message.toLowerCase();

    if (m.contains('username o email obbligatorio')) return '✦ L\'identità dell\'avventuriero è richiesta.';
    if (m.contains('username obbligatorio')) return '✦ Il nome dell\'avventuriero è richiesto.';
    if (m.contains('username troppo corto')) return '✦ Il nome è troppo breve per entrare nelle cronache del regno.';
    if (m.contains('email non valida')) return '❖ Il sigillo del corvo (email) non è valido.';
    if (m.contains('password obbligatoria')) return '✦ Devi forgiare una parola segreta.';
    if (m.contains('password troppo corta')) return '❖ La runa segreta è troppo debole (minimo 8 simboli).';
    if (m.contains('almeno 1 numero')) return '❖ La runa segreta deve contenere almeno un numero arcano.';
    if (m.contains('almeno 1 maiuscola')) return '❖ La runa segreta deve contenere almeno una lettera nobile (maiuscola).';
    if (m.contains('username già esistente')) return '⚔ Questo nome è già preso da un altro eroe.';
    if (m.contains('email già registrata')) return '❖ Questo sigillo è già legato a un eroe.';
    if (m.contains('credenziali non valide')) return 'ᗢ Le chiavi del portale non coincidono.';

    return '✦ $message';
  }

  Future<void> _handleAuth() async {
    if (!_validate()) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    AuthResult result;

    if (_isRegisterMode) {
      final capitalizedUsername = StringUtils.capitalizeFirstLetter(_usernameController.text.trim());
      result = await widget.authService.register(
        capitalizedUsername,
        _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      result = await widget.authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    switch (result) {
      case AuthSuccess():
        widget.onAuthSuccess();
        break;
      case AuthError(:final message):
        setState(() => _errorMessage = message);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTheme = ThemeManager.currentTheme;
    final isArcade = currentTheme == AppTheme.arcade;
    final isRegale = currentTheme == AppTheme.regale;

    // 💡 Scaffold con sfondo trasparente per permettere al background personalizzato di vedersi
    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: isArcade ? 0 : (isRegale ? 16 : 24),
            color: isArcade
                ? theme.colorScheme.surface.withValues(alpha: 0.85)
                : (isRegale ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.92) : null),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isArcade ? 8 : (isRegale ? 22 : 28)),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: isArcade ? 0.9 : 0.65),
                width: isArcade ? 2 : (isRegale ? 1.2 : 2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(theme, isArcade, isRegale),
                  const SizedBox(height: 16),
                  Divider(color: theme.colorScheme.secondary.withValues(alpha: 0.35)),
                  const SizedBox(height: 16),
                  _buildForm(theme, isArcade, isRegale),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    _buildErrorCard(_toFantasyError(_errorMessage), theme),
                  ],
                  const SizedBox(height: 16),
                  _buildButtons(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // 👑 Applicazione dello sfondo coerente con il tema attivo
    if (isArcade) {
      return ArcadeBackground(child: scaffold);
    } else if (isRegale) {
      return RoyalBackground(child: scaffold);
    }

    // Tema Fantasy standard
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: scaffold.body,
    );
  }

  Widget _buildHeader(ThemeData theme, bool isArcade, bool isRegale) {
    return Column(
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            shape: isArcade ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isArcade ? BorderRadius.circular(4) : null,
            border: Border.all(color: theme.colorScheme.secondary, width: isArcade ? 2 : 1),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: theme.colorScheme.secondary,
            size: 34,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '✦ QUESTER ✦',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        Text(
          _isRegisterMode ? 'Crea il tuo personaggio' : 'Bentornato, avventuriero',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          _isRegisterMode ? 'Il viaggio inizia adesso' : 'Il regno attende il tuo ritorno',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(ThemeData theme, bool isArcade, bool isRegale) {
    return Column(
      children: [
        _buildTextField(
          controller: _usernameController,
          label: _isRegisterMode ? 'Nome avventuriero' : 'Username o Email',
          error: _usernameError,
          theme: theme,
          isArcade: isArcade,
        ),
        if (_isRegisterMode) ...[
          const SizedBox(height: 10),
          _buildTextField(
            controller: _emailController,
            label: 'Email (opzionale)',
            error: _emailError,
            theme: theme,
            isArcade: isArcade,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
        const SizedBox(height: 10),
        _buildPasswordField(theme, isArcade),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required ThemeData theme,
    required bool isArcade,
    String? error,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final borderRadius = isArcade ? 4.0 : 12.0;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: isArcade,
        fillColor: isArcade ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4) : null,
        errorText: error != null ? _toFantasyError(error) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.secondary, width: isArcade ? 2 : 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.secondary.withValues(alpha: isArcade ? 0.6 : 0.35),
            width: isArcade ? 1.5 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(ThemeData theme, bool isArcade) {
    final borderRadius = isArcade ? 4.0 : 12.0;

    return TextField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: isArcade,
        fillColor: isArcade ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4) : null,
        errorText: _passwordError != null ? _toFantasyError(_passwordError) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.secondary, width: isArcade ? 2 : 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.secondary.withValues(alpha: isArcade ? 0.6 : 0.35),
            width: isArcade ? 1.5 : 1,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _passwordVisible = !_passwordVisible);
          },
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error, ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          error,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(ThemeData theme) {
    return Column(
      children: [
        MagicBurstButton(
          text: _isRegisterMode ? 'INIZIA L\'AVVENTURA' : 'ENTRA NEL REGNO',
          loading: _isLoading,
          onClickAfterEffect: () {
            _handleAuth();
          },
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            setState(() {
              _isRegisterMode = !_isRegisterMode;
              _errorMessage = null;
              _usernameError = null;
              _emailError = null;
              _passwordError = null;
            });
          },
          child: Text(
            _isRegisterMode
                ? 'Hai già un account? Accedi'
                : 'Non hai un account? Registrati',
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}