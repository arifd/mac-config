{
  homeDirectory,
  username,
  dotfiles,
  pkgs,
  ...
}:

{
  home-manager.users.${username} = {
    # Install SwiftBar:
    home.packages = [ pkgs.swiftbar ];

    # Configure SwiftBar:
    home.file.".config/swiftbar/plugins" = {
      source = dotfiles + "/swiftbar";
      recursive = true;
    };

    # Tell SwiftBar where it should find the plugins:
    targets.darwin.defaults."com.ameba.SwiftBar".PluginDirectory =
      "${homeDirectory}/.config/swiftbar/plugins";

    # Launch SwiftBar:
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
  };
}
