#!/usr/bin/env bash
# Usage: health_check.sh [URL]   -> appends result to logs/health.log, exit 1 if DOWN
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
URL="${1:-http://127.0.0.1:5000/health}"
LOG="$ROOT/logs/health.log"
mkdir -p "$ROOT/logs"
CODE="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$URL" || true)"
TS="$(date -u +%FT%TZ)"
if [ "$CODE" = "200" ]; then
  echo "$TS UP url=$URL http=$CODE" | tee -a "$LOG"; exit 0
else
  echo "$TS DOWN url=$URL http=${CODE:-000}" | tee -a "$LOG"; exit 1
fi
