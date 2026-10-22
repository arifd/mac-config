{
  username,
  dotfiles,
  pkgs,
  ...
}:

let
  theme = fromTOML (builtins.readFile (dotfiles + "/bat/themes/Nordish.toml"));
  themeDir = pkgs.writeTextDir "Nordish.tmTheme" (
    pkgs.lib.generators.toPlist { escape = true; } theme
  );
in

{
  home-manager.users.${username} = {
    programs.bat = {
      enable = true;
      config.theme = "Nordish";
      themes.Nordish = {
        src = themeDir;
        file = "Nordish.tmTheme";
      };
    };
  };
}
