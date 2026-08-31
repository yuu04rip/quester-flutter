// lib/domain/service/reminder_service.dart

import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class ReminderService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  ReminderService(this._notificationsPlugin);

  /// Inizializza i canali di notifica (da chiamare all'avvio)
  Future<void> init() async {
    tz_data.initializeTimeZones();
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) return;

    const reminderChannel = AndroidNotificationChannel(
      'mission_reminder_channel',
      'Promemoria Missioni',
      description: 'Notifiche per ricordare le missioni in scadenza',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const securityChannel = AndroidNotificationChannel(
      'quester_security_channel',
      'Quester Notifiche Eroe',
      description: 'Notifiche di completamento e avanzamento',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await androidImplementation.createNotificationChannel(reminderChannel);
    await androidImplementation.createNotificationChannel(securityChannel);
  }

  /// Programma un promemoria differito per una missione
  Future<void> scheduleMissionReminder({
    required int missionId,
    required String missionTitle,
    required int delayMinutes,
  }) async {
    if (delayMinutes <= 0) return;

    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(minutes: delayMinutes));

    const androidDetails = AndroidNotificationDetails(
      'mission_reminder_channel',
      'Promemoria Missioni',
      channelDescription: 'Notifiche per ricordare le missioni in scadenza',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    await _notificationsPlugin.zonedSchedule(
      missionId,
      'Quester - Promemoria',
      'Hai una missione da completare: $missionTitle',
      scheduledDate,
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancella un promemoria programmato
  Future<void> cancelMissionReminder(int missionId) async {
    await _notificationsPlugin.cancel(missionId);
  }

  /// Invia una notifica immediata di missione completata (ricompense incluse)
  Future<void> sendMissionCompletionNotification({
    required int missionId,
    required String missionTitle,
    required int xpGained,
    required int coinsGained,
    required int playerLevel,
  }) async {
    final message = 'XP: +$xpGained | Monete: +$coinsGained\nLivello Eroe: $playerLevel\nGloria eterna!';

    final androidDetails = AndroidNotificationDetails(
      'quester_security_channel',
      'Quester Notifiche Eroe',
      channelDescription: 'Notifiche di completamento e avanzamento',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      styleInformation: BigTextStyleInformation(
        message,
        contentTitle: 'Missione Completata: $missionTitle',
        summaryText: 'Ricompense riscosse',
      ),
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      3000 + missionId, // ID univoco per il completamento
      'Missione Completata',
      message,
      notificationDetails,
    );
  }
}