{
  username,
  dotfiles,
  pkgs,
  ...
}:

{
  # Install Zed:
  homebrew.casks = [ "zed" ];

  home-manager.users.${username} = {
    # Indicate that we would like Zed to be used as the default editor for
    # terminal applications:
    home.sessionVariables = {
      EDITOR = "zed --wait";
      VISUAL = "zed --wait";
    };

    # External formatters, declared in `settings.json`.
    home.packages = [
      pkgs.nixfmt # Nix formatter
      pkgs.rumdl # Markdown linter and language server
      pkgs.taplo # TOML formatter
    ];

    # Move the config file into the location Zed expects it to be:
    home.file.".config/zed" = {
      source = dotfiles + "/zed";
      recursive = true;
    };

    home.file.".config/rumdl/rumdl.toml".source = dotfiles + "/rumdl/rumdl.toml";
  };
}
