#!/usr/bin/env bash

# Detects the current macOS user and exports machine-specific environment
# variables for Nix flake evaluation.
#
# Usage:
#   source scripts/machine-env.sh
#
# Must be sourced so the variables remain available to the calling shell.
# Nix reads them through builtins.getEnv, requiring --impure.

detect_mac_environment() {
  local username home_dir

  username="$(id -un)" || return 1
  home_dir="$HOME"

  MAC_USERNAME="$username"
  MAC_HOME="$home_dir"

  export MAC_USERNAME MAC_HOME
}

detect_mac_environment
