import 'package:flutter_test/flutter_test.dart';

// Esempio di classe o servizio che gestisce l'anti-spam / throttling delle notifiche
class NotificationManager {
  DateTime? _lastNotificationTime;
  final Duration spamCooldown;

  NotificationManager({this.spamCooldown = const Duration(seconds: 2)});

  /// Tenta di inviare una notifica. Ritorna true se inviata, false se bloccata dall'anti-spam.
  bool sendNotification(String message, {DateTime? customNow}) {
    final now = customNow ?? DateTime.now();

    if (_lastNotificationTime != null) {
      final difference = now.difference(_lastNotificationTime!);
      if (difference < spamCooldown) {
        // 🛡️ Bloccato dall'anti-spam!
        return false;
      }
    }

    // Invia la notifica e aggiorna il timestamp
    _lastNotificationTime = now;
    return true;
  }

  /// Resetta lo stato per i test
  void reset() {
    _lastNotificationTime = null;
  }
}

void main() {
  group('🛡️ Test Anti-Spam e Notifiche', () {
    late NotificationManager notificationManager;

    setUp(() {
      // Inizializza il gestore con un cooldown anti-spam di 2 secondi
      notificationManager = NotificationManager(
        spamCooldown: const Duration(seconds: 2),
      );
    });

    test('La prima notifica deve essere inviata con successo', () {
      final result = notificationManager.sendNotification('Notifica 1');
      expect(result, isTrue);
    });

    test('Notifiche inviate troppo rapidamente devono essere bloccate (Anti-Spam)', () {
      final baseTime = DateTime(2026, 1, 1, 12, 0, 0);

      // 1️⃣ Prima notifica inviata alle 12:00:00
      final firstResult = notificationManager.sendNotification(
        'Notifica 1',
        customNow: baseTime,
      );
      expect(firstResult, isTrue);

      // 2️⃣ Tentativo immediato dopo 500 millisecondi (entro i 2 secondi di cooldown)
      final spamResult = notificationManager.sendNotification(
        'Notifica Spam',
        customNow: baseTime.add(const Duration(milliseconds: 500)),
      );
      expect(spamResult, isFalse, reason: 'Il sistema anti-spam avrebbe dovuto bloccare questa richiesta!');
    });

    test('Notifiche inviate dopo il cooldown devono passare', () {
      final baseTime = DateTime(2026, 1, 1, 12, 0, 0);

      // 1️⃣ Prima notifica alle 12:00:00
      notificationManager.sendNotification('Notifica 1', customNow: baseTime);

      // 2️⃣ Seconda notifica dopo 3 secondi (oltre il cooldown di 2 secondi)
      final validResult = notificationManager.sendNotification(
        'Notifica Valida',
        customNow: baseTime.add(const Duration(seconds: 3)),
      );
      expect(validResult, isTrue, reason: 'Il cooldown è scaduto, la notifica deve passare.');
    });
  });
}