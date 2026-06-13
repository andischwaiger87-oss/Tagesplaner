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
    _t('haende_waschen', 'Hände waschen', 'Jetzt ist es Zeit, die Hände zu waschen.', 3),
    _t('haare_waschen', 'Haare waschen', 'Jetzt ist es Zeit, die Haare zu waschen.', 10),
    _t('naegel_schneiden', 'Nägel schneiden', 'Jetzt ist es Zeit, die Nägel zu schneiden.', 10),
    _t('schuhe_anziehen', 'Schuhe anziehen', 'Jetzt ist es Zeit, die Schuhe anzuziehen.', 5),
    _t('jacke_anziehen', 'Jacke anziehen', 'Jetzt ist es Zeit, die Jacke anzuziehen.', 3),
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
    _t('kaffee', 'Kaffee', 'Jetzt ist Zeit für einen Kaffee.', 10),
    _t('tee', 'Tee', 'Jetzt ist Zeit für einen Tee.', 10),
    _t('obst', 'Obst essen', 'Jetzt ist Zeit für etwas Obst.', 10),
    _t('wasser', 'Wasser trinken', 'Bitte ein Glas Wasser trinken.', 2),
  ]),
  ModuleCategory('Gesundheit', [
    _t('medikament', 'Medikament', 'Jetzt ist es Zeit für dein Medikament.', 2),
    _t('tropfen', 'Tropfen nehmen', 'Jetzt ist es Zeit für die Tropfen.', 2),
    _t('blutdruck', 'Blutdruck messen', 'Jetzt ist es Zeit, den Blutdruck zu messen.', 5),
    _t('arzt', 'Arzt-Termin', 'Jetzt ist ein Termin beim Arzt.', 30),
    _t('therapie', 'Therapie', 'Jetzt ist es Zeit für die Therapie.', 30),
    _t('insulin', 'Insulin spritzen', 'Jetzt ist es Zeit für das Insulin.', 5),
    _t('brille_putzen', 'Brille putzen', 'Jetzt ist es Zeit, die Brille zu putzen.', 3),
    _t('physio', 'Physiotherapie', 'Jetzt ist es Zeit für die Physiotherapie.', 45),
    _t('logopaedie', 'Logopädie', 'Jetzt ist es Zeit für die Logopädie.', 45),
    _t('haende_desinfizieren', 'Hände desinfizieren', 'Bitte die Hände desinfizieren.', 2),
  ]),
  ModuleCategory('Unterwegs', [
    _t('bus_nehmen', 'Bus nehmen', 'Jetzt ist es Zeit, den Bus zu nehmen.', 20),
    _t('zug_nehmen', 'Zug nehmen', 'Jetzt ist es Zeit, den Zug zu nehmen.', 20),
    _t('zu_fuss', 'Zu Fuß gehen', 'Jetzt gehen wir zu Fuß.', 15),
    _t('fahrrad', 'Fahrrad fahren', 'Jetzt fahren wir Fahrrad.', 20),
    _t('auto_fahren', 'Auto fahren', 'Jetzt fahren wir mit dem Auto.', 20),
    _t('spazieren', 'Spazieren', 'Jetzt ist es Zeit für einen Spaziergang.', 30),
    _t('taxi', 'Taxi nehmen', 'Jetzt ist es Zeit, das Taxi zu nehmen.', 20),
  ]),
  ModuleCategory('Arbeit & Schule', [
    _t('arbeit', 'Arbeit', 'Jetzt ist es Zeit für die Arbeit.', 60),
    _t('schule', 'Schule', 'Jetzt ist es Zeit für die Schule.', 60),
    _t('werkstatt', 'Werkstatt', 'Jetzt ist es Zeit für die Werkstatt.', 60),
    _t('rucksack_packen', 'Rucksack packen', 'Jetzt ist es Zeit, den Rucksack zu packen.', 10),
    _t('tasche_packen', 'Tasche packen', 'Jetzt ist es Zeit, die Tasche zu packen.', 10),
    _t('pause', 'Pause', 'Jetzt ist Pause.', 15),
    _t('aufgabe', 'Aufgabe erledigen', 'Jetzt ist es Zeit für die Aufgabe.', 20),
    _t('lernen', 'Lernen', 'Jetzt ist es Zeit zum Lernen.', 30),
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
    _t('geschirrspueler', 'Geschirrspüler', 'Jetzt ist es Zeit für den Geschirrspüler.', 10),
    _t('post_holen', 'Post holen', 'Jetzt ist es Zeit, die Post zu holen.', 5),
    _t('tisch_abraeumen', 'Tisch abräumen', 'Jetzt ist es Zeit, den Tisch abzuräumen.', 5),
    _t('staub_wischen', 'Staub wischen', 'Jetzt ist es Zeit zum Staubwischen.', 15),
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
    _t('radio', 'Radio hören', 'Jetzt ist Zeit, Radio zu hören.', 20),
    _t('zeitung', 'Zeitung lesen', 'Jetzt ist Zeit, die Zeitung zu lesen.', 20),
    _t('hoerbuch', 'Hörbuch', 'Jetzt ist Zeit für ein Hörbuch.', 30),
    _t('singen', 'Singen', 'Jetzt ist Zeit zum Singen.', 15),
    _t('gymnastik', 'Gymnastik', 'Jetzt ist es Zeit für Gymnastik.', 20),
    _t('meditation', 'Meditation', 'Jetzt ist es Zeit für die Meditation.', 15),
    _t('nickerchen', 'Nickerchen', 'Jetzt ist Zeit für ein Nickerchen.', 30),
  ]),
  ModuleCategory('Abend & Nacht', [
    _t('abendroutine', 'Fertig machen für die Nacht', 'Jetzt machen wir uns fertig für die Nacht.', 15),
    _t('schlafanzug', 'Schlafanzug anziehen', 'Jetzt ist es Zeit, den Schlafanzug anzuziehen.', 5),
    _t('schlafengehen', 'Schlafen gehen', 'Jetzt ist es Zeit zum Schlafengehen.', 5),
    _t('gute_nacht', 'Gute Nacht', 'Gute Nacht. Schlaf gut.', 2),
    _t('wecker_stellen', 'Wecker stellen', 'Jetzt ist es Zeit, den Wecker zu stellen.', 2),
    _t('handy_laden', 'Handy laden', 'Jetzt ist es Zeit, das Handy zu laden.', 2),
  ]),
  ModuleCategory('Autismus: Reize & Ruhe', [
    _t('gleich_fertig', 'Gleich fertig', 'Gleich ist diese Aufgabe fertig.', 2),
    _t('wechsel', 'Es kommt ein Wechsel', 'Gleich wechseln wir zu etwas Neuem.', 2),
    _t('reizpause', 'Reizpause', 'Jetzt ist Zeit für eine ruhige Pause.', 10),
    _t('ruheraum', 'Ruhiger Ort', 'Du darfst dich an deinen ruhigen Ort zurückziehen.', 10),
    _t('kopfhoerer', 'Kopfhörer aufsetzen', 'Setz die Kopfhörer auf, wenn es zu laut ist.', 1),
    _t('atemuebung', 'Atemübung', 'Atme langsam ein und langsam aus.', 5),
    _t('gefuehle_zeigen', 'Wie geht es dir?', 'Zeig mir, wie es dir gerade geht.', 2),
    _t('auswaehlen', 'Auswählen', 'Du darfst jetzt selbst auswählen.', 2),
    _t('warten', 'Warten', 'Jetzt warten wir kurz. Gleich geht es weiter.', 5),
    _t('belohnung', 'Belohnung', 'Super gemacht. Jetzt kommt deine Belohnung.', 5),
    _t('bewegungspause', 'Bewegungspause', 'Steh auf und beweg dich ein bisschen.', 5),
    _t('aufgabe_fertig', 'Aufgabe abhaken', 'Diese Aufgabe ist fertig. Gut gemacht.', 1),
  ]),
  ModuleCategory('Demenz: Orientierung & Begleitung', [
    _t('heutiger_tag', 'Welcher Tag ist heute?', 'Wir schauen, welcher Tag und welches Datum heute ist.', 2),
    _t('orientierung', 'Wo bin ich?', 'Wir schauen gemeinsam, wo du gerade bist.', 2),
    _t('fotos_ansehen', 'Fotos ansehen', 'Wir schauen uns schöne Erinnerungen und Fotos an.', 15),
    _t('familie_anrufen', 'Familie anrufen', 'Jetzt rufen wir jemanden aus der Familie an.', 10),
    _t('trinkpause', 'Trinkpause', 'Bitte trink einen Schluck. Das ist wichtig.', 2),
    _t('toilette_erinnerung', 'Toilette', 'Komm, wir gehen auf die Toilette.', 5),
    _t('brille_aufsetzen', 'Brille aufsetzen', 'Setz bitte deine Brille auf.', 1),
    _t('hoergeraet', 'Hörgerät einsetzen', 'Setz bitte dein Hörgerät ein.', 2),
    _t('lieblingsmusik', 'Lieblingsmusik', 'Wir hören deine Lieblingsmusik.', 20),
    _t('beruhigen', 'Ruhig werden', 'Alles ist gut. Wir werden gemeinsam ruhig.', 10),
    _t('waesche_falten', 'Wäsche falten', 'Wir falten zusammen die Wäsche.', 15),
    _t('frische_luft', 'Frische Luft', 'Wir gehen kurz an die frische Luft.', 15),
    _t('tag_besprechen', 'Den Tag besprechen', 'Wir reden kurz über den heutigen Tag.', 10),
  ]),
];

