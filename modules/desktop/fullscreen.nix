{
  pkgs,
  programs,
  ...
}:
let
  fullscreen = pkgs.stdenv.mkDerivation {
    pname = "fullscreen";
    version = "1.0.0";
    src = programs + "/fullscreen.swift";

    nativeBuildInputs = [ pkgs.swift ];

    dontUnpack = true;

    buildPhase = ''
      runHook preBuild
      swiftc -O "$src" -o fullscreen
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      cp fullscreen "$out/bin/fullscreen"
      runHook postInstall
    '';
  };
in
{
  environment.systemPackages = [ fullscreen ];
}
