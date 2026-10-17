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
      # Paths to local files:
      dotfiles = ./dotfiles;
      assets = ./assets;

      # Machine information provided by scripts/machine-env.sh
      machine = {
        username = builtins.getEnv "MAC_USERNAME";
        homeDirectory = builtins.getEnv "MAC_HOME";
        system = builtins.currentSystem;
      };
    in
    {
      # macOS system configuration
      darwinConfigurations.default = nix-darwin.lib.darwinSystem {
        # Pass the dotfiles path to nix-darwin modules
        specialArgs = {
          inherit dotfiles assets;
          username = machine.username;
        };

        modules = [
          # System-level nix-darwin configuration
          ./modules/darwin

          # Integrate Home Manager into nix-darwin
          home-manager.darwinModules.home-manager

          {
            # Expose Apple font packages through pkgs.
            nixpkgs.overlays = [ apple-fonts.overlays.default ];

            # Machine-specific nix-darwin settings
            nixpkgs.hostPlatform = machine.system;
            system.primaryUser = machine.username;
            users.users.${machine.username}.home = machine.homeDirectory;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Pass the dotfiles path to Home Manager modules
            home-manager.extraSpecialArgs = { inherit dotfiles assets; };

            # Import user-specific Home Manager configuration
            home-manager.users.${machine.username} = {
              imports = [ ./modules/home ];
            };
          }
        ];
      };

      # Nix formatter (nixfmt)
      formatter.${machine.system} =
        nixpkgs.legacyPackages.${machine.system}.nixfmt;
    };
}
