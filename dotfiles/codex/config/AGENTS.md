# AGENTS.md

## Communication Style

- Be concise. Prioritize clarity and brevity over perfect grammar.
- Avoid unnecessary explanations, repetition, and filler.
- Never sacrifice technical accuracy or important details for brevity.

## General style

Prefer code that reads declaratively from top to bottom.

A reader should be able to understand the conceptual phases of a function by
skimming:

- type and function names,
- doc comments,
- high-level comments,
- and the structure of the code,

without having to mentally execute every statement.

Favor explicit, straightforward code over clever or highly compressed code.

Respect established codebase conventions unless they conflict with an explicit
requirement or materially harm clarity. Avoid introducing stylistic
inconsistency in unrelated code.

Do not introduce abstractions merely to reduce line count. Extract helpers when
they:

- name a meaningful concept,
- isolate a distinct invariant,
- remove incidental mechanics from the main flow,
- or make the caller read more like a specification.

Avoid helpers that merely hide simple syntax or make important domain behavior
harder to see.

## Declarative structure

Structure code around conceptual steps rather than incidental operations.

A substantial function should read like a sequence of meaningful phases, for
example:

```text
validate input
derive required information
transform the data
validate resulting invariants
construct the result
```

Use short comments to mark these phases when a function contains mulltiple
phases, or the phase is not immediately obvious from its function name.

## Comments and documentation

Document the "why" more than the "what."

Useful documentation explains:

- what a concept represents,
- what assumptions are valid,
- what invariants hold,
- why a design choice exists,
- or why an apparently simpler alternative is incorrect.

Avoid documentation that merely restates the identifier or type.

Good:

```rust
/// A validated representation of a configuration.
///
/// Construction guarantees that every referenced service exists, so consumers
/// do not need to perform that validation again.
```

Weak:

```rust
/// The configuration.
```

For non-obvious private helpers, document their contract when the name and
signature are not enough.

Delete stale comments rather than preserving commentary that no longer matches
the code.

## Data modelling

Prefer types that encode meaningful distinctions in the domain.

If a struct represents an important concept, document what that concept is and
what guarantees instances of the type provide.

Do not treat internal types as anonymous bags of fields.

Prefer representations that make invalid or ambiguous states harder to express
when doing so remains simple and readable.

Use ownership directly when ownership is available. Avoid cloning or copying
merely because it is convenient if the value can naturally be moved.

Do not complicate ownership solely to avoid a small clone when the resulting
code would become harder to understand. Clarity still takes precedence.

## Tests

Tests should document behavioral contracts, not implementation trivia.

Group cases together when they exercise the same rule.

Keep unrelated behaviors in separate tests so failures communicate what broke.

Prefer a small number of strong tests over many weak tests that assert
implementation details.

Test observable semantics and important invariants rather than incidental
internal structure.

Use test helpers to remove repetitive mechanics, but keep the behavior being
tested visible.

Do not build a custom test framework for a small test suite.

Test code is still code, and should have the same standards applied to the rest
of the production codebase.

Asserts in tests, especially when there are multiple, should have a comment
explaining what the particular assert is checking. Assert comments should begin
with `Check` and end with a colon, for example:

```rust
// Check unknown fields are preserved during a round trip:
assert_eq!(decoded.extra, original.extra);
```

A comment may be omitted when the test contains a single assert, or when what
the assert checks is otherwise obvious or identical to the name of the test.

## Refactoring

When changing existing code, preserve behavior unless behavior change is part of
the task.

Keep changes focused on the requested task. Avoid unrelated cleanup or
refactoring unless necessary for correctness.

Refactor in this order:

1. Clarify names.
1. Clarify conceptual structure.
1. Make data flow and ownership obvious.
1. Improve documentation of invariants and intent.
1. Strengthen tests around behavior.
1. Introduce abstractions only where they now clearly improve the design.

Do not refactor merely to make code look more sophisticated.

Prefer code that is easy to audit and change later over code that demonstrates
advanced technique.

## Naming

Prefer names that describe domain meaning rather than implementation context.

## Decision rule

When in doubt, choose the version that a competent engineer unfamiliar with the
codebase is more likely to understand correctly on the first read.

Favor:

- clarity over cleverness,
- domain language over generic terminology,
- visible behavior over indirection,
- meaningful structure over brevity,
- and simple abstractions over speculative generality.

## Technology-specific standards

Additional standards are available in the `standards/` directory.

The standards directory is at `~/.codex/standards/`. Expand `~` to the current
user’s home directory when locating it. Before modifying code, identify the
relevant technologies and read any matching standards from that directory.

In your response, name the standards you read. If you cannot locate this
directory or find no relevant standards, say so and explain what prevented
discovery.

Multiple standards may apply to the same task.
