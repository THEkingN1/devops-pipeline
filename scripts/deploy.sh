#!/usr/bin/env bash
# Blue-Green deployment into a local "production" folder with automatic rollback.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROD="$ROOT/production"
PORT="${PORT:-5000}"
URL="http://127.0.0.1:$PORT/health"
mkdir -p "$PROD" "$ROOT/logs"

ACTIVE="$(cat "$PROD/active_slot" 2>/dev/null || echo none)"
if [ "$ACTIVE" = "blue" ]; then TARGET="green"; else TARGET="blue"; fi
echo "[deploy] active=$ACTIVE target=$TARGET"

stop_server() {
  if [ -f "$PROD/app.pid" ]; then
    kill "$(cat "$PROD/app.pid")" 2>/dev/null || true
    rm -f "$PROD/app.pid"; sleep 1
  fi
}

start_slot() {
  cd "$PROD/$1" || return 1
  PORT="$PORT" APP_VERSION="${APP_VERSION:-1.0.0}" nohup python -m app.app > "$ROOT/logs/app_$1.out" 2>&1 < /dev/null &
  echo $! > "$PROD/app.pid"
  cd "$ROOT"
}

# 1. copy the new release into the idle slot
rm -rf "$PROD/$TARGET"; mkdir -p "$PROD/$TARGET"
cp -r "$ROOT/app" "$PROD/$TARGET/app"

# 2. switch the running server to the new slot
stop_server
start_slot "$TARGET"

# 3. health check with retries
for i in 1 2 3 4 5 6 7 8 9 10; do
  if curl -fsS "$URL" > /dev/null 2>&1; then OK=1; break; fi
  OK=0; sleep 1
done

if [ "${OK:-0}" = "1" ]; then
  echo "$TARGET" > "$PROD/active_slot"
  ln -sfn "$PROD/$TARGET" "$PROD/current"
  echo "[deploy] SUCCESS: $TARGET is live"
  bash "$ROOT/scripts/health_check.sh" "$URL" || true
  exit 0
fi

# 4. automatic rollback
echo "[deploy] HEALTH CHECK FAILED -> rollback"
echo "$(date -u +%FT%TZ) DEPLOY_FAILED target=$TARGET rollback_to=$ACTIVE" >> "$ROOT/logs/health.log"
stop_server
if [ "$ACTIVE" != "none" ]; then start_slot "$ACTIVE"; echo "[deploy] rolled back to $ACTIVE"; fi
exit 1
