{ pkgs, ... }:

{
  imports = [
    ../nix
    ./homebrew.nix
    ./hotkeys.nix
    # ./privacy.nix
    ./spotlight.nix
  ];

  system.stateVersion = 6;

  # nix-darwin's createRun step needs this.
  system.activationScripts.preActivation.text = ''
      if [[ ! -e /etc/synthetic.conf ]]; then
        touch /etc/synthetic.conf
      fi
    '';

  system.defaults = {
    dock = {
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

    CustomUserPreferences = {
      # Hide search Menubar item:
      "com.apple.Spotlight" = {
        MenuItemHidden = true;
      };

      # Hide Keyboard Menubar item:
      "com.apple.TextInputMenu" = {
         visible = false;
       };

      # Hide desktop files from deskop view:
      "com.apple.WindowManager" = {
        StandardHideDesktopIcons = true;
      };

      # # Hint no rounded corners (doesn't always work):
      # "NSGlobalDomain" = {
      #   NSConvolutionOverride1 = 0.1;
      # };
    };

    screencapture.location = "~/Desktop";

    finder = {
      # Default finder view is list:
      FXPreferredViewStyle = "Nlsv";
      # Show a bar at the bottom with the path:
      ShowPathbar = true;
      # Search the current folder by default:
      FXDefaultSearchScope = "SCcf";
    };

    # Disable click desktop to woosh windows away:
    WindowManager.EnableStandardClickToShowDesktop = false;
  };

  # Zsh.
  programs.zsh.enable = true;

  # Enable Touch ID for sudo:
  security.pam.services.sudo_local.touchIdAuth = true;

  # Install fonts:
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
