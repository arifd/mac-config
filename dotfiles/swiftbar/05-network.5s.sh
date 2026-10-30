#!/usr/bin/env bash

print() {
  local up="$1"
  local down="$2"
  local font="JetBrainsMono Nerd Font"

  printf ' %s  %s | font="%s"\n' "$up" "$down" "$font"
  printf '%s\n' '---' "Upload: ${up} MiB/s" "Download: ${down} MiB/s"
}

interface=$(
  route -n get default 2>/dev/null |
    awk '/interface:/ { print $2; exit }'
)

if [[ -z $interface ]]; then
  print "--" "--"
  exit 0
fi

read_bytes() {
  netstat -b -I "$interface" |
    awk 'NR == 2 { print $7, $10; exit }'
}

read -r rx1 tx1 < <(read_bytes)
sleep 1
read -r rx2 tx2 < <(read_bytes)

read -r down up < <(
  LC_ALL=C awk \
    -v rx1="$rx1" -v rx2="$rx2" \
    -v tx1="$tx1" -v tx2="$tx2" '
      BEGIN {
        printf "%.1f %.1f\n",
          (rx2 - rx1) / 1048576,
          (tx2 - tx1) / 1048576
      }
    '
)

print "$up" "$down"
