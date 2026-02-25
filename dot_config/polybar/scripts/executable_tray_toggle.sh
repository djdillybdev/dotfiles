#!/usr/bin/env bash
set -u

state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/polybar-scripts"
state_file="$state_dir/tray_toggle.lock"

icon_shown='>>'
icon_hidden='>>'

mkdir -p "$state_dir"

read_state() {
  if [[ -f "$state_file" ]]; then
    cat "$state_file"
    return
  fi

  if [[ "${START_TRAY_HIDDEN:-true}" == "true" ]]; then
    echo "hidden"
  else
    echo "shown"
  fi
}

write_state() {
  printf '%s' "$1" >"$state_file"
}

show_tray() {
  polybar-msg action "#tray.module_show" >/dev/null 2>&1 || true
  write_state "shown"
  echo "$icon_shown"
}

hide_tray() {
  polybar-msg action "#tray.module_hide" >/dev/null 2>&1 || true
  write_state "hidden"
  echo "$icon_hidden"
}

toggle() {
  if [[ "$(read_state)" == "hidden" ]]; then
    show_tray
  else
    hide_tray
  fi
}

trap 'toggle' USR1

if [[ "$(read_state)" == "hidden" ]]; then
  hide_tray
else
  show_tray
fi

while :; do
  sleep 3600 &
  wait $!
done
