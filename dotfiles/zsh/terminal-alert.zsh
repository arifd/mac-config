#!/usr/bin/env zsh

# Plays a notification sound when a long running terminal command has completed.
#
# This script must be sourced from .zshrc (or via Home Manager), rather
# than executed directly, so the hooks are registered in the current shell.

# Load Zsh's hook registration utility for registering callbacks without
# replacing existing hooks.
autoload -Uz add-zsh-hook

# Records the start time of each command (in seconds since shell startup).
terminal_alert_start() {
  TERMINAL_ALERT_START=$SECONDS
}

# Plays an alert if the previous command exceeded the threshold.
terminal_alert_finish() {
  local threshold_secs=10

  if [[ -n "$TERMINAL_ALERT_START" ]] &&
    (( SECONDS - TERMINAL_ALERT_START >= threshold_secs )); then
    # Play asynchronously so the prompt is not blocked.
    /usr/bin/afplay /System/Library/Sounds/Glass.aiff &!
  fi

  unset TERMINAL_ALERT_START
}

# Register hooks without overriding other Zsh integrations.
add-zsh-hook preexec terminal_alert_start
add-zsh-hook precmd terminal_alert_finish