List<Activity> moduleLibrary() => [for (final c in moduleCategories()) ...c.items];

Activity _mk(Map<String, Activity> t, String k, int start, int dur) {
  final base = t[k] ?? _t(k, k, 'Jetzt ist es Zeit f\u00fcr $k.', dur);
  final c = base.copy();
  c.id = 's_${k}_$start';
  c.startMinutes = start;
  c.durationMin = dur;
  return c;
}

List<Activity> sampleDay() {
  final t = {for (final a in moduleLibrary()) a.key!: a};
  return [
    _mk(t, 'aufstehen', 420, 10),
    _mk(t, 'duschen', 435, 15),
    _mk(t, 'zaehne_putzen', 455, 5),
    _mk(t, 'anziehen', 465, 10),
    _mk(t, 'fruehstueck', 480, 20),
    _mk(t, 'bus_nehmen', 510, 20),
    _mk(t, 'arbeit', 540, 180),
    _mk(t, 'mittagessen', 720, 30),
    _mk(t, 'pause', 750, 15),
    _mk(t, 'arbeit', 780, 180),
    _mk(t, 'bus_nehmen', 960, 20),
    _mk(t, 'spazieren', 990, 30),
    _mk(t, 'abendessen', 1050, 30),
    _mk(t, 'fernsehen', 1110, 60),
    _mk(t, 'abendroutine', 1200, 15),
    _mk(t, 'zaehne_putzen', 1230, 5),
    _mk(t, 'schlafengehen', 1260, 10),
  ];
}
