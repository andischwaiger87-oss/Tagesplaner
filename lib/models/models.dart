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

  /// Schlüssel für die automatische Zuordnung von Icon & Sprachdatei.
  /// Bausteine haben einen festen [key]; eigene Einträge leiten ihn aus dem
  /// Namen ab („Adrian abholen" -> adrian_abholen).
  String get lookupKey => key ?? slugify(label);

  /// Medikamente & Co.: Die App fragt nach, ob es erledigt wurde.
  bool get needsFollowUp {
    if (kFollowUpKeys.contains(lookupKey)) return true;
    final l = label.toLowerCase();
    return l.contains('medikament') || l.contains('tablette') || l.contains('insulin');
  }

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

/// Macht aus einem Namen einen Dateinamen-Schlüssel:
/// „Adrian abholen" -> adrian_abholen, „Zähne putzen" -> zaehne_putzen.
String slugify(String s) {
  var t = s.trim().toLowerCase()
      .replaceAll('ä', 'ae').replaceAll('ö', 'oe').replaceAll('ü', 'ue').replaceAll('ß', 'ss');
  t = t.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  t = t.replaceAll(RegExp(r'^_+|_+$'), '');
  return t;
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
  bool minimalUI;
  String fontFamily;
  bool discreet;     // Diskretionsmodus: keine automatische Sprachausgabe, leise Erinnerungen
  String profile;    // Personengruppe: allgemein | kognitiv | autismus | demenz
  String emergencyName;  // Notfall: Kontaktperson
  String emergencyPhone; // Notfall: Telefonnummer
  String emergencyInfo;  // Notfallpass: Adresse, Medikamente, Allergien …
  String pin;        // Sperre für Bearbeiten & Einstellungen ('' = keine)

  AppSettings({
    this.name = '', this.voice = 'f', this.highContrast = false,
    this.fontScale = 1.0, this.reduceMotion = false, this.showNext = true,
    this.showClock = true, this.vibrate = true, this.volume = 1.0, this.themeIndex = 0,
    this.avatarUser, this.avatarF, this.avatarM,
    this.onboardingDone = false,
    this.minimalUI = false,
    this.fontFamily = 'Lexend',
    this.discreet = false,
    this.profile = 'allgemein',
    this.emergencyName = '', this.emergencyPhone = '', this.emergencyInfo = '',
    this.pin = '',
  });

  /// Personengruppe mit angepasster Oberfläche (Hilfe-Knopf, Nachtansicht …)
  bool get supported => profile != 'allgemein';
  bool get hasEmergency => emergencyPhone.trim().isNotEmpty;
  /// Hilfe-Knopf nur bei gewählter Personengruppe und eingetragener Nummer.
  bool get showHelpButton => supported && hasEmergency;

  Map<String, dynamic> toJson() => {
        'name': name, 'voice': voice, 'highContrast': highContrast,
        'fontScale': fontScale, 'reduceMotion': reduceMotion, 'showNext': showNext,
        'showClock': showClock, 'vibrate': vibrate, 'volume': volume, 'themeIndex': themeIndex,
        'avatarUser': avatarUser, 'avatarF': avatarF, 'avatarM': avatarM,
        'onboardingDone': onboardingDone,
        'minimalUI': minimalUI,
        'fontFamily': fontFamily,
        'discreet': discreet,
        'profile': profile,
        'emergencyName': emergencyName, 'emergencyPhone': emergencyPhone,
        'emergencyInfo': emergencyInfo,
        'pin': pin,
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
        minimalUI: j['minimalUI'] ?? false,
        fontFamily: j['fontFamily'] ?? 'Lexend',
        discreet: j['discreet'] ?? false,
        profile: j['profile'] ?? 'allgemein',
        emergencyName: j['emergencyName'] ?? '',
        emergencyPhone: j['emergencyPhone'] ?? '',
        emergencyInfo: j['emergencyInfo'] ?? '',
        pin: j['pin'] ?? '',
      );
}

/// Personengruppen – bestimmen, welche Hilfen die Oberfläche zusätzlich zeigt.
const Map<String, String> kProfiles = {
  'allgemein': 'Allgemein',
  'kognitiv': 'Kognitive Beeinträchtigung',
  'autismus': 'Autismus',
  'demenz': 'Demenz',
};

/// Bausteine, bei denen die App nachfragt, ob sie erledigt wurden.
const Set<String> kFollowUpKeys = {'medikament', 'tropfen', 'insulin'};
