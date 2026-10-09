#!/usr/bin/env bash
# Deploy only the isolated AFTERHOURS Hosting site. Never deploy the default site.
set -euo pipefail
cd "$(dirname "$0")/.."
FIREBASE_BIN="${FIREBASE_BIN:-firebase}"
GODOT_BIN="${GODOT_BIN:-godot}"
if [[ "${1:-}" != "" && "${1:-}" != "--skip-build" ]]; then
  echo "Usage: $0 [--skip-build]" >&2
  echo "Set FIREBASE_BIN and GODOT_BIN when the CLIs are not on PATH." >&2
  exit 2
fi
if ! command -v "$FIREBASE_BIN" >/dev/null 2>&1; then
  echo "Firebase CLI not found. Set FIREBASE_BIN to your authenticated firebase executable." >&2
  exit 1
fi
if [[ "${1:-}" != "--skip-build" ]]; then
  if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
    echo "Godot not found. Set GODOT_BIN to the Godot 4.5 executable." >&2
    exit 1
  fi
  mkdir -p export/web
  "$GODOT_BIN" --headless --path . --editor --import --quit
  "$GODOT_BIN" --headless --path . --script tests/test_game.gd
  "$GODOT_BIN" --headless --path . --export-release Web export/web/index.html
fi
# The HTML shell refers to this ordinary image outside the Godot PCK archive.
mkdir -p export/web/assets
cp assets/title_art.png export/web/assets/title_art.png
for required in index.html index.js index.wasm index.pck assets/title_art.png; do
  if [[ ! -s "export/web/$required" ]]; then
    echo "Incomplete web export: $required is missing or empty." >&2
    exit 1
  fi
done
# Explicit project plus one deploy target prevents changes to existing sites,
# Functions, Authentication, Firestore, Storage, and other project services.
"$FIREBASE_BIN" deploy --only hosting:afterhours --project unpause-studio --config firebase.json
