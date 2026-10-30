#!/usr/bin/env bash

# <swiftbar.title>CPU Monitor</swiftbar.title>
# <swiftbar.refreshOnOpen>false</swiftbar.refreshOnOpen>

script_path="$HOME/.config/swiftbar/plugins/${BASH_SOURCE[0]##*/}"

average_cpu() {
  local duration=${1:-30}

  for ((i = 0; i < duration; i++)); do
    ps -Ao pid=,%cpu=,comm=
    sleep 1
  done | LC_ALL=C awk -v duration="$duration" '
    {
      pid = $1
      cpu = $2

      $1 = $2 = ""
      sum[pid] += cpu
      names[pid] = substr($0, 3)
    }
    END {
      for (pid in sum)
        printf "%6.1f%%  %s\n", sum[pid] / duration, names[pid]
    }
  ' | LC_ALL=C sort -nr | head -n 15
}

show_dialog() {
  osascript \
    -e 'on run argv' \
    -e 'set report to item 1 of argv' \
    -e 'set dialogTitle to item 2 of argv' \
    -e 'set response to display dialog report with title dialogTitle buttons {"Copy", "OK"} default button "OK"' \
    -e 'if button returned of response is "Copy" then set the clipboard to report' \
    -e 'end run' \
    "$1" "$2"
}

if [[ ${1:-} == --diagnose ]]; then
  duration=30

  if report=$(average_cpu "$duration"); then
    show_dialog "$report" "Top CPU Processes — ${duration}s Average"
  else
    show_dialog "CPU sampling failed." "CPU Diagnosis Failed"
    exit 1
  fi

  exit 0
fi

cpu=$(
  top -l 1 -n 0 |
    LC_ALL=C awk '
      /CPU usage:/ {
        printf "%.0f", $3 + $5
        exit
      }
    '
)

percent=$(( cpu < 0 ? 0 : cpu > 100 ? 100 : cpu ))
bar=$(<"$HOME/.config/swiftbar/plugins/.bars/$percent.txt")

printf ' | font="JetBrainsMono Nerd Font" image=%s\n' "$bar"
printf '%s\n' '---' "CPU usage: ${cpu}%" '---'
printf 'Diagnose... | bash=/bin/bash param1="%s" param2=--diagnose terminal=false refresh=false\n' "$script_path"
