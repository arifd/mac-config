---
name: code-review
description: Review code for correctness, simplicity, clarity, maintainability, and fit with the surrounding codebase. By default, review the current branch against main or master. Do not modify code.
---

# Code Review

Review code critically and constructively. Identify real problems and meaningful
opportunities for improvement, not as many comments as possible.

This is a review-only task. You may inspect files, use non-destructive Git
commands, run tests, and perform other safe verification. Never modify the
codebase or apply fixes.

## Scope

Unless instructed otherwise, review the current branch against the repository's
default branch, typically `main` or `master`.

Use the merge base to identify changes introduced by the current branch. Include
relevant uncommitted changes.

Read surrounding code and documentation as needed to understand the changes, but
focus findings on problems introduced by the reviewed code rather than unrelated
existing issues.

If the requested scope or comparison base is ambiguous, use reasonable judgment
and state any important assumptions.

## Review priorities

Consider the following, roughly in order of importance.

### Correctness

Determine what the code is intended to do and whether it actually does it.

Look for bugs, incorrect assumptions, missing edge cases, failure modes, state
inconsistencies, and surprising behavior.

Do not assume passing tests imply correctness. Do not invent requirements when
intent is unclear.

### Implementation

Prefer the simplest implementation that clearly expresses the intended behavior.

Look for unnecessary complexity, over-engineering, excessive indirection,
unjustified abstractions, duplication, and convoluted control flow.

Value abstractions when they genuinely simplify reasoning or establish useful
boundaries. Prefer removing complexity over merely reorganizing it.

Do not suggest changes solely because you would have implemented something
differently.

### Documentation

Documentation should help a capable reader understand things that are not
obvious from the code.

Look for missing explanations of contracts, invariants, assumptions, side
effects, and non-obvious behavior, as well as stale, redundant, or misleading
comments.

Prefer self-explanatory code over excessive documentation.

### Naming

Names should be clear, concise, intuitive, domain-appropriate, and consistent
with the surrounding codebase.

Flag naming only when it meaningfully affects understanding.

### Tests

Evaluate whether tests provide meaningful confidence in the intended behavior.

Look for important missing coverage, weak assertions, untested failure paths,
and tests coupled unnecessarily to implementation details.

Recommend tests when they protect against plausible regressions, not
mechanically.

### Codebase fit

Evaluate changes in the context of the existing system.

Prefer established concepts, conventions, and utilities where appropriate. Avoid
unnecessary coupling, inconsistent patterns, and redundant alternatives.

Consistency matters, but should not justify a clearly worse design.

### Other concerns

Surface concrete security, performance, resource management, dependency, or
compatibility issues when relevant.

Avoid speculative concerns without a plausible impact.

## Review principles

- Understand the intent and surrounding context before judging the
  implementation.
- Trace relevant behavior rather than reviewing isolated lines.
- Verify assumptions through code inspection or safe execution when useful.
- Distinguish actual problems from stylistic preferences.
- Prefer high-confidence, high-value findings over exhaustive commentary.
- Consider the concrete consequence of each finding and whether the proposed
  alternative is meaningfully better.
- Apply the same standards you would when reviewing code written by a capable
  human engineer.

## Findings

Present findings in order of importance.

For each finding, include:

- **Severity:** `critical`, `major`, `minor`, or `suggestion`
- **Location:** relevant file, line, or symbol
- **Issue:** what is wrong
- **Impact:** why it matters
- **Recommendation:** how it could be improved

Use severity proportionately. Reserve `critical` for severe failures, `major`
for significant correctness or design problems, `minor` for limited but real
issues, and `suggestion` for worthwhile non-essential improvements.

Do not manufacture findings or repeat the same underlying issue in different
forms.

## Output

Start with findings, ordered by severity. Omit categories without meaningful
findings.

Finish with a brief overall assessment, including the scope reviewed, relevant
verification results, and important uncertainties.

If there are no meaningful findings, say so explicitly.

## Constraints

You may inspect the repository, run non-mutating Git operations, execute tests,
and perform safe analysis.

Do not edit files, apply fixes, change branches, alter Git history or staging,
or perform destructive operations.

Verification tools may produce incidental temporary artifacts, but must not
overwrite existing work or intentionally modify tracked files. Avoid commands
with uncertain or unsafe side effects.

The deliverable is the review, not a modified codebase.
