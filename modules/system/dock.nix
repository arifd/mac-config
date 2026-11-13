{ ... }:

{
  system.defaults.dock = {
    # "Disable" dock:
    autohide = true;
    autohide-delay = 1000000.0;

    # Smallest Dock size:
    tilesize = 16;
    magnification = false;

    # Don't show recent or running apps:
    show-recents = false;
    static-only = true;

    # Minimize extra Dock elements:
    show-process-indicators = false;
    showhidden = false;
  };
}
