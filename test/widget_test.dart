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
}
