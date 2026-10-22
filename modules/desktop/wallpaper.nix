{
  username,
  pkgs,
  assets,
  ...
}:

let
  # Render the PNG from our source SVG:
  wallpaper =
    pkgs.runCommand "wallpaper.png"
      {
        nativeBuildInputs = [
          pkgs.imagemagick
          pkgs.resvg
        ];
      }
      ''
        # Render at the SVG's intrinsic width and height, then repeat that tile
        # across the desktop canvas without changing its proportions.
        resvg ${assets}/wallpaper.svg tile.png
        magick -size 2560x1440 tile:tile.png \
          -strip -define png:compression-level=9 "$out"
      '';
in
{
  # Install Desktopper to handle setting the wallpaper:
  home-manager.users.${username}.programs.desktoppr = {
    enable = true;
    settings = {
      picture = "${wallpaper}";
      # Keep the SVG's intrinsic tile size; the rendered canvas is already
      # larger than the desktop and can be cropped without scaling.
      scale = "center";
      setOnlyOnce = false;
    };
  };
}