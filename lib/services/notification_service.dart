import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/models.dart';

// "Aufpoppen": plant für die nächsten Tage exakte lokale Benachrichtigungen –
// jeweils mit dem RICHTIGEN Wochentagsplan. Funktioniert auch bei geschlossener
// App und offline (native Android/iOS). Wird bei jedem App-Start und jeder
// Planänderung neu aufgebaut.
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

  /// Plant die nächsten 7 Tage vor – je Datum mit dem passenden Wochentagsplan.
  /// Deckelt die Anzahl (iOS erlaubt max. 64 offene Benachrichtigungen).
  Future<void> scheduleWeek(Map<int, List<Activity>> week) async {
    await init();
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);
    int id = 1000;
    int count = 0;
    const maxNotifs = 60;
    for (int offset = 0; offset < 7 && count < maxNotifs; offset++) {
      final date = now.add(Duration(days: offset));
      final plan = week[date.weekday] ?? const <Activity>[];
      for (final a in plan) {
        if (count >= maxNotifs) break;
        final when = tz.TZDateTime(tz.local, date.year, date.month, date.day,
            a.startMinutes ~/ 60, a.startMinutes % 60);
        if (!when.isAfter(now)) continue;
        final nid = id++;
        try {
          await _plugin.zonedSchedule(nid, 'Jetzt: ${a.label}', 'Tippe, um die App zu öffnen.',
              when, _details,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
          count++;
        } catch (_) {
          try {
            await _plugin.zonedSchedule(nid, 'Jetzt: ${a.label}', 'Tippe, um die App zu öffnen.',
                when, _details,
                androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
                uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
            count++;
          } catch (_) {}
        }
      }
    }
  }

  Future<void> cancelAll() async { await _plugin.cancelAll(); }
}
