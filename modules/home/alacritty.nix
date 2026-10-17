{ dotfiles, ... }:

{
  programs.alacritty.enable = true;

  # Symlink the config files into the expected location:
  home.file.".config/alacritty" = {
    source = dotfiles + "/alacritty";
    recursive = true;
  };
}
