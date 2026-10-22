# Lightweight Fuzzy App Launcher

## Summary

Build a small native Swift launcher, package it with the repo’s pinned Nix toolchain, and start it at login. It will search installed app bundles directly, without querying Spotlight or maintaining a separate index.

## Stages:

- First understand how swift/xcode projects work and what I need to builld a minimal terminal app.

- Create the fuzzy search ranking within one folder tree algorithm. test it in the terminal

- Then have compile time configurable paths and have it return entry along with app icon. (the program assumes it only searches for apps)

- Then create the GUI. it must look exactly as Spotlight. `Return` launches app (and hides GUI), Arrow keys to navigate` `Esc` quits or hides.

-- 

Now we need to package.

Home manger should pass in the paths, it will pass in `/Applications`, `/Applications/Utilities`, `/System/Applications`, `/System/Applications/Utilities`, `~/Applications`, and the Home Manager app profile.

Home manger will set up the `⌥⌘Space` shortcut

This repo should build/cache/gitignore configure and deploy.

## Implementation

- Vendor a dependency-free Swift package. Build its executable and assemble a `.app` bundle in a Darwin Nix derivation using the pinned Nixpkgs Swift toolchain and Apple SDK.
- Use AppKit for a compact palette showing ranked app names and icons. Match app names with a simple subsequence fuzzy matcher; use `⌘Space` to show the palette, arrow keys to select, `Return` to launch, and `Escape` to dismiss. Launch apps through Apple’s `NSWorkspace` (https://developer.apple.com/documentation/appkit/nsworkspace).
- Discover apps from `/Applications`, `/Applications/Utilities`, `/System/Applications`, `/System/Applications/Utilities`, `~/Applications`, and the Home Manager app profile. But allow the list of paths to be compile-tiem configurable. We'll then pass in locations at compile time. Scan when opening the palette, skip descending into `.app` bundles, and deduplicate results.
- Install the bundle through Home Manager and run it as a user launch agent at login. Register `⌘Space` with Carbon; the existing config already disables Spotlight’s `⌘Space` hotkey. Keep Finder’s `⌥⌘Space` shortcut unchanged.
- Keep the launcher app-only: no file search, Spotlight queries, clipboard, extensions, or third-party runtime dependencies. Apple documents app launching through `NSWorkspace`; the pinned Nixpkgs Swift package (https://github.com/NixOS/nixpkgs/blob/nixos-26.05/pkgs/development/compilers/swift/default.nix) provides a Nix-managed compiler.

## Acceptance Checks

- The Nix derivation builds the `.app` bundle, and Home Manager installs it and starts the launch agent.
- `⌘Space` opens the palette with focus in the search field; matching, arrow navigation, `Return`, and `Escape` behave as specified.
- Fuzzy queries find apps in each configured location, including the Home Manager profile; newly installed apps appear on the next palette opening.
- Confirm the launcher makes no Spotlight queries and keeps no app index on disk.

## Assumptions

- The app catalog includes both Apple’s system apps and user-installed apps.
- The Nix build uses the pinned Nixpkgs compiler and Darwin SDK, rather than relying on the host’s Xcode Swift compiler.
- Keep the implementation to the launcher essentials; no usage history or customization UI.
