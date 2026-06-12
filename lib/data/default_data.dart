import '../models/models.dart';

class ModuleCategory {
  final String name;
  final List<Activity> items;
  const ModuleCategory(this.name, this.items);
}

Activity _t(String key, String label, String spoken, int dur) =>
    Activity(id: 'lib_$key', key: key, label: label, spoken: spoken, durationMin: dur);

List<ModuleCategory> moduleCategories() => [
  ModuleCategory('Körperpflege', [
    _t('aufstehen', 'Aufstehen', 'Jetzt ist es Zeit zum Aufstehen.', 10),
    _t('waschen', 'Waschen', 'Jetzt ist es Zeit zum Waschen.', 10),
    _t('duschen', 'Duschen', 'Jetzt ist es Zeit zum Duschen.', 15),
    _t('baden', 'Baden', 'Jetzt ist es Zeit zum Baden.', 20),
    _t('zaehne_putzen', 'Zähne putzen', 'Jetzt ist es Zeit zum Zähneputzen.', 5),
    _t('haare_kaemmen', 'Haare kämmen', 'Jetzt ist es Zeit, die Haare zu kämmen.', 5),
    _t('rasieren', 'Rasieren', 'Jetzt ist es Zeit zum Rasieren.', 10),
    _t('anziehen', 'Anziehen', 'Jetzt ist es Zeit zum Anziehen.', 10),
    _t('toilette', 'Toilette', 'Jetzt ist es Zeit für die Toilette.', 5),
    _t('eincremen', 'Eincremen', 'Jetzt ist es Zeit zum Eincremen.', 5),
  ]),
  ModuleCategory('Essen & Trinken', [
    _t('fruehstueck', 'Frühstück', 'Jetzt ist Frühstück.', 20),
    _t('mittagessen', 'Mittagessen', 'Jetzt ist Mittagessen.', 30),
    _t('abendessen', 'Abendessen', 'Jetzt ist Abendessen.', 30),
    _t('jause', 'Jause', 'Jetzt ist Zeit für die Jause.', 10),
    _t('trinken', 'Trinken', 'Bitte jetzt etwas trinken.', 2),
    _t('kochen', 'Kochen', 'Jetzt ist es Zeit zum Kochen.', 30),
    _t('tisch_decken', 'Tisch decken', 'Jetzt ist es Zeit, den Tisch zu decken.', 10),
    _t('abwaschen', 'Abwaschen', 'Jetzt ist es Zeit zum Abwaschen.', 15),
  ]),
  ModuleCategory('Gesundheit', [
    _t('medikament', 'Medikament', 'Jetzt ist es Zeit für dein Medikament.', 2),
    _t('tropfen', 'Tropfen nehmen', 'Jetzt ist es Zeit für die Tropfen.', 2),
    _t('blutdruck', 'Blutdruck messen', 'Jetzt ist es Zeit, den Blutdruck zu messen.', 5),
    _t('arzt', 'Arzt-Termin', 'Jetzt ist ein Termin beim Arzt.', 30),
    _t('therapie', 'Therapie', 'Jetzt ist es Zeit für die Therapie.', 30),
  ]),
  ModuleCategory('Unterwegs', [
    _t('bus_nehmen', 'Bus nehmen', 'Jetzt ist es Zeit, den Bus zu nehmen.', 20),
    _t('zug_nehmen', 'Zug nehmen', 'Jetzt ist es Zeit, den Zug zu nehmen.', 20),
    _t('zu_fuss', 'Zu Fuß gehen', 'Jetzt gehen wir zu Fuß.', 15),
    _t('fahrrad', 'Fahrrad fahren', 'Jetzt fahren wir Fahrrad.', 20),
    _t('auto_fahren', 'Auto fahren', 'Jetzt fahren wir mit dem Auto.', 20),
    _t('spazieren', 'Spazieren', 'Jetzt ist es Zeit für einen Spaziergang.', 30),
  ]),
  ModuleCategory('Arbeit & Schule', [
    _t('arbeit', 'Arbeit', 'Jetzt ist es Zeit für die Arbeit.', 60),
    _t('schule', 'Schule', 'Jetzt ist es Zeit für die Schule.', 60),
    _t('werkstatt', 'Werkstatt', 'Jetzt ist es Zeit für die Werkstatt.', 60),
    _t('rucksack_packen', 'Rucksack packen', 'Jetzt ist es Zeit, den Rucksack zu packen.', 10),
    _t('tasche_packen', 'Tasche packen', 'Jetzt ist es Zeit, die Tasche zu packen.', 10),
    _t('pause', 'Pause', 'Jetzt ist Pause.', 15),
    _t('aufgabe', 'Aufgabe erledigen', 'Jetzt ist es Zeit für die Aufgabe.', 20),
  ]),
  ModuleCategory('Haushalt', [
    _t('aufraeumen', 'Aufräumen', 'Jetzt ist es Zeit zum Aufräumen.', 15),
    _t('staubsaugen', 'Staubsaugen', 'Jetzt ist es Zeit zum Staubsaugen.', 15),
    _t('waesche', 'Wäsche waschen', 'Jetzt ist es Zeit für die Wäsche.', 10),
    _t('waesche_aufhaengen', 'Wäsche aufhängen', 'Jetzt ist es Zeit, die Wäsche aufzuhängen.', 10),
    _t('einkaufen', 'Einkaufen', 'Jetzt ist es Zeit zum Einkaufen.', 30),
    _t('muell', 'Müll rausbringen', 'Jetzt ist es Zeit, den Müll rauszubringen.', 5),
    _t('blumen_giessen', 'Blumen gießen', 'Jetzt ist es Zeit, die Blumen zu gießen.', 5),
    _t('bett_machen', 'Bett machen', 'Jetzt ist es Zeit, das Bett zu machen.', 5),
  ]),
  ModuleCategory('Freizeit', [
    _t('fernsehen', 'Fernsehen', 'Jetzt ist Zeit zum Fernsehen.', 30),
    _t('musik_hoeren', 'Musik hören', 'Jetzt ist Zeit, Musik zu hören.', 20),
    _t('lesen', 'Lesen', 'Jetzt ist Zeit zum Lesen.', 20),
    _t('telefonieren', 'Telefonieren', 'Jetzt ist es Zeit zum Telefonieren.', 10),
    _t('besuch', 'Besuch', 'Jetzt kommt Besuch.', 30),
    _t('spielen', 'Spielen', 'Jetzt ist Zeit zum Spielen.', 20),
    _t('malen', 'Malen', 'Jetzt ist Zeit zum Malen.', 20),
    _t('sport', 'Sport', 'Jetzt ist es Zeit für Sport.', 30),
    _t('entspannen', 'Entspannen', 'Jetzt ist es Zeit zum Entspannen.', 15),
    _t('ausruhen', 'Ausruhen', 'Jetzt ist es Zeit zum Ausruhen.', 15),
  ]),
  ModuleCategory('Abend & Nacht', [
    _t('abendroutine', 'Fertig machen für die Nacht', 'Jetzt machen wir uns fertig für die Nacht.', 15),
    _t('schlafanzug', 'Schlafanzug anziehen', 'Jetzt ist es Zeit, den Schlafanzug anzuziehen.', 5),
    _t('schlafengehen', 'Schlafen gehen', 'Jetzt ist es Zeit zum Schlafengehen.', 5),
    _t('gute_nacht', 'Gute Nacht', 'Gute Nacht. Schlaf gut.', 2),
  ]),
];

List<Activity> moduleLibrary() => [for (final c in moduleCategories()) ...c.items];

List<Activity> sampleDay() {
  final t = {for (final a in moduleLibrary()) a.key: a};
  List<Activity> pick(List<String> keys) =>
      [for (final k in keys) (t[k] ?? _t(k, k, 'Jetzt: $k', 10)).copy()..id = 'a$k'];
  return pick(['aufstehen', 'duschen', 'zaehne_putzen', 'anziehen', 'fruehstueck', 'rucksack_packen', 'bus_nehmen']);
}
