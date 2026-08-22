// lib/utils/notification_helper.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Helper per la gestione delle notifiche.
/// Equivalente a NotificationHelper in Kotlin.
class NotificationHelper {
  NotificationHelper._(); // Costruttore privato

  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /// Verifica se le notifiche sono abilitate
  static Future<bool> areNotificationsEnabled() async {
    // In Flutter, il permesso per le notifiche su Android 13+
    // va richiesto tramite il plugin delle notifiche
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      return await androidImpl.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  /// Richiede il permesso per le notifiche (Android 13+)
  static Future<bool> requestNotificationPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      return await androidImpl.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  /// Verifica se il permesso è concesso
  static Future<bool> isNotificationPermissionGranted() async {
    return await areNotificationsEnabled();
  }
}