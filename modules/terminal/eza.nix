{ pkgs, username, dotfiles, ... }:

{
  home-manager.users.${username} = {
    home.packages = [ pkgs.eza ];

    # eza reads its theme from this XDG config path by default.
    home.file.".config/eza/theme.yml".source = dotfiles + "/eza/theme.yml";
  };
}
