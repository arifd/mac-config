#!/usr/bin/env bash

gpu=$(
  ioreg -r -c IOAccelerator -d 1 -l |
    LC_ALL=C rg -o -m 1 -r '$1' '"Device Utilization %"=([0-9]+)'
)

if [[ -z $gpu ]]; then
  printf ' N/A | font="JetBrainsMono Nerd Font"\n'
  printf '%s\n' '---' 'GPU usage unavailable'
  exit 0
fi

percent=$(( gpu < 0 ? 0 : gpu > 100 ? 100 : gpu ))
bar=$(<"$HOME/.config/swiftbar/plugins/.bars/$percent.txt")

printf ' | font="JetBrainsMono Nerd Font" image=%s\n' "$bar"
printf '%s\n' '---' "GPU usage: ${gpu}%"
