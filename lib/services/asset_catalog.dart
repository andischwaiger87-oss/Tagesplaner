import 'package:flutter/services.dart';

// Liest beim Start, welche Assets wirklich gebündelt sind. So "docken" deine
// später hinzugefügten Icons/Audios automatisch an – ohne Code-Änderung.
class AssetCatalog {
  static Set<String> _assets = {};
  static bool loaded = false;

  static Future<void> load() async {
    try {
      final m = await AssetManifest.loadFromAssetBundle(rootBundle);
      _assets = m.listAssets().toSet();
    } catch (_) {
      _assets = {};
    }
    loaded = true;
  }

  static bool has(String assetPath) => _assets.contains(assetPath);

  static String? iconForKey(String? key) {
    if (key == null) return null;
    final p = 'assets/icons/$key.svg';
    return has(p) ? p : null;
  }

  // Sprachdatei nach Schlüssel + Stimme; fällt auf die andere Stimme zurück.
  static String? audioForKey(String? key, String voice) {
    if (key == null) return null;
    for (final v in [voice, voice == 'f' ? 'm' : 'f']) {
      final p = 'assets/audio/${key}_de_$v.mp3';
      if (has(p)) return p;
    }
    return null;
  }
}
