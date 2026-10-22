---
name: mac-config-keybindings-review
description: Audit the current macOS configuration for keybinding conflicts with each other, macOS shortcuts, or application shortcuts, regardless of changes or worktree state. Use when asked to review keybindings in this repository.
---

Audit the repository's current keybinding configuration in full, regardless of whether the worktree is clean or which files changed. Do not limit the review to a diff. Find and read all relevant keybinding declarations and application configuration before evaluating the current state.

Check for these issues:

- Check all keybindings against other bindings in this repository, including bindings declared in different files or application layers when both can be active together.
- Check whether they override or conflict with standard macOS shortcuts or the affected application's established shortcuts.
- Consider the application and context in which each binding is active. Identical chords in mutually exclusive contexts are not necessarily conflicts.
- Verify uncertain standard shortcuts from authoritative documentation or application configuration when practical. Do not present a guess as a confirmed conflict.
- Report the conflicting chord, the actions it triggers, the relevant contexts, and the files or documentation supporting the finding.

Report actionable findings first, with severity and file/line references. If there are no concrete issues, say so briefly. Do not expand the review into unrelated concerns.
