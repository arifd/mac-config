{ lib, pkgs, dotfiles, ... }:

let
  brewPrefix =
    if pkgs.stdenv.hostPlatform.isAarch64
    then "/opt/homebrew"
    else "/usr/local";
in
{
  # Import the dotfiles:
  xdg.configFile."rift" = {
    source = dotfiles + "/rift";
    recursive = true;
  };

  launchd.agents.rift = {
    enable = true;

    config = {
      Label = "git.acsandmann.rift";

      ProgramArguments = [
        "/usr/bin/env"
        "rift"
      ];

      EnvironmentVariables = {
        PATH = "${brewPrefix}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
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

  # Explicitly start rift.
  home.activation.startRift = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
    /bin/launchctl kickstart -k "gui/$(${pkgs.coreutils}/bin/id -u)/git.acsandmann.rift"
  '';
}
