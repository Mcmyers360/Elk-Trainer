#!/usr/bin/env bash
# Elk Hunt Trainer — local server startup
# Run once to install the PWA on your phone, then the service worker handles offline.
#
# Prerequisites (one-time):
#   Mac:   brew install python3 ngrok
#   Win:   install Python from python.org, ngrok from ngrok.com
#
# Usage:  ./start.sh
# Then open the HTTPS URL printed by ngrok on your phone and install to home screen.

set -e

PORT=8080
DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "  Elk Hunt Trainer"
echo "  ─────────────────────────────────"
echo "  Serving from: $DIR"
echo "  Local:  http://localhost:$PORT"
echo ""

# Start Python file server in background
cd "$DIR"
python3 -m http.server $PORT &
SERVER_PID=$!

echo "  File server running (PID $SERVER_PID)"
echo ""

# Check for ngrok
if command -v ngrok &> /dev/null; then
  echo "  Starting ngrok HTTPS tunnel..."
  echo "  ─────────────────────────────────"
  echo "  → Open the https:// URL below on your phone"
  echo "  → Safari/Chrome: Share → Add to Home Screen"
  echo "  → After installing once, you never need this again"
  echo ""
  # ngrok prints its own URL; Ctrl-C kills both
  trap "kill $SERVER_PID 2>/dev/null; exit" INT TERM
  ngrok http $PORT
else
  echo "  ⚠  ngrok not found — running HTTP only."
  echo "  Service worker won't work from the phone without HTTPS."
  echo ""
  echo "  To install ngrok (free):"
  echo "    Mac:  brew install ngrok"
  echo "    Win:  download from https://ngrok.com/download"
  echo "          then: ngrok config add-authtoken <your-token>"
  echo ""
  echo "  Without ngrok: open http://localhost:$PORT in your local browser only."
  echo "  Press Ctrl-C to stop."
  echo ""
  wait $SERVER_PID
fi
