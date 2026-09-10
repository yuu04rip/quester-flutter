// lib/domain/service/auth_service.dart

import 'package:flutter/foundation.dart';
import '../../data/session/session_manager.dart';
import '/repository/auth_repository.dart';
import '/repository/user_repository.dart';
import 'api_service.dart';
import 'sync_service.dart';

class AuthService {
  final SessionManager sessionManager;
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final SyncService? syncService;

  AuthService({
    required this.sessionManager,
    required this.authRepository,
    required this.userRepository,
    this.syncService,
  });

  /// Verifica se l'utente è autenticato
  Future<bool> isAuthenticated() => sessionManager.isLoggedIn();

  /// Registrazione (Cloud + Locale)
  Future<AuthResult> register(String username, String? email, String password) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanEmail = email?.trim().toLowerCase();

    final validationError = _validateForRegister(cleanUsername, cleanEmail, password);
    if (validationError != null) return AuthError(validationError);

    try {
      // 1. Registrazione sul Cloud (Render / PostgreSQL)
      final cloudResponse = await ApiService.registerOnCloud(username, cleanEmail, password);
      if (cloudResponse == null || cloudResponse['user'] == null) {
        return AuthError('Errore di comunicazione con il cloud');
      }

      final userData = cloudResponse['user'];
      final cloudId = userData['id'] is int ? userData['id'] : int.parse(userData['id'].toString());

      // 2. Registrazione o salvataggio speculare sul DB Locale SQLite tramite l'AuthRepository
      final result = await authRepository.registerWithId(
        id: cloudId,
        username: userData['username'] ?? username,
        email: userData['email'] ?? cleanEmail,
        passwordHash: password,
      );

      if (result is AuthSuccess) {
        await sessionManager.clearSession();
        await sessionManager.createSession(result.user.id);
      }

      return result;
    } catch (e) {
      debugPrint('Errore durante la registrazione cloud/locale: $e');
      return AuthError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Login (Cloud + Locale)
  Future<AuthResult> login(String identity, String password) async {
    final cleanIdentity = identity.trim().toLowerCase();

    if (cleanIdentity.isEmpty) return AuthError('Username o email obbligatorio');
    if (password.isEmpty) return AuthError('Password obbligatoria');

    try {
      // 1. Autenticazione sul Cloud (Render / PostgreSQL)
      final cloudResponse = await ApiService.loginOnCloud(cleanIdentity, password);
      if (cloudResponse == null || cloudResponse['user'] == null) {
        return AuthError('Credenziali non valide');
      }

      final userData = cloudResponse['user'];
      debugPrint("DEBUG LOGIN: User data received from cloud -> $userData");

      final cloudId = userData['id'] is int ? userData['id'] : int.parse(userData['id'].toString());
      debugPrint("DEBUG LOGIN: Parsed cloudId -> $cloudId (Type: ${cloudId.runtimeType})");

      // 2. Controllo locale su SQLite
      var localUser = await userRepository.getUserById(cloudId);
      debugPrint("DEBUG LOGIN: Local user found before sync? -> ${localUser != null}");

      if (localUser == null) {
        debugPrint('DEBUG LOGIN: Utente non trovato localmente. Recupero dati completi dal cloud...');

        // Scarichiamo profilo e missioni dal cloud
        final fullCloudData = await ApiService.fetchUserDataFromCloud(cloudId);
        if (fullCloudData != null) {
          final uMap = fullCloudData['user'];
          debugPrint("DEBUG LOGIN: Saving user from cloud map -> $uMap");
          await userRepository.saveOrUpdateUserFromCloud(uMap);

          List missions = fullCloudData['missions'] ?? [];
          for (var m in missions) {
            await userRepository.saveMissionFromCloud(m);
          }
        } else {
          debugPrint('DEBUG LOGIN: fullCloudData is null, falling back to registerWithId...');
          // Fallback se per qualche motivo non ci sono dati completi ma abbiamo l'utente base
          await authRepository.registerWithId(
            id: cloudId,
            username: userData['username'],
            email: userData['email'],
            passwordHash: password,
          );
        }
      } else {
        debugPrint("DEBUG LOGIN: L'utente esiste già in locale, procediamo con l'aggiornamento eventuale.");
      }

      // 3. Verifica finale prima della sessione
      localUser = await userRepository.getUserById(cloudId);
      debugPrint("DEBUG LOGIN: Local user retrieved after save attempt -> ${localUser != null}");

      if (localUser == null) {
        debugPrint("ERRORE CRITICO: Impossibile trovare o salvare l'utente locale con ID $cloudId");
        return AuthError('Errore interno: salvataggio locale fallito');
      }

      // 4. Creazione della sessione locale
      await sessionManager.clearSession();
      await sessionManager.createSession(cloudId);

      // 5. Allineamento totale post-login
      if (syncService != null) {
        syncService!.performFullSync(cloudId);
      }

      return AuthSuccess(localUser);
    } catch (e, stackTrace) {
      debugPrint('Errore durante il login cloud/locale: $e');
      debugPrint('Stacktrace: $stackTrace');
      return AuthError(e.toString().replaceAll('Exception: ', ''));
    }
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