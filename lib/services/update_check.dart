import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';

/// Build-Nummer dieser App (wird beim Bauen gesetzt: --dart-define=BUILD_NUMBER=...)
const int kBuildNumber = int.fromEnvironment('BUILD_NUMBER', defaultValue: 0);

/// Holt die Build-Nummer der neuesten veröffentlichten Version. null = unbekannt.
Future<int?> fetchLatestBuild() async {
  if (kIsWeb) return null; // Web aktualisiert sich selbst
  try {
    final r = await http
        .get(Uri.parse(kVersionJsonUrl))
        .timeout(const Duration(seconds: 6));
    if (r.statusCode != 200) return null;
    final m = jsonDecode(r.body) as Map<String, dynamic>;
    final b = m['build'];
    return b is int ? b : int.tryParse('$b');
  } catch (_) {
    return null;
  }
}

Future<void> openExternal(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
}
