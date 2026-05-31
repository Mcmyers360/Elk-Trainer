# Elk Hunt Trainer 2027

Personal fitness and shooting tracker for a Utah elk hunt — South Slope Uintas, October 3–16 2027.

Five tabs: **Week** (daily workouts + notes), **Shoot** (range sessions + group size chart), **Weight** (bodyweight log + trend), **Log** (full workout history), **Plan** (12-month phase overview + hunt countdown).

---

## Architecture

| What | Where | Visibility |
|------|-------|------------|
| App shell (this repo) | GitHub Pages | Public — no personal data |
| Your training data (`data.json`) | Private repo you create | Private — only you |

Your data never touches this public repository. The app reads and writes one file (`data.json`) to a **separate private repo** using your Personal Access Token.

---

## One-Time Setup

### 1 — Create a private data repository

1. Go to [github.com/new](https://github.com/new)
2. Name it `elk-trainer-data`
3. Set visibility to **Private**
4. Click **Create repository** — no need to add any files, the app creates `data.json` automatically

### 2 — Create a GitHub Personal Access Token

1. GitHub → Settings → Developer settings → Personal access tokens → **Tokens (classic)**
2. Click **Generate new token (classic)**
3. Name: `Elk Trainer`
4. Expiration: **No expiration** (or set 1 year and renew annually)
5. Scopes: check **repo** — this grants read/write access to your private repositories
6. Click **Generate token**
7. **Copy it immediately** — GitHub only shows it once

> The token is stored in your phone's `localStorage` only. It is never committed to any repository or sent anywhere except the GitHub API.

### 3 — Enable GitHub Pages on this repository

In the `Elk-Trainer` repository:

1. **Settings → Pages**
2. Source: **Deploy from a branch**
3. Branch: **main** · folder: **/ (root)**
4. Click **Save**

The app will be live at `https://mcmyers360.github.io/Elk-Trainer/` within about a minute.

### 4 — Install on your phone

**iPhone (Safari required):**
1. Open `https://mcmyers360.github.io/Elk-Trainer/` in Safari
2. Tap the **Share** button (box with arrow)
3. Tap **Add to Home Screen** → **Add**

**Android (Chrome):**
1. Open `https://mcmyers360.github.io/Elk-Trainer/` in Chrome
2. Chrome will show an install banner, or tap menu → **Install app**

### 5 — First launch

When you open the app for the first time:

1. **PIN** (optional) — set a 4-digit PIN or skip
2. **Token** — paste your Personal Access Token
3. **Username** — your GitHub username (e.g. `mcmyers360`)
4. **Repository** — your private data repo name (e.g. `elk-trainer-data`)
5. Tap **Verify & Connect**

The app verifies your token, then creates `data.json` in your private repo if it doesn't exist. You're ready.

---

## Updating the App

Edit files on your computer → commit → push to `main`. Your phone picks up the changes automatically the next time the app opens with any internet connection. **Your computer does not need to be on.**

---

## Offline Use

After the first install, the service worker caches the app shell. The app opens and works fully offline. Any changes you make while offline (logging a workout, weight, or shooting session) are queued and synced to GitHub the next time you have internet.

---

## Local Development

To run the app locally for development and testing:

```bash
# Terminal 1 — file server
python3 -m http.server 8080

# Terminal 2 — HTTPS tunnel (required for service worker on phone)
ngrok http 8080
```

Or use the included script:

```bash
./start.sh
```

Open the ngrok HTTPS URL on your phone to test. After installing from that URL once, the service worker caches the app and you can close the tunnel.

---

## Data Format

Your private `elk-trainer-data` repo holds one file:

```json
{
  "schemaVersion": 1,
  "workoutLog":   { "2025-06-01": true },
  "sessionNotes": { "2025-06-01": [{ "text": "Felt strong on the climb" }] },
  "weightLog":    { "2025-06-01": 215.5 },
  "shootLog": [
    {
      "id": 1748123456789,
      "date": "2025-06-01",
      "rifle": "Ridgeline 300 Win Mag",
      "distance": "200 yds",
      "rounds": 20,
      "groupSize": 1.25,
      "condition": "Calm",
      "coldBore": true,
      "notes": "First cold bore at 200. Clean."
    }
  ]
}
```

---

## Rifles Tracked

- Ridgeline 300 Win Mag (hunt rifle)
- Remington 783 30-06 (primary trainer)
- Mossberg 100 ATR 30-06 (backup)
- 7mm Rem Mag
