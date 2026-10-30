#!/usr/bin/env zsh

# Override the standard `clear` command to also clear terminal scrollback.
#
# The default `clear` command clears the visible screen but preserves previous
# output in the terminal's scrollback buffer.
function clear() {
  printf '\033[H\033[2J\033[3J'
}
