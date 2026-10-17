#!/usr/bin/env bash
set -euo pipefail

# Be in repo root:
cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

untracked_files="$(git ls-files --others --exclude-standard)"
if [[ -n "$untracked_files" ]]; then
  printf 'Error: stage these untracked files before applying:\n%s\n' "$untracked_files" >&2
  exit 1
fi

# Export the current user's name and home directory for flake evaluation.
source ./scripts/machine-env.sh

# Nix needs these features enabled before it can evaluate the flake.
# nix-core.nix declares them for the managed system, but that configuration
# takes effect only after activation.
NIX_CONFIG="experimental-features = nix-command flakes"

# Build the system configuration declared by this flake.
# This makes darwin-rebuild available even on the first run, and uses this
# repository's flake inputs rather than a separately selected nix-darwin version.
NIX_CONFIG="$NIX_CONFIG" \
  nix build .#darwinConfigurations.default.system --impure

# Activate the built configuration.
sudo \
  NIX_CONFIG="$NIX_CONFIG" \
  MAC_USERNAME="$MAC_USERNAME" \
  MAC_HOME="$MAC_HOME" \
  ./result/sw/bin/darwin-rebuild switch --flake ".#default" --impure
