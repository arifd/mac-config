{ config, pkgs, dotfiles, assets, ... }:

let
  wallpaper = pkgs.runCommand "wallpaper.png" {
    nativeBuildInputs = [ pkgs.imagemagick pkgs.resvg ];
  } ''
    # Render at the SVG's intrinsic width and height, then repeat that tile
    # across the desktop canvas without changing its proportions.
    resvg ${assets}/wallpaper.svg tile.png
    magick -size 2560x1440 tile:tile.png \
      -strip -define png:compression-level=9 "$out"
  '';
in

{
  imports = [
    ./alacritty.nix
    ./automator.nix
    ./rift.nix
    ./swiftbar.nix
  ];

  home.stateVersion = "26.05";

  # Add bin directories here when user-managed tools need to be on the PATH.
  home.sessionPath = [ "${config.home.homeDirectory}/.cargo/bin" ];

  # Suppress the "Last login" message when opening a terminal:
  home.file.".hushlogin".text = "";

  # Packages without dedicated configuration.
  home.packages = with pkgs; [
    # Download a repository or subdirectory without Git history
    degit
    # Replacement for `ls`
    eza
    # Video editing
    ffmpeg
  ];

  programs = {
    ripgrep.enable = true;
    git.enable = true;

    # Shell
    zsh = {
      enable = true;
      # Effectively `~/.zshrc`:
      initContent = ''
        for file in ${dotfiles}/zsh/*.zsh; do
          source "$file"
        done
      '';
    };

    # Wallpaper
    desktoppr = {
      enable = true;
      settings = {
        picture = "${wallpaper}";
        # Keep the SVG's intrinsic tile size; the rendered canvas is already
        # larger than the desktop and can be cropped without scaling.
        scale = "center";
        setOnlyOnce = false;
      };
    };

    # Terminal prompt
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = fromTOML (
        builtins.readFile (dotfiles + "/starship/starship.toml")
      );
    };
  };
}
