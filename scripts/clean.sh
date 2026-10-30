#!/usr/bin/env bash
set -euo pipefail

repository_root="$(git -C "$(dirname "${BASH_SOURCE[0]}")/.." rev-parse --show-toplevel)"

find "$repository_root" \
  -type d -name .git -prune \
  -o -type d \( -name .build -o -name target \) -prune \
  -exec rm -rf {} +
