import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/default_data.dart';

// Offline-Speicherung über SharedPreferences (funktioniert auf Mobil, Desktop, Web).
class StorageService {
  Future<List<Activity>> loadPlan() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString('plan_v2');
      if (raw == null) return sampleDay();
      final list = (jsonDecode(raw) as List).map((e) => Activity.fromJson(e)).toList();
      return list.isEmpty ? sampleDay() : list;
    } catch (_) {
      return sampleDay();
    }
  }

  Future<void> savePlan(List<Activity> plan) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('plan_v2', jsonEncode(plan.map((e) => e.toJson()).toList()));
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
}
