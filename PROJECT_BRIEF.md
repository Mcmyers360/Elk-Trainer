# Elk Hunt Trainer 2027 — Claude Code Project Brief

## Project Overview

Build a Progressive Web App (PWA) training tracker for a Utah elk hunt in October 2027. The app is a personal tool for one user. All data persists in a GitHub repository as a JSON file via the GitHub Contents API. The token is entered once by the user in-app and stored in localStorage — it never lives in the codebase.

-----

## Context

This conversation contains the full design history. Key decisions already made:

- **User:** Non-resident hunter from Cincinnati, OH targeting Utah general season elk, October 3–16 2027, South Slope Uinta Mountains
- **Rifle:** Christensen Arms Ridgeline 300 Win Mag (hunting), Remington 783 30-06 with Bushnell DOA 600 (primary trainer), Mossberg 100 ATR 30-06 with Barska 3-9x (backup)
- **Training:** 5 days/week weighted 5K + legs (atlas trainer), Saturday long effort, Sunday rest. 12-month progressive program across 4 phases (15lb → 35lb vest)
- **Hunt setup:** Polaris Ranger 1000 EPS, trailer base camp, canvas wall tent, 14-day hunt with brother

-----

## Tech Stack

- **Frontend:** Vanilla HTML/CSS/JavaScript or lightweight React (no build tooling if possible — single deployable HTML file preferred)
- **Hosting:** GitHub Pages (free, public repo)
- **Storage:** GitHub Contents API — single `data.json` file in the repo, read/written by the app
- **Auth:** GitHub Personal Access Token — user enters once, stored in localStorage, never committed to repo
- **PWA:** Service worker for offline capability, home screen installable

-----

## Data Structure

All app data lives in one `data.json` file in the repo:

```json
{
  "workoutLog": {},
  "sessionNotes": {},
  "weightLog": {},
  "shootLog": []
}
```

### workoutLog

Key-value: `{ "2025-06-01": true }` — date string to boolean (completed/not)

### sessionNotes

Key-value: `{ "2025-06-01": [{ "text": "Felt strong" }] }` — date to array of note objects

### weightLog

Key-value: `{ "2025-06-01": 215.5 }` — date to weight in lbs

### shootLog

Array of session objects:

```json
{
  "id": 1748123456789,
  "date": "2025-06-01",
  "rifle": "Ridgeline 300 Win Mag",
  "distance": "200 yds",
  "rounds": 40,
  "groupSize": 5.0,
  "condition": "Calm",
  "coldBore": false,
  "notes": "Flinch on rounds 3 and 7. Dry fire needed."
}
```

-----

## GitHub Storage Implementation

### Setup flow (first launch)

1. User is prompted to enter their GitHub Personal Access Token (gist scope is sufficient, or repo scope for Contents API)
1. User enters their GitHub username and repo name where data.json will live
1. App verifies token works by making a test API call
1. Token, username, and repo name stored in localStorage
1. App creates `data.json` in the repo if it doesn't exist

### Read

```
GET https://api.github.com/repos/{owner}/{repo}/contents/data.json
Authorization: token {token}
```

Response includes base64-encoded content and a `sha` value needed for writes.

### Write

```
PUT https://api.github.com/repos/{owner}/{repo}/contents/data.json
Authorization: token {token}
Body: {
  message: "Update training data",
  content: btoa(JSON.stringify(data)),
  sha: {current_sha}
}
```

### Important

- Always fetch current SHA before writing — stale SHA causes 409 conflict
- Debounce writes — don't hit the API on every keystroke, write after user action completes
- Cache data locally in memory during session, write to GitHub on change
- Handle offline gracefully — queue writes and sync when back online

-----

## App Features

### Five tabs

#### 1. Week

- Week navigation (previous/next week arrows)
- 7-day view showing each day's scheduled workout
- Mark workout done / unmark
- Session notes per day (expandable)
- Shows weight and shooting session indicators inline on each day

#### 2. Shooting

- Running stats: total sessions, total rounds fired, average group size
- Group size trend chart (SVG line chart, color-coded by rifle)
- Log range session form:
  - Date, rifle (dropdown), distance (dropdown)
  - Rounds fired, best group size in inches
  - Conditions (chip selector: Calm, Light Wind, Moderate Wind, Heavy Wind, Rain, Cold)
  - Cold bore toggle
  - Free-text notes
