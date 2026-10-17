#!/usr/bin/env bash

used=$(
  df -P /System/Volumes/Data |
    LC_ALL=C awk 'NR == 2 { print $5 + 0; exit }'
)

percent=$(( used < 0 ? 0 : used > 100 ? 100 : used ))
bar=$(<"$HOME/.config/swiftbar/plugins/.bars/$percent.txt")

printf ' | font="JetBrainsMono Nerd Font" image=%s\n' "$bar"
printf '%s\n' '---' "Macintosh HD: ${used}% used"
