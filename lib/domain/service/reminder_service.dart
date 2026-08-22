// lib/domain/service/reminder_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class ReminderService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  ReminderService(this._notificationsPlugin) {
    // Inizializza il database dei fusi orari
    tz_data.initializeTimeZones();
  }

  /// Programma un promemoria per una missione
  Future<void> scheduleMissionReminder({
    required int missionId,
    required String missionTitle,
    required int delayMinutes,
  }) async {
    if (delayMinutes <= 0) return;

    // Converte DateTime in TZDateTime
    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(minutes: delayMinutes));

    await _notificationsPlugin.zonedSchedule(
      missionId,
      'Quester - Promemoria',
      'Hai una missione da completare: $missionTitle',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mission_reminder_channel',
          'Promemoria Missioni',
          channelDescription: 'Notifiche per ricordare le missioni in scadenza',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancella un promemoria
  Future<void> cancelMissionReminder(int missionId) async {
    await _notificationsPlugin.cancel(missionId);
  }
}