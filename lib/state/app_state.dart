import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/media_service.dart';
import '../services/notification_service.dart';
import '../services/asset_catalog.dart';

enum DayState { active, upcoming, done }

class AppState extends ChangeNotifier {
  final _storage = StorageService();
  final media = MediaService();
  final _notif = NotificationService();

  List<Activity> plan = [];
  AppSettings settings = AppSettings();
  bool loading = true;

  int currentIndex = 0;
  bool isActive = false;
  DayState dayState = DayState.upcoming;
  double progress = 0;
  int remainingMin = 0;
  String? _lastAnnouncedId;
  Timer? _timer;

  Future<void> init() async {
    await AssetCatalog.load();
    plan = await _storage.loadPlan();
    settings = await _storage.loadSettings();
    _sort();
    loading = false;
    _recompute(announce: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _recompute());
    notifyListeners();
    try { await _notif.init(); await _reschedule(); } catch (_) {}
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  double get _nowMin {
    final n = DateTime.now();
    return n.hour * 60 + n.minute + n.second / 60.0;
  }

  void _sort() => plan.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

  void _recompute({bool announce = true}) {
    if (plan.isEmpty) { dayState = DayState.done; isActive = false; notifyListeners(); return; }
    final now = _nowMin;
    int? act;
    for (int i = 0; i < plan.length; i++) {
      final s = plan[i].startMinutes.toDouble();
      if (now >= s && now < s + plan[i].durationMin) { act = i; break; }
    }
    int idx; bool active; DayState ds;
    if (act != null) {
      idx = act; active = true; ds = DayState.active;
      final a = plan[idx];
      progress = ((now - a.startMinutes) / a.durationMin).clamp(0, 1).toDouble();
      remainingMin = (a.durationMin - (now - a.startMinutes)).ceil().clamp(0, 999);
    } else {
      final up = plan.indexWhere((a) => a.startMinutes > now);
      if (up != -1) {
        idx = up; active = false; ds = DayState.upcoming; progress = 0; remainingMin = plan[idx].durationMin;
      } else {
        idx = plan.length - 1; active = false; ds = DayState.done; progress = 0; remainingMin = 0;
      }
    }
    final changed = idx != currentIndex || active != isActive || ds != dayState;
    currentIndex = idx; isActive = active; dayState = ds;
    if (announce && active && plan[idx].id != _lastAnnouncedId) {
      _lastAnnouncedId = plan[idx].id; _onActivityStart(plan[idx]);
    }
    if (changed || active) notifyListeners();
  }

  Future<void> _onActivityStart(Activity a) async {
    if (settings.vibrate) {
      try { if (await Vibration.hasVibrator() ?? false) Vibration.vibrate(duration: 200); } catch (_) {}
    }
    await media.speakActivity(a, settings);
  }

  Activity get current => plan.isEmpty
      ? Activity(id: 'x', label: '–') : plan[currentIndex.clamp(0, plan.length - 1)];

  // Alle noch kommenden Schritte von heute (Startzeit liegt in der Zukunft).
  List<Activity> get upcoming => [for (final a in plan) if (a.startMinutes > _nowMin) a];
  int minutesUntil(Activity a) => (a.startMinutes - _nowMin).ceil();

  Future<void> speakCurrent() => media.speakActivity(current, settings);

  // ---- Zeitlogik: feste Startzeiten, keine Überschneidungen ----
  bool _free(int start, int dur, int ignore) {
    final end = start + dur;
    for (int i = 0; i < plan.length; i++) {
      if (i == ignore) continue;
      final s = plan[i].startMinutes, e = s + plan[i].durationMin;
      if (start < e && s < end) return false;
    }
    return true;
  }

  int _lastEnd() => plan.isEmpty ? 7 * 60
      : plan.map((a) => a.startMinutes + a.durationMin).reduce(max);

  Future<void> _reschedule() async { try { await _notif.scheduleAll(plan); } catch (_) {} }

  void _afterPlanChange() {
    try { media.stop(); } catch (_) {}
    _sort(); _persistPlan(); _recompute(announce: false); notifyListeners(); _reschedule();
  }

  void addFromTemplate(Activity t) {
    final a = t.copy();
    a.id = 'a${DateTime.now().microsecondsSinceEpoch}';
    a.startMinutes = _lastEnd();
    plan.add(a); _afterPlanChange();
  }

  void addCustom(String label, {String? spoken, int durationMin = 10}) {
    final a = Activity(
      id: 'c${DateTime.now().microsecondsSinceEpoch}',
      label: label.trim().isEmpty ? 'Neuer Eintrag' : label.trim(),
      spoken: (spoken == null || spoken.trim().isEmpty)
          ? 'Jetzt ist es Zeit für ${label.trim()}.' : spoken.trim(),
      startMinutes: _lastEnd(), durationMin: durationMin,
    );
    plan.add(a); _afterPlanChange();
  }

  void insertActivity(Activity a) { plan.add(a); _afterPlanChange(); }

  void removeAt(int i) {
    if (i < 0 || i >= plan.length) return;
    plan.removeAt(i);
    if (currentIndex >= plan.length) currentIndex = (plan.length - 1).clamp(0, 999);
    _afterPlanChange();
  }

  /// Setzt die exakte Startzeit. Gibt false zurück, wenn die Zeit belegt ist.
  bool setStart(int i, int minutes) {
    if (!_free(minutes, plan[i].durationMin, i)) return false;
    plan[i].startMinutes = minutes; _afterPlanChange(); return true;
  }

  /// Setzt die Dauer. Gibt false zurück, wenn es zur Überschneidung käme.
  bool setDuration(int i, int minutes) {
    minutes = minutes.clamp(2, 600);
    if (!_free(plan[i].startMinutes, minutes, i)) return false;
    plan[i].durationMin = minutes; _afterPlanChange(); return true;
  }

  void setIcon(int i, String path) { plan[i].iconPath = path; _persistPlan(); notifyListeners(); }
  void setAudio(int i, String path) { plan[i].audioPath = path; _persistPlan(); notifyListeners(); }

  Future<void> _persistPlan() => _storage.savePlan(plan);

  void updateSettings(void Function(AppSettings) f) {
    f(settings); _storage.saveSettings(settings); notifyListeners();
  }
}
