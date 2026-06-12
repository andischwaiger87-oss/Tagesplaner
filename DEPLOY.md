# Deployment: Tagesbegleiter als Web-App (Cloudflare Pages)

Du hast Cloudflare Pages bereits per **Git-Anbindung** mit dem Repo verbunden –
es fehlt nur der **Build-Schritt** (Flutter). Ohne ihn lädt Cloudflare nur den
Quellcode hoch → 404.

## Fix in 2 Feldern (Cloudflare Dashboard)

Projekt **tagesplaner-aut** → **Settings → Builds & deployments → Build configuration → Edit**:

- **Framework preset:** `None`
- **Build command:**
  ```
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable fluttersdk && export PATH="$PWD/fluttersdk/bin:$PATH" && flutter pub get && flutter build web --release
  ```
- **Build output directory:** `build/web`
- **Root directory:** (leer lassen)

Speichern → oben **„Retry deployment"** (oder „Create deployment").
Der erste Build dauert ein paar Minuten (Flutter wird einmal geklont).
Danach ist die App unter `https://tagesplaner-aut.pages.dev/` live.

> Hinweis: Bei jedem `git push` baut & veröffentlicht Cloudflare nun automatisch.

## Alternative (GitHub Actions statt Cloudflare-Build)
Falls du lieber über Actions deployst, ist `.github/workflows/deploy.yml`
vorbereitet (baut Flutter, deployt via Wrangler). Dafür im Repo zwei Secrets
setzen: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`. Dann aber die
Cloudflare-Git-Anbindung deaktivieren, damit nicht doppelt deployt wird.
