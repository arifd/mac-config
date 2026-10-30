{
  description = "Arif's Personal macOS configuration";

  inputs = {
    # Keep the release suffixes below aligned. Bump them manually once matching
    # releases exist for all three projects. Check https://status.nixos.org/ for
    # Nixpkgs, then confirm nix-darwin-<release> and release-<release> branches
    # exist upstream before changing these URLs and running `nix flake update`.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Configure macOS system settings and system-wide packages
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Configure the user environment
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Use this package set in overlays for packages newer than the main release.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      # Paths to local files
      dotfiles = ./dotfiles;
      assets = ./assets;
      programs = ./programs;
    in
    {
      # macOS system configuration
      darwinConfigurations.default = nix-darwin.lib.darwinSystem {
        # Pass machine context to the integration modules
        specialArgs = {
          inherit dotfiles assets programs;
          username = builtins.getEnv "MAC_USERNAME";
          homeDirectory = builtins.getEnv "MAC_HOME_DIRECTORY";
        };

        modules = [
          # Integrate Home Manager into nix-darwin
          home-manager.darwinModules.home-manager

          # nix-darwin and Home Manager setup
          (
            {
              username,
              homeDirectory,
              dotfiles,
              assets,
              programs,
              ...
            }:
            {
              homebrew.enable = true;

              # Preserve nix-darwin's compatibility defaults from the initial setup
              system.stateVersion = 6;

              # Ensure this file exists before nix-darwin's createRun activation step.
              system.activationScripts.preActivation.text = ''
                if [[ ! -e /etc/synthetic.conf ]]; then
                  touch /etc/synthetic.conf
                fi
              '';

              nixpkgs.overlays = [ (import ./overlays/swift.nix { inherit nixpkgs; }) ];

              nixpkgs.hostPlatform = "aarch64-darwin";
              system.primaryUser = username;
              users.users.${username}.home = homeDirectory;

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit dotfiles assets programs; };

              # Preserve Home Manager's compatibility defaults from the initial setup
              home-manager.users.${username}.home.stateVersion = "26.05";
            }
          )
        ]
        # Load every Nix module recursively from the modules directory
        ++ (
          let
            modulesIn =
              directory:
              let
                entries = builtins.readDir directory;
              in
              builtins.concatMap (
                name:
                let
                  path = directory + "/${name}";
                  type = entries.${name};
                in
                if type == "directory" then
                  modulesIn path
                else if (type == "regular" || type == "symlink") && builtins.match ".*\\.nix" name != null then
                  [ path ]
                else
                  [ ]
              ) (builtins.attrNames entries);
          in
          modulesIn ./modules
        );
      };
    };
}
