import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/media_service.dart';
import '../services/notification_service.dart';
import '../services/asset_catalog.dart';

class AppState extends ChangeNotifier {
  final _storage = StorageService();
  final media = MediaService();
  final _notif = NotificationService();

  List<Activity> plan = [];
  AppSettings settings = AppSettings();
  bool loading = true;

  int currentIndex = 0;
  bool isActive = false;       // läuft die aktuelle Aktivität GERADE?
  double progress = 0;
  int remainingMin = 0;
  String? _lastAnnouncedId;
  Timer? _timer;

  Future<void> init() async {
    await AssetCatalog.load();
    plan = await _storage.loadPlan();
    settings = await _storage.loadSettings();
    if (plan.isNotEmpty && plan.first.startMinutes == 0) plan.first.startMinutes = 7 * 60;
    rechain(save: false);
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

  void _recompute({bool announce = true}) {
    if (plan.isEmpty) return;
    final now = _nowMin;
    int? activeIdx;
    for (int i = 0; i < plan.length; i++) {
      final s = plan[i].startMinutes.toDouble();
      if (now >= s && now < s + plan[i].durationMin) { activeIdx = i; break; }
    }
    int idx; bool active;
    if (activeIdx != null) {
      idx = activeIdx; active = true;
      final a = plan[idx];
      progress = ((now - a.startMinutes) / a.durationMin).clamp(0, 1).toDouble();
      remainingMin = (a.durationMin - (now - a.startMinutes)).ceil().clamp(0, 999);
    } else {
      // exakte Uhrzeit: nächste Aktivität, die noch kommt – sonst die erste (morgen)
      int up = plan.indexWhere((a) => a.startMinutes > now);
      if (up == -1) up = 0;
      idx = up; active = false; progress = 0; remainingMin = plan[idx].durationMin;
    }
    final changed = idx != currentIndex || active != isActive;
    currentIndex = idx; isActive = active;
    if (announce && active && plan[idx].id != _lastAnnouncedId) {
      _lastAnnouncedId = plan[idx].id;
      _onActivityStart(plan[idx]);
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
  Activity? get next => currentIndex + 1 < plan.length ? plan[currentIndex + 1] : null;

  Future<void> speakCurrent() => media.speakActivity(current, settings);

  // ---- Plan bearbeiten ----
  void rechain({bool save = true}) {
    for (int i = 1; i < plan.length; i++) {
      plan[i].startMinutes = plan[i - 1].startMinutes + plan[i - 1].durationMin;
    }
    if (save) _persistPlan();
  }

  Future<void> _reschedule() async { try { await _notif.scheduleAll(plan); } catch (_) {} }

  void _afterPlanChange() {
    rechain(); _recompute(announce: false); notifyListeners(); _reschedule();
  }

  void setDayStart(int minutes) { if (plan.isEmpty) return; plan.first.startMinutes = minutes; _afterPlanChange(); }

  void addFromTemplate(Activity t) {
    final a = t.copy(); a.id = 'a${DateTime.now().microsecondsSinceEpoch}';
    plan.add(a); _afterPlanChange();
  }

  void addCustom(String label, {String? spoken, int durationMin = 10}) {
    final a = Activity(
      id: 'c${DateTime.now().microsecondsSinceEpoch}',
      label: label.trim().isEmpty ? 'Neuer Eintrag' : label.trim(),
      spoken: (spoken == null || spoken.trim().isEmpty)
          ? 'Jetzt ist es Zeit für ${label.trim()}.' : spoken.trim(),
      durationMin: durationMin,
    );
    plan.add(a); _afterPlanChange();
  }

  void removeAt(int i) {
    plan.removeAt(i);
    if (currentIndex >= plan.length) currentIndex = (plan.length - 1).clamp(0, 999);
    _afterPlanChange();
  }

  void changeDuration(int i, int delta) {
    plan[i].durationMin = (plan[i].durationMin + delta).clamp(2, 240); _afterPlanChange();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    plan.insert(newIndex, plan.removeAt(oldIndex)); _afterPlanChange();
  }

  void setIcon(int i, String path) { plan[i].iconPath = path; _persistPlan(); notifyListeners(); }
  void setAudio(int i, String path) { plan[i].audioPath = path; _persistPlan(); notifyListeners(); }

  Future<void> _persistPlan() => _storage.savePlan(plan);

  void updateSettings(void Function(AppSettings) f) {
    f(settings); _storage.saveSettings(settings); notifyListeners();
  }
}
