{ username, dotfiles, ... }:

{
  home-manager.users.${username} = {
    # Install Alacritty:
    programs.alacritty.enable = true;

    # Configure Alacritty:
    home.file.".config/alacritty" = {
      source = dotfiles + "/alacritty";
      recursive = true;
    };
  };
}
