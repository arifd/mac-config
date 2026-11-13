#!/usr/bin/env bash
set -euo pipefail

# This script can be replaced with rustfmt when the feature becomes stable.
# https://github.com/rust-lang/rustfmt/issues/3349

# Find comments exceeding 80 graphemes
! rg --no-heading '^[[:space:]]*//.{79,}' -g '*.rs' -g '!target/' -n
