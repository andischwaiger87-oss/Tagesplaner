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

  Map<int, List<Activity>> week = {}; // 1=Mo ... 7=So
  AppSettings settings = AppSettings();
  bool loading = true;

  int editingDay = DateTime.now().weekday; // welcher Tag im Editor bearbeitet wird
  int navTab = 0;                          // aktiver Tab (zentral gesteuert)

  int currentIndex = 0;
  bool isActive = false;
  DayState dayState = DayState.upcoming;
  double progress = 0;
  int remainingMin = 0;
  String? _lastAnnouncedId;
  Timer? _timer;

  Future<void> init() async {
    await AssetCatalog.load();
    week = await _storage.loadWeek();
    settings = await _storage.loadSettings();
    for (final l in week.values) { l.sort((a, b) => a.startMinutes.compareTo(b.startMinutes)); }
    loading = false;
    _recompute(announce: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _recompute());
    notifyListeners();
    try { await _notif.init(); await _reschedule(); } catch (_) {}
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  // Heutiger Plan (für „Jetzt") und Plan eines beliebigen Wochentags
  List<Activity> get _today => week[DateTime.now().weekday] ?? const [];
  List<Activity> dayPlan(int weekday) => week[weekday] ?? const [];
  List<Activity> get edit => week[editingDay] ?? const [];
  List<Activity> get plan => edit; // für den Editor

  void goTab(int i) { navTab = i; notifyListeners(); }
  void setEditingDay(int wd) { editingDay = wd; notifyListeners(); }

  double get _nowMin {
    final n = DateTime.now();
    return n.hour * 60 + n.minute + n.second / 60.0;
  }

  void _recompute({bool announce = true}) {
    final p = _today;
    if (p.isEmpty) { dayState = DayState.done; isActive = false; notifyListeners(); return; }
    final now = _nowMin;
    int? act;
    for (int i = 0; i < p.length; i++) {
      final s = p[i].startMinutes.toDouble();
      if (now >= s && now < s + p[i].durationMin) { act = i; break; }
    }
    int idx; bool active; DayState ds;
    if (act != null) {
      idx = act; active = true; ds = DayState.active;
      final a = p[idx];
      progress = ((now - a.startMinutes) / a.durationMin).clamp(0, 1).toDouble();
      remainingMin = (a.durationMin - (now - a.startMinutes)).ceil().clamp(0, 999);
    } else {
      final up = p.indexWhere((a) => a.startMinutes > now);
      if (up != -1) { idx = up; active = false; ds = DayState.upcoming; progress = 0; remainingMin = p[idx].durationMin; }
      else { idx = p.length - 1; active = false; ds = DayState.done; progress = 0; remainingMin = 0; }
    }
    final changed = idx != currentIndex || active != isActive || ds != dayState;
    currentIndex = idx; isActive = active; dayState = ds;
    if (announce && active && p[idx].id != _lastAnnouncedId) { _lastAnnouncedId = p[idx].id; _onActivityStart(p[idx]); }
    if (changed || active) notifyListeners();
  }

  Future<void> _onActivityStart(Activity a) async {
    if (settings.vibrate) {
      try { if (await Vibration.hasVibrator() ?? false) Vibration.vibrate(duration: 200); } catch (_) {}
    }
    await media.speakActivity(a, settings);
  }

  Activity get current {
    final p = _today;
    return p.isEmpty ? Activity(id: 'x', label: '–') : p[currentIndex.clamp(0, p.length - 1)];
  }
  List<Activity> get upcoming => [for (final a in _today) if (a.startMinutes > _nowMin) a];
  int minutesUntil(Activity a) => (a.startMinutes - _nowMin).ceil();
  Future<void> speakCurrent() => media.speakActivity(current, settings);

  // ---- Bearbeiten (immer auf editingDay) ----
  bool _free(List<Activity> list, int start, int dur, int ignore) {
    final end = start + dur;
    for (int i = 0; i < list.length; i++) {
      if (i == ignore) continue;
      final s = list[i].startMinutes, e = s + list[i].durationMin;
      if (start < e && s < end) return false;
    }
    return true;
  }

  int _lastEnd(List<Activity> list) => list.isEmpty ? 7 * 60
      : list.map((a) => a.startMinutes + a.durationMin).reduce(max);

  Future<void> _reschedule() async { try { await _notif.scheduleAll(_today); } catch (_) {} }

  void _afterEdit() {
    try { media.stop(); } catch (_) {}
    edit.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    _storage.saveWeek(week);
    _recompute(announce: false);
    notifyListeners();
    _reschedule();
  }

  void addFromTemplate(Activity t) {
    final list = week[editingDay]!;
    final a = t.copy();
    a.id = 'a${DateTime.now().microsecondsSinceEpoch}';
    a.startMinutes = _lastEnd(list);
    list.add(a); _afterEdit();
  }

  void addCustom(String label, {String? spoken, int durationMin = 10}) {
    final list = week[editingDay]!;
    list.add(Activity(
      id: 'c${DateTime.now().microsecondsSinceEpoch}',
      label: label.trim().isEmpty ? 'Neuer Eintrag' : label.trim(),
      spoken: (spoken == null || spoken.trim().isEmpty) ? 'Jetzt ist es Zeit für ${label.trim()}.' : spoken.trim(),
      startMinutes: _lastEnd(list), durationMin: durationMin,
    ));
    _afterEdit();
  }

  void insertActivity(Activity a) { week[editingDay]!.add(a); _afterEdit(); }

  void removeAt(int i) {
    final list = week[editingDay]!;
    if (i < 0 || i >= list.length) return;
    list.removeAt(i); _afterEdit();
  }

  bool setStart(int i, int minutes) {
    final list = week[editingDay]!;
    if (!_free(list, minutes, list[i].durationMin, i)) return false;
    list[i].startMinutes = minutes; _afterEdit(); return true;
  }

  bool setDuration(int i, int minutes) {
    final list = week[editingDay]!;
    minutes = minutes.clamp(2, 600);
    if (!_free(list, list[i].startMinutes, minutes, i)) return false;
    list[i].durationMin = minutes; _afterEdit(); return true;
  }

  void setIcon(int i, String path) { week[editingDay]![i].iconPath = path; _storage.saveWeek(week); notifyListeners(); }
  void setAudio(int i, String path) { week[editingDay]![i].audioPath = path; _storage.saveWeek(week); notifyListeners(); }

  // Plan des aktuellen Tages auf andere Tage kopieren
  void copyEditTo(List<int> days) {
    final src = edit;
    for (final d in days) {
      if (d == editingDay) continue;
      week[d] = [for (final a in src) a.copy()..id = '${a.id}_$d'];
    }
    _storage.saveWeek(week); _recompute(announce: false); notifyListeners(); _reschedule();
  }

  void updateSettings(void Function(AppSettings) f) {
    f(settings); _storage.saveSettings(settings); notifyListeners();
  }
}
