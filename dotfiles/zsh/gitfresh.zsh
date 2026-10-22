#!/usr/bin/env zsh

# gitfresh — Reinitialize the current directory as a fresh Git repository.
#
# Deletes existing Git history, preserves working files, and creates
# an initial commit. Excludes .notes/ locally without .gitignore.
#
# Usage:
#   gitfresh [-y|--yes]
gitfresh() {
  local force=false
  local root

  while (( $# > 0 )); do
    case "$1" in
      -y|--yes)
        force=true
        ;;
      *)
        print -u2 "Usage: gitfresh [-y|--yes]"
        return 2
        ;;
    esac
    shift
  done

  # Refuse to operate inside an existing repository's subdirectory.
  if root=$(git rev-parse --show-toplevel 2>/dev/null); then
    if [[ "$PWD:A" != "$root:A" ]]; then
      print -u2 "Error: Run gitfresh from the repository root: $root"
      return 1
    fi
  fi

  # Refuse linked worktrees and submodules with .git files.
  if [[ -f .git ]]; then
    print -u2 "Error: .git is a file, not a directory."
    return 1
  fi

  # Confirm before deleting existing Git history.
  if [[ -d .git ]]; then
    print -P "%F{yellow}Warning:%f Git history in $PWD will be deleted."
    if [[ "$force" != true ]]; then
      read -q "?Continue? [y/N] " || { echo; return 1; }
      echo
    fi
    rm -rf -- .git || return
  fi

  git init || return
  print -r -- ".notes/" >> .git/info/exclude

  git add . || return
  git commit -m "Initial commit"
}
