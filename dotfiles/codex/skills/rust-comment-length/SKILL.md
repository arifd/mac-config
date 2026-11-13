---
name: rust-comment-length
description: Check and fix Rust comment line-length violations.
---

# Rust comment length

Ensure that Rust line comments do not exceed 80 characters.

## Procedure

Run `check.sh` from the root of the repository being modified.

Fix every violation reported by the checker.

When fixing comments:

- preserve the comment kind (`//`, `///`, or `//!`);
- preserve indentation;
- preserve meaning;
- preserve Markdown structure in documentation comments;
- reflow prose at natural boundaries rather than mechanically splitting at
  column 80;
- do not modify Rust code solely to make a comment shorter.

Run `check.sh` again after making changes.

The task is complete only when `check.sh` exits successfully.
