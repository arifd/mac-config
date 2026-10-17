{ ... }:

{
  homebrew = {
    enable = true;
    taps = [ "acsandmann/tap" ];
    brews = [
      {
        name = "acsandmann/tap/rift";
        trusted = true;
      }
    ];
  };
}
