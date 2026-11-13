{
  pkgs,
  programs,
  username,
  ...
}:
let
  launcher = pkgs.stdenv.mkDerivation {
    pname = "launcher";
    version = "1.0.0";
    src = programs + "/launcher";

    nativeBuildInputs = [
      pkgs.swift
      pkgs.swiftpm
      pkgs.libcxx
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      swift build \
        --package-path "$src" \
        --scratch-path "$TMPDIR/launcher-build" \
        --disable-sandbox \
        -Xlinker "-L${pkgs.libcxx}/lib" \
        --configuration release \
        --product launcher
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      cp "$TMPDIR/launcher-build/release/launcher" "$out/bin/launcher"
      runHook postInstall
    '';
  };
in
{
  home-manager.users.${username} = {
    home.packages = [ launcher ];

    launchd.agents.launcher = {
      enable = true;
      config = {
        ProgramArguments = [ "${launcher}/bin/launcher" ];
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
        LimitLoadToSessionType = "Aqua";
      };
    };
  };
}
