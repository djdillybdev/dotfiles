#!/usr/bin/env bash
set -euo pipefail

wait_for_polybar_exit() {
  local wait_seconds="${1:-5}"
  local elapsed=0
  while pgrep -u "${UID}" -x polybar >/dev/null 2>&1; do
    if [[ "$elapsed" -ge "$wait_seconds" ]]; then
      return 1
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done
  return 0
}

# Graceful quit via IPC when available
if command -v polybar-msg >/dev/null 2>&1; then
  polybar-msg cmd quit >/dev/null 2>&1 || true
fi

if ! wait_for_polybar_exit 5; then
  killall -q polybar || true
  if ! wait_for_polybar_exit 5; then
    echo "WARN: polybar instances did not fully exit before relaunch" >&2
  fi
fi

if command -v xrandr >/dev/null 2>&1; then
  # Launch top bar on each connected monitor
  while IFS= read -r monitor; do
    MONITOR="$monitor" polybar --reload top &
  done < <(xrandr --query | awk '/ connected/{print $1}')
else
  polybar --reload top &
fi

echo "Bars launched..."
