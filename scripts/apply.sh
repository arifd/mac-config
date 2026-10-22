#!/usr/bin/env bash
set -euo pipefail

# Be in repo root:
repository_root="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
cd "$repository_root"

# Ensure git and config are in sync:
untracked_files="$(git ls-files --others --exclude-standard)"
if [[ -n "$untracked_files" ]]; then
  printf 'Error: stage these untracked files before applying:\n%s\n' "$untracked_files" >&2
  exit 1
fi

# Run darwin-rebuild from the nix-darwin revision pinned for this configuration,
# keeping the activation tool aligned with the module version.
sudo -H \
  NIX_CONFIG="experimental-features = nix-command flakes" \
  MAC_USERNAME="$(id -un)" \
  MAC_HOME_DIRECTORY="$HOME" \
  nix run "github:nix-darwin/nix-darwin/c3e90c89649b07d1a96e4b9dd6cd0d6e44b91a74#darwin-rebuild" -- \
    switch --flake ".#default" --impure
