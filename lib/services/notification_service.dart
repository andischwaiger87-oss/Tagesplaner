import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/models.dart';

// "Aufpoppen": plant zu jeder Startzeit eine exakte, täglich wiederkehrende
// lokale Benachrichtigung – funktioniert auch bei geschlossener App, offline.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try { tz.setLocalLocation(tz.getLocation('Europe/Vienna')); } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    await requestPermissions();
    _ready = true;
  }

  Future<void> requestPermissions() async {
    final a = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await a?.requestNotificationsPermission();
    try { await a?.requestExactAlarmsPermission(); } catch (_) {}
    final i = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await i?.requestPermissions(alert: true, badge: true, sound: true);
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails('jetzt', 'Aktuelle Aktivität',
            channelDescription: 'Meldet, wenn ein neuer Schritt beginnt',
            importance: Importance.max, priority: Priority.high,
            fullScreenIntent: true, category: AndroidNotificationCategory.alarm),
        iOS: DarwinNotificationDetails(interruptionLevel: InterruptionLevel.timeSensitive),
      );

  Future<void> showNow(String title, String body) async {
    await init();
    await _plugin.show(0, title, body, _details);
  }

  // Für jeden Schritt eine täglich wiederkehrende Benachrichtigung zur Startzeit.
  Future<void> scheduleAll(List<Activity> plan) async {
    await init();
    await _plugin.cancelAll();
    for (int i = 0; i < plan.length; i++) {
      final a = plan[i];
      final when = _nextInstanceOf(a.startMinutes ~/ 60, a.startMinutes % 60);
      try {
        await _plugin.zonedSchedule(100 + i, 'Jetzt: ${a.label}',
            'Tippe, um die App zu öffnen.', when, _details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time);
      } catch (_) {
        try {
          await _plugin.zonedSchedule(100 + i, 'Jetzt: ${a.label}',
              'Tippe, um die App zu öffnen.', when, _details,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.time);
        } catch (_) {}
      }
    }
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var d = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (d.isBefore(now)) d = d.add(const Duration(days: 1));
    return d;
  }

  Future<void> cancelAll() async { await _plugin.cancelAll(); }
}
