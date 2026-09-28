import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/models.dart';
import 'asset_catalog.dart';

class MediaService {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  Future<void> _initTts(String voice, double volume) async {
    await _tts.setLanguage('de-DE');
    await _tts.setVolume(volume);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(voice == 'm' ? 0.9 : 1.05);
    _ttsReady = true;
  }

  Future<void> speakActivity(Activity a, AppSettings s) async {
    await stop();
    // 1) Eigene zugewiesene Datei vom Gerät
    if (a.audioPath != null && a.audioPath!.isNotEmpty && !a.audioIsAsset) {
      try { await _player.play(DeviceFileSource(a.audioPath!), volume: s.volume); return; } catch (_) {}
    }
    // 2) Zugewiesene Sprachdatei aus assets/audio (passend zur Stimme)
    //    3) sonst automatisch über den Schlüssel bzw. den Namen des Eintrags
    final assetPath = (a.audioIsAsset ? AssetCatalog.voiceAware(a.audioPath!, s.voice) : null)
        ?? AssetCatalog.audioForKey(a.lookupKey, s.voice);
    if (assetPath != null) {
      if (await playAsset(assetPath, s.volume)) return;
    }
    // 4) Rückfall: geräteeigene Stimme (im Web bewusst KEINE Roboterstimme)
    if (kIsWeb) return;
    if (!_ttsReady) await _initTts(s.voice, s.volume);
    await _tts.setVolume(s.volume);
    await _tts.setPitch(s.voice == 'm' ? 0.9 : 1.05);
    final text = (a.spoken != null && a.spoken!.isNotEmpty)
        ? a.spoken! : 'Jetzt ist es Zeit für ${a.label}.';
    await _tts.speak(text);
  }

  /// Spielt eine gebündelte Sprachdatei ab (als Bytes, web-sicher).
  Future<bool> playAsset(String assetPath, double volume) async {
    try {
      await stop();
      final data = await rootBundle.load(assetPath);
      await _player.play(BytesSource(data.buffer.asUint8List()), volume: volume);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try { await _player.stop(); } catch (_) {}
    try { await _tts.stop(); } catch (_) {}
  }
}
