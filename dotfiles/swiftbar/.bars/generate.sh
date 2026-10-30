#!/usr/bin/env bash
set -euo pipefail

# Requires rsvg-convert to be available in PATH.

OUTPUT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

for percent in {0..100}; do
  height=$(( 10 * percent / 100 ))
  y=$(( 12 - height ))

  cat <<EOF | rsvg-convert -f png | base64 | tr -d '\n' > "$OUTPUT_DIR/$percent.txt"
<svg xmlns="http://www.w3.org/2000/svg"
     width="8" height="14" viewBox="0 0 8 14">
  <rect x="1.5" y="0.5" width="5" height="13"
        rx="1.5" fill="none" stroke="#888"
        stroke-width="1"/>
  <rect x="2.5" y="$y" width="3" height="$height"
        rx="0.5" fill="#FFFFFF"/>
</svg>
EOF
done

echo "Generated 101 images in $OUTPUT_DIR"
