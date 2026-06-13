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
    // 1) Eigene zugewiesene Datei (nur Gerätedatei)
    if (a.audioPath != null && a.audioPath!.isNotEmpty && !a.audioIsAsset) {
      try { await _player.play(DeviceFileSource(a.audioPath!), volume: s.volume); return; } catch (_) {}
    }
    // 2) Sprachdatei über den Schlüssel (Frau = de_f, Mann = de_m) – als Bytes, web-sicher
    final assetPath = AssetCatalog.audioForKey(a.key, s.voice)
        ?? (a.audioIsAsset ? a.audioPath : null);
    if (assetPath != null) {
      try {
        final data = await rootBundle.load(assetPath);
        await _player.play(BytesSource(data.buffer.asUint8List()), volume: s.volume);
        return;
      } catch (_) {}
    }
    // 3) Rückfall: geräteeigene Stimme
    if (!_ttsReady) await _initTts(s.voice, s.volume);
    await _tts.setVolume(s.volume);
    await _tts.setPitch(s.voice == 'm' ? 0.9 : 1.05);
    final text = (a.spoken != null && a.spoken!.isNotEmpty)
        ? a.spoken! : 'Jetzt ist es Zeit für ${a.label}.';
    await _tts.speak(text);
  }

  Future<void> stop() async {
    try { await _player.stop(); } catch (_) {}
    try { await _tts.stop(); } catch (_) {}
  }
}
