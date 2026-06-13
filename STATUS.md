# Entwicklungsstand – Tagesbegleiter

Stand: 12. Juni 2026 · Ziel 100% = fertig, getestet, fehlerfrei, Go-Live

## Gesamtfortschritt: ~58 %

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