- Filter session history by rifle
- Delete sessions

#### 3. Weight

- Log weight by date
- Summary stats: current, starting, total change
- SVG line chart (last 60 entries)
- History list with day-over-day delta, delete entries

#### 4. Fitness Log

- Chronological list of all completed workout sessions
- Shows workout type, date, weight logged that day, session notes

#### 5. Plan

- 4-phase program overview with current phase highlighted
- Weekly structure reference

-----

## Training Program Constants

### Phases

|Phase|Months|Vest Weight|Focus                  |
|-----|------|-----------|-----------------------|
|1    |1–3   |15 lb      |Build the base         |
|2    |4–6   |20 lb      |Add intensity + incline|
|3    |7–9   |25 lb      |Go heavy               |
|4    |10–12 |35 lb      |Hunt ready             |

Phase advances automatically every 60 logged sessions.

### Weekly Schedule

|Day     |Workout                           |
|--------|----------------------------------|
|Mon–Fri |Weighted 5K + Legs                |
|Saturday|Long Effort (60–90 min trail ruck)|
|Sunday  |Rest / Mobility                   |

### Rifles

- Ridgeline 300 Win Mag
- Remington 783 30-06
- Mossberg 100 ATR 30-06
- 7mm Rem Mag

### Distances

50 yds, 100 yds, 200 yds, 300 yds, 400 yds

### Conditions

Calm, Light Wind, Moderate Wind, Heavy Wind, Rain, Cold

-----

## UI Design

### Color Palette

```
Background:     #0f1a0f
Surface:        #131f13
Surface raised: #1a2e1a
Border:         #1e2e1e / #2a3a2a
Border active:  #4a6741
Gold accent:    #8B6914
Green accent:   #6B9E5A
Text primary:   #e8d5a3 / #f0e6c8
Text secondary: #9aad8a / #c8b88a
Text muted:     #5a7a5a / #6a8a6a
Success green:  #6adf6a
Error red:      #df6a6a
```

### Typography

Georgia / Times New Roman serif throughout. Uppercase tracking for labels.

### Layout

- Mobile-first, full-width
- Sticky header + tab bar
- Safe area insets for iPhone notch/home bar
- No horizontal scroll except charts

-----

## Stats Bar (top of app, always visible)

|Stat        |Source                                 |
|------------|---------------------------------------|
|Days to Hunt|Countdown to Oct 3 2027                |
|Streak      |Consecutive non-rest days completed    |
|Rounds Fired|Sum of all shoot log rounds            |
|Best Group  |Min groupSize across all shoot sessions|

-----

## PWA Requirements

- `manifest.json` with name, short_name, icons, theme_color (#0f1a0f), background_color, display: standalone
- Service worker caching app shell for offline use
- `apple-mobile-web-app-capable` meta tag
- `apple-mobile-web-app-status-bar-style: black-translucent`
- Install prompt banner on Android

-----

## PIN Protection (optional but recommended)

Simple 4-digit PIN stored in localStorage. Shown on app open. Not cryptographic security — just prevents casual access if someone picks up the phone. Can be set/changed in a settings screen.

-----

## First-Run Flow

1. PIN setup screen (optional, can skip)
1. GitHub token entry screen
1. GitHub username + repo name entry
1. Token verification
1. data.json created in repo if not present
1. App loads normally

-----

## Existing Code Reference

A working React/JSX version of the full app exists from a prior Claude conversation. It uses `window.storage` (Claude artifact storage) instead of GitHub. The full component is available and can be used as a direct reference for UI structure, chart logic, and state management. Key difference for this build: replace all `window.storage` calls with GitHub Contents API read/write calls.

-----

## Deliverables

1. `index.html` — full app, single file preferred, or minimal file structure
1. `manifest.json` — PWA manifest
1. `sw.js` — service worker
1. `data.json` — empty initial data file (committed to repo as starting state)
1. `README.md` — setup instructions: how to create GitHub token, configure repo, deploy to GitHub Pages, add to home screen

-----

## Success Criteria

- App loads and works fully offline after first visit
- Data persists across sessions and phone upgrades via GitHub
- Installable to home screen on iPhone (Safari) and Android (Chrome)
- All five tabs functional with correct data persistence
- GitHub write conflicts handled gracefully (SHA management)
- Token never appears in committed code
