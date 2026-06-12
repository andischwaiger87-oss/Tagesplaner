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
    // 1) Eigene zugewiesene Audiodatei
    if (a.audioPath != null && a.audioPath!.isNotEmpty) {
      try {
        if (a.audioIsAsset) {
          await _player.play(AssetSource(a.audioPath!.replaceFirst('assets/', '')), volume: s.volume);
        } else {
          await _player.play(DeviceFileSource(a.audioPath!), volume: s.volume);
        }
        return;
      } catch (_) {}
    }
    // 2) Audio über den Schlüssel (assets/audio/{key}_de_{voice}.mp3)
    final byKey = AssetCatalog.audioForKey(a.key, s.voice);
    if (byKey != null) {
      try {
        await _player.play(AssetSource(byKey.replaceFirst('assets/', '')), volume: s.volume);
        return;
      } catch (_) {}
    }
    // 3) Rückfall: geräteeigene Stimme mit dem festen Satz
    if (!_ttsReady) await _initTts(s.voice, s.volume);
    await _tts.setVolume(s.volume);
    final text = (a.spoken != null && a.spoken!.isNotEmpty)
        ? a.spoken!
        : '${s.name}, jetzt ist Zeit für ${a.label}.';
    await _tts.speak(text);
  }

  Future<void> stop() async {
    try { await _player.stop(); } catch (_) {}
    try { await _tts.stop(); } catch (_) {}
  }
}
