# Tagesbegleiter (Flutter)

Barrierefreie App zur Tagesstrukturierung – „Jetzt", immer mit der echten Uhrzeit
synchronisiert. Plattformübergreifend (iOS, Android, Desktop) aus einer Codebasis.

## Erststart (einmalig auf deinem Rechner)

Dieses Repo enthält den App-Code (`lib/`) und die Konfiguration. Die
plattform-spezifischen Ordner (android/ios/windows/...) erzeugt Flutter selbst:

```bash
cd app
flutter create .          # erzeugt android/ ios/ ... ohne lib/ zu überschreiben
flutter pub get
flutter run               # auf Gerät/Emulator oder -d chrome / -d windows
```

## Eigene Icons & Sprachdateien zuweisen

- Lege deine **handgezeichneten SVGs** in `assets/icons/` ab.
- Lege deine **ElevenLabs-Sprachdateien** (.mp3/.wav) in `assets/audio/` ab.
- In der App: Tab **Bearbeiten → Modul → „SVG-Icon"** bzw. **„Sprachdatei"**
  öffnet die Dateiauswahl. Die Zuweisung wird pro Modul gespeichert.
- Ohne Sprachdatei nutzt die App automatisch die geräteeigene Stimme (Rückfall).

## Architektur (Kurzüberblick)

- `models/` – Datenmodelle (Activity, AppSettings)
- `data/` – vorgefertigte Modul-Bibliothek + Beispieltag
- `services/` – Speicherung (offline JSON), Audio/TTS, Benachrichtigungen
- `state/app_state.dart` – zentrale Logik inkl. **Echtzeit-Synchronisation**
- `screens/` – Jetzt, Tagesplan, Bearbeiten, Einstellungen
- `theme/` – moderne, kontraststarke Themes (inkl. Hochkontrast)

## Noch offen (siehe STATUS.md)
Exakte geplante Alarme, Drag-&-Drop-Reihenfolge, Smartwatch, Tests, Store-Setup.
