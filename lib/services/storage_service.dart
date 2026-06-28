import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/default_data.dart';

class StorageService {
  Map<int, List<Activity>> _defaultWeek() => {
        for (int d = 1; d <= 7; d++) d: (d <= 5 ? sampleDay() : sampleWeekend()),
      };

  Future<Map<int, List<Activity>>> loadWeek() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString('week_v1');
      if (raw == null) return _defaultWeek();
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final week = <int, List<Activity>>{};
      for (int d = 1; d <= 7; d++) {
        final list = m['$d'];
        week[d] = (list is List)
            ? list.map((e) => Activity.fromJson(e)).toList()
            : (d <= 5 ? sampleDay() : sampleWeekend());
      }
      return week;
    } catch (_) {
      return _defaultWeek();
    }
  }

  Future<void> saveWeek(Map<int, List<Activity>> week) async {
    final p = await SharedPreferences.getInstance();
    final m = {for (final e in week.entries) '${e.key}': e.value.map((a) => a.toJson()).toList()};
    await p.setString('week_v1', jsonEncode(m));
  }

  Future<AppSettings> loadSettings() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('settings');
    if (raw == null) return AppSettings();
    return AppSettings.fromJson(jsonDecode(raw));
  }

  Future<void> saveSettings(AppSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('settings', jsonEncode(s.toJson()));
  }

  Future<String> loadDoneDate() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('done_date') ?? '';
  }

  Future<Set<String>> loadDoneIds() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('done_ids');
    if (raw == null) return <String>{};
    return Set<String>.from(jsonDecode(raw) as List);
  }

  Future<void> saveDone(String date, Set<String> ids) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('done_date', date);
    await p.setString('done_ids', jsonEncode(ids.toList()));
  }
}
