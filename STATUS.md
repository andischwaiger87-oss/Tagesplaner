# Entwicklungsstand – Tagesbegleiter

Stand: 12. Juni 2026 · Ziel 100% = fertig, getestet, fehlerfrei, Go-Live

## Gesamtfortschritt: ~78 %

| Bereich | Status | % |
|---|---|---|
| Konzept, Prototyp, Architektur | ✅ | 100 |
| Bausteine-Bibliothek (58 Module) + Auto-Erkennung Icons/Audio | ✅ | 95 |
| Eigene Custom-Einträge | ✅ | 90 |
| Modernes Design (Lexend-Schrift, Bring-Stil, helle Oberfläche) | ✅ neu | 70 |
| Icon-Kontrast (weiße Icons auf farbigen Kacheln) | ✅ neu | 90 |
| „Bearbeiten" neu: Ablauf oben, Hinzufügen-Sheet mit SUCHE | ✅ neu | 85 |
| „Jetzt" exakt zur Uhrzeit | ✅ neu | 90 |
| Schriftgrößen-Crash behoben (TextScaler) | ✅ neu | 100 |
| Adressleisten-/PWA-Farbe (mobil) | ✅ neu | 100 |
| Web-Deployment (GitHub Actions → Cloudflare Pages) | ◑ vorbereitet | 70 |
| Echtgeräte-Test Aufpoppen (Android) | ◻ offen | 10 |
| Barrierefreiheits-Audit (VoiceOver/TalkBack) | ◻ offen | 0 |
| Wochen-/Monatspläne · Smartwatch | ◻ offen | 0 |
| Tests & Go-Live | ◻ offen | 5 |

## Neu in diesem Schritt
- Moderne, sehr gut lesbare Schrift **Lexend** (für Leseförderung entwickelt).
- Bring-orientiertes Design: weiße Icons auf farbigen Kacheln = hoher Kontrast.
- „Bearbeiten" mobil-first neu: der Ablauf steht oben, Bausteine kommen über ein
  Bottom-Sheet **mit Suchfeld** + Kategorie-Chips + Kachel-Raster (auch für kleine Geräte).
