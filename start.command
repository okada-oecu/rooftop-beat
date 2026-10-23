#!/bin/bash
# Double-click to play Rooftop Beat locally: starts a small web server in this folder and opens the game.
cd "$(dirname "$0")" || exit 1
PORT=8765
echo "Rooftop Beat: http://localhost:$PORT/"
echo "このウィンドウを閉じると止まります。"
( sleep 1; open "http://localhost:$PORT/" ) &
exec python3 -m http.server "$PORT"
