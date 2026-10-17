{ config, dotfiles, pkgs, ... }:

{
  home.packages = [ pkgs.swiftbar ];

  # Symlink the config files into the expected location:
  home.file.".config/swiftbar/plugins" = {
    source = dotfiles + "/swiftbar";
    recursive = true;
  };

  # Tell SwiftBar where it should find the plugins:
  targets.darwin.defaults."com.ameba.SwiftBar".PluginDirectory =
    "${config.home.homeDirectory}/.config/swiftbar/plugins";

  # Launch SwiftBar on login:
  launchd.agents.swiftbar = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/open"
        "-a"
        "SwiftBar"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };
}
