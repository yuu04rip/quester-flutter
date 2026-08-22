// lib/domain/service/auth_service.dart

import '../../data/session/session_manager.dart';
import '/repository/auth_repository.dart';
import '/repository/user_repository.dart';

// NON ridefinire AuthResult! Usa quello del repository.

class AuthService {
  final SessionManager sessionManager;
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthService({
    required this.sessionManager,
    required this.authRepository,
    required this.userRepository,
  });

  /// Verifica se l'utente è autenticato
  Future<bool> isAuthenticated() => sessionManager.isLoggedIn();

  /// Registrazione
  Future<AuthResult> register(String username, String? email, String password) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanEmail = email?.trim().toLowerCase();

    final validationError = _validateForRegister(cleanUsername, cleanEmail, password);
    if (validationError != null) return AuthError(validationError);

    final result = await authRepository.register(cleanUsername, cleanEmail, password);

    if (result is AuthSuccess) {
      await sessionManager.clearSession();
      await sessionManager.createSession(result.user.id);  // ✅ user.id, non userId
    }

    return result;
  }

  /// Login
  Future<AuthResult> login(String identity, String password) async {
    final cleanIdentity = identity.trim().toLowerCase();

    if (cleanIdentity.isEmpty) return AuthError('Username o email obbligatorio');
    if (password.isEmpty) return AuthError('Password obbligatoria');

    final result = await authRepository.login(cleanIdentity, password);

    if (result is AuthSuccess) {
      await sessionManager.clearSession();
      await sessionManager.createSession(result.user.id);  // ✅ user.id, non userId
    }

    return result;
  }

  /// Logout
  Future<void> logout() => sessionManager.clearSession();

  /// Aggiorna username
  Future<bool> updateUsername(String newUsername) async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) return false;
    return userRepository.updateUsername(userId, newUsername);
  }

  /// Elimina account
  Future<bool> deleteAccount() async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) return false;

    final result = await userRepository.deleteAccount(userId);
    if (result) {
      await sessionManager.clearSession();
    }
    return result;
  }

  /// Validazione per la registrazione
  String? _validateForRegister(String username, String? email, String password) {
    if (username.isEmpty) return 'Username obbligatorio';
    if (username.length < 3) return 'Username troppo corto (minimo 3 caratteri)';

    if (email != null && email.isNotEmpty) {
      final emailRegex = RegExp(r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$');
      if (!emailRegex.hasMatch(email)) return 'Email non valida';
    }

    if (password.length < 8) return 'Password troppo corta (minimo 8 caratteri)';
    if (!password.contains(RegExp(r'[0-9]'))) return 'La password deve contenere almeno 1 numero';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'La password deve contenere almeno 1 maiuscola';

    return null;
  }
}