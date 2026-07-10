import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/models.dart';
import 'web_notify.dart' as webn;

// Erinnerungen:
//  - Native App: exakte, geplante lokale Benachrichtigungen (auch bei geschlossener App).
//  - Web: echte Browser-Benachrichtigungen, solange die App geöffnet/installiert ist.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  bool get supported => kIsWeb ? webn.webNotificationsSupported : true;
  bool get granted => kIsWeb ? webn.webNotificationPermission == 'granted' : true;
  bool get canInstallApp => kIsWeb && webn.pwaCanInstall;
  void installApp() => webn.pwaInstall();

  Future<void> init() async {
    if (_ready) return;
    if (kIsWeb) { _ready = true; return; } // Web nutzt die Browser-Schnittstelle
    tzdata.initializeTimeZones();
    try { tz.setLocalLocation(tz.getLocation('Europe/Vienna')); } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    await requestPermissions();
    _ready = true;
  }

  /// Fragt die Erlaubnis an. Gibt zurück, ob Erinnerungen jetzt erlaubt sind.
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      final p = await webn.requestWebNotificationPermission();
      return p == 'granted';
    }
    final a = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ok = await a?.requestNotificationsPermission();
    try { await a?.requestExactAlarmsPermission(); } catch (_) {}
    final i = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final iosOk = await i?.requestPermissions(alert: true, badge: true, sound: true);
    return (ok ?? iosOk ?? true);
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails('jetzt', 'Aktuelle Aktivität',
            channelDescription: 'Meldet, wenn ein neuer Schritt beginnt',
            importance: Importance.max, priority: Priority.high,
            fullScreenIntent: true, category: AndroidNotificationCategory.alarm),
        iOS: DarwinNotificationDetails(interruptionLevel: InterruptionLevel.timeSensitive),
      );

  /// Zeigt sofort eine Benachrichtigung. Gibt zurück, ob es geklappt hat.
  Future<bool> showNow(String title, String body) async {
    if (kIsWeb) return webn.showWebNotification(title, body);
    await init();
    await _plugin.show(0, title, body, _details);
    return true;
  }

  /// Plant die nächsten 7 Tage vor – je Datum mit dem passenden Wochentagsplan.
  /// Deckelt die Anzahl (iOS erlaubt max. 64 offene Benachrichtigungen).
  Future<void> scheduleWeek(Map<int, List<Activity>> week) async {
    if (kIsWeb) return; // Browser kann keine Termine im Voraus planen
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

  Future<void> cancelAll() async { if (!kIsWeb) await _plugin.cancelAll(); }

  // ---------- Diagnose ----------

  /// Zeigt Android an, dass Benachrichtigungen für die App erlaubt sind?
  Future<bool?> notificationsEnabled() async {
    if (kIsWeb) return granted;
    await init();
    final a = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    try { return await a?.areNotificationsEnabled(); } catch (_) { return null; }
  }

  /// Darf die App exakte Alarme stellen? (Ohne das kommen Meldungen verspätet.)
  Future<bool?> exactAlarmsAllowed() async {
    if (kIsWeb) return null;
    await init();
    final a = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    try { return await a?.canScheduleExactNotifications(); } catch (_) { return null; }
  }

  /// Wie viele Erinnerungen sind aktuell beim System hinterlegt?
  Future<int> pendingCount() async {
    if (kIsWeb) return 0;
    await init();
    try { return (await _plugin.pendingNotificationRequests()).length; } catch (_) { return 0; }
  }

  /// Wann kommt die nächste hinterlegte Erinnerung? (nur zur Anzeige)
  DateTime? lastScheduledFirst;

  /// Echter Hintergrund-Test: plant eine Meldung in [seconds] Sekunden.
  /// Der Bildschirm darf danach ausgehen – genau das wird geprüft.
  Future<String> scheduleSelfTest({int seconds = 60}) async {
    if (kIsWeb) return 'Im Browser nicht möglich – bitte die Android-App verwenden.';
    await init();
    final when = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
    try {
      await _plugin.zonedSchedule(999, 'Test-Erinnerung',
          'Wenn du das siehst, funktionieren die Erinnerungen.', when, _details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
      return 'OK-EXAKT';
    } catch (e) {
      try {
        await _plugin.zonedSchedule(999, 'Test-Erinnerung',
            'Wenn du das siehst, funktionieren die Erinnerungen.', when, _details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
        return 'OK-UNGEFÄHR';
      } catch (e2) {
        return 'FEHLER: $e2';
      }
    }
  }
}
