#!/usr/bin/env bash

total=$(sysctl -n hw.memsize)

percent=$(
  vm_stat | LC_ALL=C awk -v total="$total" '
    /page size of/                   { page_size = $8  }
    /Pages active:/                  { active = $3     }
    /Pages wired down:/              { wired = $4      }
    /Pages occupied by compressor:/  { compressed = $5 }

    END {
      used = (active + wired + compressed) * page_size
      printf "%.0f", used / total * 100
    }
  '
)

percent=$(( percent < 0 ? 0 : percent > 100 ? 100 : percent ))
bar=$(<"$HOME/.config/swiftbar/plugins/.bars/$percent.txt")

printf ' | font="JetBrainsMono Nerd Font" image=%s\n' "$bar"
printf '%s\n' '---' "RAM usage: ${percent}%"
