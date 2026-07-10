// Datenmodelle für Tagesbegleiter.

class Activity {
  String id;
  String? key;           // stabiler Schlüssel (für assets/icons/{key}.svg & assets/audio/{key}_de_x.mp3)
  String label;          // klarer Text, z. B. "Zähne putzen"
  String? spoken;        // fester gesprochener Satz (für Audio/TTS), z. B. "Jetzt ist es Zeit zum Zähneputzen."
  String? iconPath;      // optionaler eigener Icon-Pfad (Asset ODER Datei) – überschreibt key
  String? audioPath;     // optionaler eigener Audio-Pfad (Asset ODER Datei) – überschreibt key
  int startMinutes;      // Beginn als Minuten seit Mitternacht (7:30 = 450)
  int durationMin;       // Dauer in Minuten

  Activity({
    required this.id,
    this.key,
    required this.label,
    this.spoken,
    this.iconPath,
    this.audioPath,
    this.startMinutes = 0,
    this.durationMin = 10,
  });

  bool get iconIsAsset => iconPath != null && iconPath!.startsWith('assets/');
  bool get audioIsAsset => audioPath != null && audioPath!.startsWith('assets/');

  String get timeLabel {
    final h = startMinutes ~/ 60;
    final m = startMinutes % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'key': key, 'label': label, 'spoken': spoken,
        'iconPath': iconPath, 'audioPath': audioPath,
        'startMinutes': startMinutes, 'durationMin': durationMin,
      };

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
        id: j['id'],
        key: j['key'],
        label: j['label'],
        spoken: j['spoken'],
        iconPath: j['iconPath'],
        audioPath: j['audioPath'],
        startMinutes: j['startMinutes'] ?? 0,
        durationMin: j['durationMin'] ?? 10,
      );

  Activity copy() => Activity.fromJson(toJson());
}

class AppSettings {
  String name;
  String voice;      // 'f' oder 'm'
  bool highContrast;
  double fontScale;
  bool reduceMotion;
  bool showNext;
  bool showClock;
  bool vibrate;
  double volume;
  int themeIndex;
  String? avatarUser;
  String? avatarF;
  String? avatarM;
  bool onboardingDone;

  AppSettings({
    this.name = '', this.voice = 'f', this.highContrast = false,
    this.fontScale = 1.0, this.reduceMotion = false, this.showNext = true,
    this.showClock = true, this.vibrate = true, this.volume = 1.0, this.themeIndex = 0,
    this.avatarUser, this.avatarF, this.avatarM,
    this.onboardingDone = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name, 'voice': voice, 'highContrast': highContrast,
        'fontScale': fontScale, 'reduceMotion': reduceMotion, 'showNext': showNext,
        'showClock': showClock, 'vibrate': vibrate, 'volume': volume, 'themeIndex': themeIndex,
        'avatarUser': avatarUser, 'avatarF': avatarF, 'avatarM': avatarM,
        'onboardingDone': onboardingDone,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        name: j['name'] ?? '', voice: j['voice'] ?? 'f',
        highContrast: j['highContrast'] ?? false,
        fontScale: (j['fontScale'] ?? 1.0).toDouble(),
        reduceMotion: j['reduceMotion'] ?? false, showNext: j['showNext'] ?? true,
        showClock: j['showClock'] ?? true, vibrate: j['vibrate'] ?? true,
        volume: (j['volume'] ?? 1.0).toDouble(), themeIndex: j['themeIndex'] ?? 0,
        avatarUser: j['avatarUser'], avatarF: j['avatarF'], avatarM: j['avatarM'],
        onboardingDone: j['onboardingDone'] ?? false,
      );
}
