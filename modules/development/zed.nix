{
  username,
  dotfiles,
  pkgs,
  ...
}:

let
  mdformat = pkgs.python3.withPackages (
    pythonPackages: with pythonPackages; [
      mdformat
      # Adds TOML, YAML, and JSON front matter support to mdformat.
      mdformat-front-matters
      # Adds GitHub Flavored Markdown support to mdformat, e.g. tables.
      mdformat-gfm
    ]
  );
in
{
  # Install Zed:
  homebrew = {
    taps = [ "slime-studio/tap" ];
    casks = [ "zed" ];
    brews = [
      # Project-aware SourceKit-LSP support for Xcode projects
      {
        name = "slime-studio/tap/sourcekit-xcode-bsp";
        trusted = true;
      }
      # Log-based SourceKit-LSP support, retained as a fallback
      "xcode-build-server"
    ];
  };

  home-manager.users.${username} = {
    # Indicate that we would like Zed to be used as the default editor for
    # terminal applications:
    home.sessionVariables = {
      EDITOR = "zed --wait";
      VISUAL = "zed --wait";
    };

    # External formatters, declared in `settings.json`.
    home.packages = [
      # Nix formatter
      pkgs.nixfmt
      # Markdown formatter
      mdformat
      # Markdown linter and language server
      pkgs.rumdl
      # TOML formatter
      pkgs.taplo
    ];

    # Move the config file into the location Zed expects it to be:
    home.file.".config/zed" = {
      source = dotfiles + "/zed";
      recursive = true;
    };

    home.file.".config/rumdl/rumdl.toml".source = dotfiles + "/rumdl/rumdl.toml";
  };
}
