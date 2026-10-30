{ ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    auto-optimise-store = true;
  };

  # Automatically remove unused store paths.
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 7;
      Hour = 3;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };
}
