# mac-config

My personal and declarative macOS configuration, managed with Nix.

## Prerequisites

**Only Nix needs to be installed manually.**

Nix is used to manage all parts of configuring the system.

Install Nix using the [official installation instructions](https://nixos.org/download/)

## Apply the configuration

To bootstrap or after any change to this repository, run:

```bash
./scripts/apply.sh
```

## Overview

- `.codex/` — repository-specific skills.
- `assets/` — static assets used by the configuration.
- `dotfiles/` — native application configuration files.
- `modules/` — Nix modules that configure macOS, install software, and set up applications.
- `overlays/` — package overrides and additions used by the Nix configuration.
- `patches/` — custom patches for upstream projects.
- `programs/` — custom software built and installed with the configuration.
- `scripts/` — commands to manage the repository.
