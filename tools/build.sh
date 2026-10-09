#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT_BIN="${GODOT_BIN:-godot}"
mkdir -p export/web export/windows export/linux
"$GODOT_BIN" --headless --path . --editor --import --quit
"$GODOT_BIN" --headless --path . --script tests/test_game.gd
"$GODOT_BIN" --headless --path . --export-release Web export/web/index.html
mkdir -p export/web/assets
cp assets/title_art.png export/web/assets/title_art.png
"$GODOT_BIN" --headless --path . --export-release macOS export/Afterhours-macOS.zip
"$GODOT_BIN" --headless --path . --export-release Windows export/windows/Afterhours.exe
"$GODOT_BIN" --headless --path . --export-release Linux export/linux/Afterhours.x86_64
