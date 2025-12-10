// lib/core/services/notification_service.dart

import 'dart:io'; // Importation nécessaire pour vérifier la plateforme
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('ic_notification');
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {},
    );
    const LinuxInitializationSettings linuxSettings = LinuxInitializationSettings(defaultActionName: 'Ouvrir');

    final InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings, linux: linuxSettings);

    await _notificationsPlugin.initialize(settings);

    // Demande de permissions seulement sur les plateformes qui en ont besoin
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // === CORRECTION : DÉGRADATION GRACIEUSE ===
    // On vérifie si la plateforme supporte les notifications programmées (zonedSchedule).
    // Actuellement, c'est le cas pour Android et iOS, mais pas pour Linux.
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _notificationsPlugin.zonedSchedule(
        id, title, body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails('your_channel_id', 'Your Channel Name', channelDescription: 'Description of your channel', importance: Importance.max, priority: Priority.high),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
    // Si ce n'est pas Android ou iOS, la méthode ne fait rien et ne plantera pas.
  }

  Future<void> cancelNotification(int id) async {
     if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _notificationsPlugin.cancel(id);
    }
  }
}
