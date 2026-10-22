{
  config,
  pkgs,
  username,
  dotfiles,
  ...
}:
{
  # Install Rift:
  homebrew.taps = [ "acsandmann/tap" ];
  homebrew.brews = [
    {
      name = "acsandmann/tap/rift";
      trusted = true;
    }
  ];

  home-manager.users.${username} = { lib, ... }: {
    # Configure Rift:
    home.file.".config/rift" = {
      source = dotfiles + "/rift";
      recursive = true;
    };

    # Launch Rift:
    launchd.agents.rift = {
      enable = true;

      config = {
        Label = "git.acsandmann.rift";

        ProgramArguments = [
          "/usr/bin/env"
          "rift"
        ];

        EnvironmentVariables = {
          PATH = "${config.homebrew.prefix}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          RUST_LOG = "warn";
        };

        RunAtLoad = true;
        KeepAlive = {
          SuccessfulExit = false;
        };

        ProcessType = "Interactive";
        LimitLoadToSessionType = "Aqua";

        StandardOutPath = "/tmp/rift.out.log";
        StandardErrorPath = "/tmp/rift.err.log";
      };
    };

    # Explicitly start rift, so that after applying this configuration,
    # changes are reflected:
    home.activation.startRift = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
      /bin/launchctl kickstart -k "gui/$(${pkgs.coreutils}/bin/id -u)/git.acsandmann.rift"
    '';
  };
}
