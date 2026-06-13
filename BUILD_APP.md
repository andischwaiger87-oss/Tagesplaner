# App bauen für Android & Apple

## Android (APK / App-Bundle) – sofort möglich

### Variante A: automatisch über GitHub Actions (empfohlen, ohne lokales Setup)
1. Code pushen (`git push`). Der Workflow **„Android Build (APK + AAB)"** startet automatisch
   (oder im GitHub-Repo unter **Actions → Android Build → Run workflow** manuell starten).
2. Nach ~5–8 Min ist der Lauf fertig. Unten beim Lauf unter **Artifacts** findest du:
   - `tagesbegleiter-apk` → die **app-release.apk** (universell, läuft auf allen Android-Geräten)
   - `tagesbegleiter-aab` → das **App-Bundle** (für den Google Play Store)
3. APK herunterladen, aufs S22 kopieren, antippen → „Aus unbekannten Quellen erlauben" → installieren.
4. Beim ersten Start: Benachrichtigungen erlauben, „Wecker & Erinnerungen / Exakte Alarme" zulassen,
   und die App in den Akku-Einstellungen auf „Nicht optimiert" stellen (für zuverlässiges Aufpoppen).

### Variante B: lokal auf deinem Rechner
```bash
cd app
flutter build apk --release
# Ergebnis: build/app/outputs/flutter-apk/app-release.apk
```

> Hinweis: Die App ist mit dem Debug-Schlüssel signiert – ideal zum Testen und Verteilen
> außerhalb des Stores. Für eine Veröffentlichung im **Google Play Store** brauchst du
> einen eigenen Upload-Schlüssel (Keystore) – das richten wir ein, sobald es so weit ist.

## Apple (iPhone / iPad) – braucht ein Apple-Entwicklerkonto

Wichtig und ehrlich: Eine auf echten iPhones installierbare App kann **nur mit einem
Apple-Developer-Konto** erstellt werden. Das ist eine Vorgabe von Apple, nicht von uns.
Nötig sind:

1. **Apple Developer Program** – 99 USD/Jahr (https://developer.apple.com/programs/).
2. Ein **Mac mit Xcode** ODER ein Cloud-Build-Dienst (kein eigener Mac nötig):
   - **Codemagic** (auf Flutter spezialisiert, kostenloser Einstieg, übernimmt die Signierung) – am einfachsten.
   - oder GitHub Actions mit macOS-Runner + Signing-Zertifikaten.
3. Verteilung an Testgeräte über **TestFlight** (über App Store Connect).

Sobald du das Apple-Konto hast, richte ich Bundle-ID, Signierung und einen
iOS-Build-Workflow (Codemagic oder GitHub Actions) ein – dann bekommst du die App
per TestFlight aufs iPhone.

## Web (bereits live)
Die Web-Version läuft schon über Cloudflare Pages (`tagesplaner-aut.pages.dev`) und
funktioniert auf jedem Gerät im Browser – nur die Hintergrund-Erinnerungen/Vibration
sind dort eingeschränkt (dafür ist die installierte App da).
