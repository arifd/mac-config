---
name: mac-config-colors-review
description: Audit the current macOS configuration for inconsistent or clashing color choices, regardless of changes or worktree state. Use when asked to review colors, themes, or visual palettes in this repository.
---

Audit the repository's current color configuration in full, regardless of whether the worktree is clean or which files changed. Do not limit the review to a diff. Find and read all relevant color definitions, themes, and related configuration before evaluating the current state.

Check for these issues:

- Check whether related color values follow a consistent palette across affected applications and configuration files.
- Check whether foreground, background, accent, selection, and status colors work well together and remain distinguishable where that matters.
- Compare with existing themes and color conventions in the repository before suggesting changes. Treat intentional differences between applications as valid when the configuration supports that interpretation.
- Report only concrete inconsistencies or combinations likely to reduce readability or create a visibly clashing palette. Include the relevant file and setting, and explain the visual or consistency issue.

Report actionable findings first, with severity and file/line references. If there are no concrete issues, say so briefly. Do not expand the review into unrelated concerns.
