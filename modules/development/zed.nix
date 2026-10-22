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
    # External formatters, declared in `settings.json`
    home.packages = [
      pkgs.nixfmt
      pkgs.taplo
    ];

    home.file.".config/zed" = {
      source = dotfiles + "/zed";
      recursive = true;
    };
  };
}
