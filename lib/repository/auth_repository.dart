// lib/data/repository/auth_repository.dart

import '../data/dao/user_dao.dart';
import '../data/models/user.dart';
import '../../domain/security/password_hasher.dart';

/// Risultato dell'autenticazione
sealed class AuthResult {}

class AuthSuccess extends AuthResult {
  final User user;
  AuthSuccess(this.user);
}

class AuthError extends AuthResult {
  final String message;
  AuthError(this.message);
}

class AuthRepository {
  final UserDao userDao;

  AuthRepository(this.userDao);

  /// Registrazione
  Future<AuthResult> register(String username, String? email, String password) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanEmail = email?.trim().toLowerCase();
    final finalEmail = (cleanEmail == null || cleanEmail.isEmpty) ? null : cleanEmail;

    final existingUsername = await userDao.getUserByUsername(cleanUsername);
    if (existingUsername != null) return AuthError('Username già esistente');

    if (finalEmail != null) {
      final existingEmail = await userDao.getUserByEmail(finalEmail);
      if (existingEmail != null) return AuthError('Email già registrata');
    }

    final hash = PasswordHasher.hash(password);
    final user = User(
      username: cleanUsername,
      email: finalEmail,
      passwordHash: hash,
    );

    final id = await userDao.insertUser(user);
    if (id == -1) return AuthError('Errore creazione utente');

    final created = await userDao.getUserByUsername(cleanUsername);
    if (created == null) return AuthError('Errore creazione utente');

    return AuthSuccess(created);
  }

  /// Login
  Future<AuthResult> login(String identity, String password) async {
    final cleanIdentity = identity.trim().toLowerCase();
    final user = await userDao.getUserByIdentity(cleanIdentity);

    if (user == null) return AuthError('Credenziali non valide');

    final ok = PasswordHasher.verify(password, user.passwordHash);
    return ok ? AuthSuccess(user) : AuthError('Credenziali non valide');
  }
}