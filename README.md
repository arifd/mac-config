# mac-config

My personal macOS configuration managed with Nix, nix-darwin, and Home Manager.

## Principle

This repository is the source of truth for configuration it manages. It assumes
that conflicting manual configuration will be removed or migrated into this
repository, rather than merged automatically.

For example, Home Manager manages the user's Zsh configuration. Before the
first activation, move any existing `~/.zshrc` out of the way. Then add any
settings you want to keep to this repository.

Nix can install packages alongside versions installed by other tools. It does
not remove those other installations. As part of migrating a package into this
configuration, remove its existing installation manually if you want only the
Nix-managed version.

## Prerequisites

**Only Nix needs to be installed manually.**

Nix uses the dependencies declared in `flake.nix` to fetch and manage nix-darwin,
Home Manager, and nixpkgs automatically. There is no need to install these tools
separately.

Install Nix using the [official installation instructions](https://nixos.org/download/),
ensuring flakes are enabled.

## Apply the configuration

To bootstrap or after any change to this repository, run:

```bash
./scripts/apply.sh
```