- „Jetzt" zeigt jetzt exakt die zur aktuellen Uhrzeit laufende Aktivität.
- Schriftgrößen-Fehler behoben (Skalierung über TextScaler statt Theme).
- Mobile Adressleiste & PWA in Markenfarbe (#2E7D6F).
- Deployment-Setup: `.github/workflows/deploy.yml` + `DEPLOY.md`.

## Vor dem nächsten Start einmalig
```bash
cd app
flutter pub get      # google_fonts (Lexend) wird geladen
flutter run -d chrome
```


## Politur (12.6., Abend)
- Lebendiger Hintergrund: sanfter Farbverlauf statt flachem Grau (passt sich dem Farbthema an).
- „Jetzt": Karte mittig ausbalanciert (keine große Leere mehr).
- Editor-Fix: eigener Verschiebe-Griff links – Verschieben & Löschen überlagern sich nicht mehr.
- Suche: im „Baustein hinzufügen"-Fenster (Suchfeld + Kategorie-Chips + Kachel-Raster).


## Bugfixes & Features (18.6.)
- Sprachausgabe repariert: Frau (de_f) als Standard, Mann (de_m) umschaltbar – die
  echten Audiodateien werden jetzt zuverlässig abgespielt (web-sicher über Bytes),
  Roboterstimme nur noch als Notfall-Rückfall.
- Einstellungen werden bei jeder Änderung gespeichert und beim Neuladen geladen.
- Editor stabilisiert: Verschieben (eigener ⠿-Griff) und Löschen klar getrennt;
  beim Löschen kommt „Rückgängig"; kein versehentliches Audio mehr beim Bearbeiten.
- Klares Feedback (kleine Hinweise) bei Hinzufügen, Löschen, Speichern, Sortieren.
- Dauer-Regler beschriftet („10 Min" mit − / +), damit verständlich.
- Einstellungen-Überschriften jetzt dunkel/lesbar.
- Profilbild (oben neben dem Namen) + Avatar-Bilder für Frau/Mann hochladbar & gespeichert.
- Englische Stimme entfernt (Standard: deutsche Frauenstimme).


## Zeitmodell & UX (13.6.)
- Echte, frei einstellbare Uhrzeiten je Schritt (Uhr-Auswahl) + Dauer-Auswahl;
  KEINE automatische Verkettung mehr. Überschneidungen werden verhindert und klar gemeldet.
- „Jetzt" ist exakt an der Systemzeit ausgerichtet: zeigt die laufende Aufgabe,
  sonst die nächste; nach dem letzten Schritt „Für heute geschafft".
- Restzeit in Echtzeit: „Als Nächstes"-Liste mit Countdown-Ringen („In 25 Min.").
- Sinnvoller Standard-Tagesplan (ganztags, realistische Reihenfolge) – lädt einmalig neu.
- Hinzufügen-Fenster: sichtbare Bestätigung (✓-Häkchen + Leiste), X zum Schließen.
- Meldungen kompakt und schließen sich selbst.


## Feinschliff (13.6., Teil 2)
- Zeitanzeige nie über 60 Min (z. B. „1 Std 29 Min" statt „89 Min").
- Dauer frei eingebbar (eigene Minuten) – mit Überschneidungs-Schutz.
- Avatar-Blinken behoben (Bild wird zwischengespeichert) + Bild entfernbar.
- Tagesplan-Titel „Mein Tag".
- 29 neue Bausteine (jetzt 87) + Excel-Produktionsliste erweitert (inkl. Hilfe-Audios).
- Hilfe-/Einführungs-Wizard (6 Schritte, Stepper) – jederzeit in den Einstellungen,
  mit Vorlesen (Audio intro1–intro6_de_f/_de_m, sonst Gerätestimme).


## Wochenpläne & Kalender (13.6.)
- Eigener Plan je Wochentag (Mo–So). Standard: Mo–Fr Arbeitstag, Sa–So entspannt.
- „Jetzt" zeigt automatisch den heutigen Tag; oben rechts das Datum – Tippen öffnet den Kalender.
- „Tagesplan"-Tab neu mit Umschaltung Tag / Woche / Monat (klarer Monatskalender mit Punkten).
- „Bearbeiten": Wochentag oben wählbar + „Kopieren" (auf Werktage / Wochenende / alle Tage).
- Haupt-UI („Jetzt") bleibt bewusst einfach.


## A11y, Onboarding, iOS-Vorbereitung (13.6.)
- Barrierefreiheit: Icons mit Screenreader-Beschriftung, „Jetzt"-Karte als zusammenhängende
  Vorlese-Einheit, dekorative Fortschrittselemente ausgeblendet.
- Automatisches Onboarding: Hilfe-Wizard öffnet sich beim allerersten Start einmalig.
- Einstellungen: Über/Impressum (dezent), Datenschutz-Hinweis, Standardplan-Reset.
- iOS vorbereitet: Bundle-ID at.mosaikdesign.tagesbegleiter, Berechtigungstexte,
  codemagic.yaml (TestFlight + Android). Apple-Developer-Konto noch nötig.


## Tagesfortschritt (13.6.)
- Schritte abhaken: erledigte Aufgaben pro Tag markieren (Kreis im Tagesplan, Button auf „Jetzt").
- Fortschrittsanzeige „x/y erledigt" auf „Jetzt" und im Tagesplan (heute).
- Erledigtes wird gespeichert und setzt sich automatisch um Mitternacht zurück.


## reduceMotion + Tests (13.6.)
- „Animationen reduzieren" greift jetzt wirklich: keine Seitenübergänge, kein Splash,
  Theme-/Balken-Animationen aus, MediaQuery.disableAnimations gesetzt.
- Erste automatisierte Tests (test/widget_test.dart): Zeit-Formatierung + JSON-Roundtrips.
  Ausführen mit: flutter test
