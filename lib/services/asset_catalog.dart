import 'package:flutter/services.dart';

// Liest beim Start, welche Assets wirklich gebündelt sind. So "docken" deine
// später hinzugefügten Icons/Audios automatisch an – ohne Code-Änderung.
class AssetCatalog {
  static Set<String> _assets = {};
  static bool loaded = false;

  static final RegExp _voiceSuffix = RegExp(r'_de_[fm]\.(mp3|wav|m4a)$');

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
    if (key == null || key.isEmpty) return null;
    final p = 'assets/icons/$key.svg';
    return has(p) ? p : null;
  }

  // Sprachdatei nach Schlüssel + Stimme; fällt auf die andere Stimme zurück.
  static String? audioForKey(String? key, String voice) {
    if (key == null || key.isEmpty) return null;
    for (final v in [voice, voice == 'f' ? 'm' : 'f']) {
      for (final ext in const ['mp3', 'wav', 'm4a']) {
        final p = 'assets/audio/${key}_de_$v.$ext';
        if (has(p)) return p;
      }
    }
    return null;
  }

  /// Alle gebündelten Icons (ohne Platzhalter), alphabetisch.
  static List<String> get icons {
    final l = [
      for (final a in _assets)
        if (a.startsWith('assets/icons/') && a.endsWith('.svg') &&
            !a.endsWith('/placeholder.svg')) a
    ]..sort();
    return l;
  }

  /// Schlüssel aller gebündelten Sprachdateien (ohne _de_f/_de_m), alphabetisch.
  /// Dateien ohne Stimmen-Endung erscheinen mit ihrem vollen Namen.
  static List<String> get audioKeys {
    final keys = <String>{};
    for (final a in _assets) {
      if (!a.startsWith('assets/audio/')) continue;
      final name = a.substring('assets/audio/'.length);
      if (_voiceSuffix.hasMatch(name)) {
        keys.add(name.replaceFirst(_voiceSuffix, ''));
      } else if (RegExp(r'\.(mp3|wav|m4a)$').hasMatch(name)) {
        keys.add(name);
      }
    }
    return keys.toList()..sort();
  }

  /// Schlüssel aus einem Asset-Pfad: assets/audio/adrian_de_f.mp3 -> adrian.
  static String? audioKeyOf(String? assetPath) {
    if (assetPath == null || !assetPath.startsWith('assets/audio/')) return null;
    final name = assetPath.substring('assets/audio/'.length);
    return _voiceSuffix.hasMatch(name) ? name.replaceFirst(_voiceSuffix, '') : name;
  }

  /// Asset-Pfad zu einem Schlüssel aus [audioKeys] – passend zur Stimme.
  static String? audioPathForPickerKey(String key, String voice) =>
      audioForKey(key, voice) ?? (has('assets/audio/$key') ? 'assets/audio/$key' : null);

  /// Zugewiesene Asset-Sprachdatei, aber passend zur gewählten Stimme
  /// (Frau/Mann), falls beide Varianten vorhanden sind.
  static String? voiceAware(String assetPath, String voice) {
    final k = audioKeyOf(assetPath);
    if (k != null && k != assetPath.substring('assets/audio/'.length)) {
      final v = audioForKey(k, voice);
      if (v != null) return v;
    }
    return has(assetPath) ? assetPath : null;
  }
}
