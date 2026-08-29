// test/session_manager_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Quester/data/session/session_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SessionManager Tests', () {
    test('Dovrebbe restituire null se nessuna sessione è attiva', () async {
      final sessionManager = SessionManager();
      final currentUserId = await sessionManager.loggedUserId();

      expect(currentUserId, isNull);
      expect(await sessionManager.isLoggedIn(), isFalse);
    });

    test('Dovrebbe creare una sessione e memorizzare correttamente l\'utente', () async {
      final sessionManager = SessionManager();

      await sessionManager.createSession(42);

      final currentUserId = await sessionManager.loggedUserId();

      expect(currentUserId, equals(42));
      expect(await sessionManager.isLoggedIn(), isTrue);
    });

    test('Dovrebbe rimuovere la sessione in caso di logout', () async {
      final sessionManager = SessionManager();

      await sessionManager.createSession(42);
      expect(await sessionManager.isLoggedIn(), isTrue);

      await sessionManager.clearSession();

      final currentUserId = await sessionManager.loggedUserId();
      expect(currentUserId, isNull);
      expect(await sessionManager.isLoggedIn(), isFalse);
    });
  });
}