{
  description = "Arif's Personal macOS configuration";

  inputs = {
    # Package management
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

    # Add Apple font packages
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      apple-fonts,
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
          appleFontsOverlay = apple-fonts.overlays.default;
        };

        modules = [
          # Integrate Home Manager into nix-darwin
          home-manager.darwinModules.home-manager

          # nix-darwin and Home Manager setup
          (
            {
              username,
              homeDirectory,
              appleFontsOverlay,
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

              nixpkgs.overlays = [ appleFontsOverlay ];
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
