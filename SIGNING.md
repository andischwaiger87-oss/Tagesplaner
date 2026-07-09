# Release-Signatur einrichten (einmalig)

Damit spätere Updates **ohne Deinstallation und ohne Datenverlust** installiert werden können,
muss die App immer mit **demselben Schlüssel** signiert sein.

## 1. Schlüssel (Keystore) erzeugen – auf deinem Rechner
In PowerShell (Java/Android Studio muss installiert sein):

```powershell
keytool -genkey -v -keystore tagesbegleiter-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
- Du vergibst ein **Keystore-Passwort** und ein **Schlüssel-Passwort** (dürfen gleich sein).
- Name/Organisation kannst du frei ausfüllen.
- **Wichtig:** Datei und Passwörter sicher aufbewahren (z. B. Passwortmanager).
  Geht der Schlüssel verloren, sind Updates ohne Deinstallation nicht mehr möglich.
- Die `.jks`-Datei **niemals** ins Repo legen (ist bereits in `.gitignore`).

## 2. Keystore in Text umwandeln (für GitHub)
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("tagesbegleiter-upload.jks")) | Set-Clipboard
```
Der lange Text liegt jetzt in der Zwischenablage.

## 3. GitHub-Secrets anlegen
Repo → **Settings → Secrets and variables → Actions → New repository secret**:

| Name | Wert |
|---|---|
| `KEYSTORE_BASE64` | der lange Text aus Schritt 2 |
| `KEYSTORE_PASSWORD` | dein Keystore-Passwort |
| `KEY_PASSWORD` | dein Schlüssel-Passwort |
| `KEY_ALIAS` | `upload` |

## 4. Fertig
Ab dem nächsten Push signiert der Workflow automatisch mit deinem Schlüssel.
Ohne Secrets baut er weiterhin mit dem Debug-Schlüssel (nichts bricht).

## Wichtig für den Umstieg
Die bisher verteilte APK war **Debug-signiert**. Nach dem Wechsel muss die App
**einmalig deinstalliert** und neu installiert werden (Android erlaubt keinen
Schlüsselwechsel im Update). Danach bleiben bei allen weiteren Updates alle
Einstellungen und Pläne erhalten.
