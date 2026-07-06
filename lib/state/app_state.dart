import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/media_service.dart';
import '../services/notification_service.dart';
import '../services/asset_catalog.dart';
import '../data/default_data.dart';

enum DayState { active, upcoming, done }

class AppState extends ChangeNotifier {
  final _storage = StorageService();
  final media = MediaService();
  final _notif = NotificationService();

  Map<int, List<Activity>> week = {}; // 1=Mo ... 7=So
  AppSettings settings = AppSettings();
  bool loading = true;

  int editingDay = DateTime.now().weekday; // welcher Tag im Editor bearbeitet wird
  int navTab = 0;
  Set<String> _done = {};
  String _doneDate = '';                          // aktiver Tab (zentral gesteuert)

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
    _doneDate = await _storage.loadDoneDate();
    _done = await _storage.loadDoneIds();
    _ensureDoneDate();
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

  String _todayKey() { final n = DateTime.now(); return '${n.year}-${n.month}-${n.day}'; }
  void _ensureDoneDate() { final k = _todayKey(); if (_doneDate != k) { _doneDate = k; _done = {}; _storage.saveDone(_doneDate, _done); } }
  bool isDone(String id) => _done.contains(id);
  int get doneCount { _ensureDoneDate(); return _today.where((a) => _done.contains(a.id)).length; }
  int get totalToday => _today.length;
  void toggleDone(String id) { _ensureDoneDate(); if (_done.contains(id)) { _done.remove(id); } else { _done.add(id); } _storage.saveDone(_doneDate, _done); notifyListeners(); }

  void _recompute({bool announce = true}) {
    _ensureDoneDate();
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

  bool addFromTemplate(Activity t) {
    final list = week[editingDay]!;
    final start = _lastEnd(list);
    if (start + t.durationMin > 1440) return false; // passt nicht mehr in den Tag
    final a = t.copy();
    a.id = 'a${DateTime.now().microsecondsSinceEpoch}';
    a.startMinutes = start;
    list.add(a); _afterEdit(); return true;
  }

  bool addCustom(String label, {String? spoken, int durationMin = 10}) {
    final list = week[editingDay]!;
    final start = _lastEnd(list);
    if (start + durationMin > 1440) return false;
    list.add(Activity(
      id: 'c${DateTime.now().microsecondsSinceEpoch}',
      label: label.trim().isEmpty ? 'Neuer Eintrag' : label.trim(),
      spoken: (spoken == null || spoken.trim().isEmpty) ? 'Jetzt ist es Zeit für ${label.trim()}.' : spoken.trim(),
      startMinutes: start, durationMin: durationMin,
    ));
    _afterEdit(); return true;
  }

  void insertActivity(Activity a) { week[editingDay]!.add(a); _afterEdit(); }

  void removeAt(int i) {
    final list = week[editingDay]!;
    if (i < 0 || i >= list.length) return;
    list.removeAt(i); _afterEdit();
  }

  bool setStart(int i, int minutes) {
    final list = week[editingDay]!;
    if (minutes + list[i].durationMin > 1440) return false; // Ende nach 24:00
    if (!_free(list, minutes, list[i].durationMin, i)) return false;
    list[i].startMinutes = minutes; _afterEdit(); return true;
  }

  bool setDuration(int i, int minutes) {
    final list = week[editingDay]!;
    minutes = minutes.clamp(2, 600);
    if (list[i].startMinutes + minutes > 1440) return false; // reicht über den Tag hinaus
    if (!_free(list, list[i].startMinutes, minutes, i)) return false;
    list[i].durationMin = minutes; _afterEdit(); return true;
  }

  // Per Drag & Drop sortieren: Reihenfolge ändern und Uhrzeiten neu verketten
  bool reorderChain(int oldIndex, int newIndex) {
    final list = week[editingDay]!;
    if (oldIndex < 0 || oldIndex >= list.length) return false;
    final snapOrder = List<Activity>.from(list);
    final snapStarts = [for (final a in list) a.startMinutes];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex.clamp(0, list.length), item);
    for (int i = 1; i < list.length; i++) {
      list[i].startMinutes = list[i - 1].startMinutes + list[i - 1].durationMin;
    }
    // Läuft der Plan über Mitternacht? Dann Änderung zurücknehmen.
    if (list.isNotEmpty && list.last.startMinutes + list.last.durationMin > 1440) {
      list..clear()..addAll(snapOrder);
      for (int i = 0; i < list.length; i++) list[i].startMinutes = snapStarts[i];
      return false;
    }
    try { media.stop(); } catch (_) {}
    _storage.saveWeek(week);
    _recompute(announce: false);
    notifyListeners();
    _reschedule();
    return true;
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

  void resetWeek() {
    week = {for (int d = 1; d <= 7; d++) d: (d <= 5 ? sampleDay() : sampleWeekend())};
    editingDay = DateTime.now().weekday;
    _storage.saveWeek(week); _recompute(announce: false); notifyListeners(); _reschedule();
  }

  void updateSettings(void Function(AppSettings) f) {
    f(settings); _storage.saveSettings(settings); notifyListeners();
  }
}
