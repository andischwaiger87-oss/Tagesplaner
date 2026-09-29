import 'package:flutter_test/flutter_test.dart';
import 'package:tagesbegleiter/util/format.dart';
import 'package:tagesbegleiter/models/models.dart';

void main() {
  group('Zeit-Formatierung (nie über 60 Min)', () {
    test('unter 60 Minuten', () {
      expect(fmtDuration(5), '5 Min');
      expect(fmtDuration(45), '45 Min');
    });
    test('60 Minuten und mehr', () {
      expect(fmtDuration(60), '1 Std');
      expect(fmtDuration(89), '1 Std 29 Min');
      expect(fmtDuration(120), '2 Std');
    });
    test('fmtUntil', () {
      expect(fmtUntil(0), 'jetzt');
      expect(fmtUntil(25), 'In 25 Min');
      expect(fmtUntil(89), 'In 1 Std 29 Min');
    });
  });

  test('AppSettings JSON-Roundtrip', () {
    final s = AppSettings(name: 'Max', voice: 'm', themeIndex: 2, fontScale: 1.2, onboardingDone: true);
    final r = AppSettings.fromJson(s.toJson());
    expect(r.name, 'Max');
    expect(r.voice, 'm');
    expect(r.themeIndex, 2);
    expect(r.fontScale, 1.2);
    expect(r.onboardingDone, true);
  });

  test('Activity JSON-Roundtrip + timeLabel', () {
    final a = Activity(id: 'x', key: 'fruehstueck', label: 'Frühstück',
        spoken: 'Jetzt ist Frühstück.', startMinutes: 480, durationMin: 20);
    final r = Activity.fromJson(a.toJson());
    expect(r.key, 'fruehstueck');
    expect(r.startMinutes, 480);
    expect(r.durationMin, 20);
    expect(r.timeLabel, '8:00');
  });

  test('Diskretionsmodus: Roundtrip + alte Einstellungen bleiben erhalten', () {
    final s = AppSettings(name: 'Andi', discreet: true);
    expect(AppSettings.fromJson(s.toJson()).discreet, true);
    // Gespeicherte Einstellungen aus älteren Versionen (ohne das neue Feld)
    final old = {'name': 'Andi', 'voice': 'm', 'themeIndex': 3, 'minimalUI': true};
    final r = AppSettings.fromJson(old);
    expect(r.discreet, false);
    expect(r.name, 'Andi');
    expect(r.voice, 'm');
    expect(r.themeIndex, 3);
    expect(r.minimalUI, true);
  });

  test('Automatische Zuordnung eigener Einträge über den Namen', () {
    expect(slugify('Adrian abholen'), 'adrian_abholen');
    expect(slugify('Zähne putzen'), 'zaehne_putzen');
    expect(slugify('  Große Pause! '), 'grosse_pause');
    expect(Activity(id: 'c1', label: 'Adrian abholen').lookupKey, 'adrian_abholen');
    expect(Activity(id: 'x', key: 'kochen', label: 'Mein Kochen').lookupKey, 'kochen');
  });

  test('Personengruppe, Notfall & Sperre: Standardwerte für alte Einstellungen', () {
    final r = AppSettings.fromJson({'name': 'Andi', 'discreet': true});
    expect(r.profile, 'allgemein');
    expect(r.pin, '');
    expect(r.showHelpButton, false);
    expect(r.discreet, true);
    final d = AppSettings(profile: 'demenz', emergencyPhone: '+43 664 123');
    expect(AppSettings.fromJson(d.toJson()).showHelpButton, true);
    expect(AppSettings(profile: 'allgemein', emergencyPhone: '123').showHelpButton, false);
  });

  test('Medikamente werden nachgefragt', () {
    expect(Activity(id: 'a', key: 'medikament', label: 'Medikament').needsFollowUp, true);
    expect(Activity(id: 'b', label: 'Tablette Abend').needsFollowUp, true);
    expect(Activity(id: 'c', key: 'kochen', label: 'Kochen').needsFollowUp, false);
  });

  test('Mehrere Medikamente pro Schritt: Speichern & alte Pläne', () {
    final a = Activity(id: 'm1', key: 'medikament', label: 'Medikament', startMinutes: 480,
        meds: ['Ramipril 5 mg', 'ASS 100']);
    final r = Activity.fromJson(a.toJson());
    expect(r.meds, ['Ramipril 5 mg', 'ASS 100']);
    expect(r.needsFollowUp, true);
    // alter Plan ohne Feld "meds"
    final old = Activity.fromJson({'id': 'x', 'label': 'Kochen', 'startMinutes': 600, 'durationMin': 30});
    expect(old.meds, isEmpty);
    expect(old.toJson().containsKey('meds'), false);
    expect(medReminderTitle(a, ['ASS 100']), 'Noch offen: ASS 100');
    expect(medReminderTitle(Activity(id: 'y', label: 'Medikament')), 'Schon erledigt? Medikament');
  });
}
