# Deployment: Tagesbegleiter als Web-App (GitHub + Cloudflare Pages)

Die App wird bei jedem Push auf `main` automatisch gebaut und auf Cloudflare
Pages veröffentlicht.

## Einmalige Einrichtung

### 1. Repo zu GitHub pushen
```bash
cd app
git init
git add .
git commit -m "Tagesbegleiter – erste Web-Version"
git branch -M main
git remote add origin https://github.com/andischwaiger87-oss/Tagesplaner.git
git push -u origin main
```
(Falls das Repo schon Inhalte hat: `git pull --rebase origin main` vor dem Push,
oder `git push -u origin main --force` wenn es leer/neu sein darf.)

### 2. Cloudflare Pages vorbereiten
1. Cloudflare Dashboard → **Workers & Pages** → **Create** → **Pages** →
   **Direct Upload** → Projektname exakt **`tagesplaner`** anlegen (einmal leer
   anlegen genügt; der GitHub-Workflow lädt danach automatisch hoch).
2. **API-Token** erstellen: Mein Profil → API Tokens → *Create Token* →
   Vorlage **"Edit Cloudflare Workers"** (oder Pages: *Account → Cloudflare
   Pages → Edit*). Token kopieren.
3. **Account-ID** kopieren (rechts im Dashboard / in der URL).

### 3. Secrets in GitHub hinterlegen
GitHub-Repo → **Settings → Secrets and variables → Actions → New repository secret**:
- `CLOUDFLARE_API_TOKEN` = dein Token
- `CLOUDFLARE_ACCOUNT_ID` = deine Account-ID

### 4. Fertig
Ab jetzt: jeder `git push` baut und deployt automatisch. Die Live-URL steht im
Cloudflare-Pages-Projekt (z. B. `https://tagesplaner.pages.dev`). Eine eigene
Domain lässt sich dort unter „Custom domains" verbinden.

## Alternative ohne GitHub Actions (manuell, schnell)
```bash
flutter build web --release
# build/web danach im Cloudflare-Pages-Projekt per Direct Upload hochladen
```
