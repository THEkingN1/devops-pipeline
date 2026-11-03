#!/usr/bin/env bash
# Manual rollback: switch back to the previous (idle) slot.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROD="$ROOT/production"
PORT="${PORT:-5000}"
ACTIVE="$(cat "$PROD/active_slot")"
if [ "$ACTIVE" = "blue" ]; then PREV="green"; else PREV="blue"; fi
[ -d "$PROD/$PREV/app" ] || { echo "No previous release to roll back to"; exit 1; }
[ -f "$PROD/app.pid" ] && kill "$(cat "$PROD/app.pid")" 2>/dev/null || true
sleep 1
cd "$PROD/$PREV"
PORT="$PORT" nohup python -m app.app > "$ROOT/logs/app_$PREV.out" 2>&1 < /dev/null &
echo $! > "$PROD/app.pid"
cd "$ROOT"
echo "$PREV" > "$PROD/active_slot"
ln -sfn "$PROD/$PREV" "$PROD/current"
echo "$(date -u +%FT%TZ) MANUAL_ROLLBACK to=$PREV" >> "$ROOT/logs/health.log"
echo "Rolled back to $PREV"
