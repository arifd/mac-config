#!/usr/bin/zsh

# degit - Download GitHub repositories or subdirectories.
#
# Extends degit to accept standard GitHub tree URLs copied from
# the browser, converting them into degit's supported syntax.
#
# Usage:
#   degit <source> [destination]
degit() {
  local source="$1"
  shift

  if [[ "$source" =~ ^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.*)$ ]]; then
    source="${match[1]}/${match[2]}/${match[4]}#${match[3]}"
  fi

  command degit "$source" "$@"
}
