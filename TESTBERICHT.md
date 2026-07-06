# Testbericht – Tagesbegleiter (simulierter Stresstest & Review)

Stand: Juni 2026. Da hier keine echte Kompilierung/Geräteausführung möglich ist,
wurde die **Kernlogik** (Zeitmodell, Überschneidungs-Schutz, Drag-&-Drop-Verkettung,
„Jetzt"-Berechnung) 1:1 nachgebaut und mit **~89.000 zufälligen Operationen** plus
Grenzfällen geprüft. Zusätzlich ein statisches Code-/Usability-Review.

## Gefundene Fehler

### 1. Kritisch – behoben: Tag lief über Mitternacht hinaus
- **Fund:** Durch Hinzufügen/Verschieben/lange Dauern konnten Startzeiten über 24:00
  hinauswachsen (im Test bis „78:25 Uhr").
- **Folgen:** kaputte Uhrzeit-Anzeige, Einträge wurden nie „Jetzt" (unerreichbar),
  Benachrichtigung mit Stunde > 23 wäre fehlgeschlagen.
- **Fix:** 24-Stunden-Grenzschutz in `setStart`, `setDuration`, `addFromTemplate`,
  `addCustom`, `reorderChain`. Passt etwas nicht mehr in den Tag, wird es abgelehnt
  und der/die Nutzer:in bekommt eine klare Meldung (z. B. „Kein Platz mehr am Tag").
- **Nachweis:** Erneuter Lauf mit 88.820 Operationen → 0 Überläufe, 0 Überschneidungen.

### 2. Kritisch – behoben: Editor-Datei war abgeschnitten
- Eine Datei war beim Speichern auf der Platte abgeschnitten worden (hätte den Build
  gebrochen). Ende wiederhergestellt, alle Dateien auf Klammer-Balance geprüft (grün).

## Geprüft und in Ordnung
- **Keine Überschneidungen** von Terminen nach beliebigen Operationen.
- **„Jetzt"-Auswahl** über den ganzen Tag konsistent (aktive Aufgabe immer korrekt).
- **Keine negativen Zeiten.**
- Drag-&-Drop-Verkettung erzeugt lückenlose, überschneidungsfreie Zeiten.

## Bekannte Einschränkungen (kein Bug – dokumentiert)
- **Web-Sprachausgabe:** Browser blockieren Auto-Audio bis zur ersten Nutzer-Aktion;
  die Roboterstimme ist im Web unterdrückt. In der installierten App voll funktionsfähig.
- **Hintergrund-Benachrichtigungen/Vibration:** zuverlässig nur in der installierten
  App (Android/iOS), nicht im Browser.
- **Avatare** werden als Bild lokal gespeichert – sehr große Bilder meiden (Speicherlimit).

## Usability-Beobachtungen (Empfehlungen, keine Fehler)
- Beim Umsortieren werden Zeiten lückenlos aneinandergereiht (ab der ersten Startzeit).
  Das ist ein sinnvoller Standard; wer Lücken will, passt danach einzelne Uhrzeiten an.
- Sehr lange eigene Bezeichnungen könnten bei maximaler Schriftgröße auf dem
  „Jetzt"-Screen umbrechen – unkritisch, ggf. später kürzen/skalieren.
- Screenreader-Grundlagen sind gesetzt; ein echter VoiceOver/TalkBack-Durchgeht auf
  Gerät steht noch aus (Punkt #16).

## Fazit
Die Terminlogik ist nach dem Fix **robust und fehlerfrei** in der Simulation.
Der letzte echte Beweis bleibt ein Build + Test auf echten Geräten.
