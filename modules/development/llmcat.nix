{
  pkgs,
  username,
  programs,
  ...
}:
let
  llmcat = pkgs.rustPlatform.buildRustPackage {
    pname = "llmcat";
    version = "0.1.0";
    src = programs + "/llmcat";

    cargoLock.lockFile = programs + "/llmcat/Cargo.lock";
    cargoHash = "sha256-W0N0W3rCGlDbtTWo4kFq0xpq9PfNoJABIYY9uy/pnXw=";
  };
in
{
  home-manager.users.${username} = {
    home.packages = [
      llmcat
    ];
  };
}
