{ username, dotfiles, ... }:

{
  # Install starship:
  home-manager.users.${username}.programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = fromTOML (builtins.readFile (dotfiles + "/starship/starship.toml"));
  };
}
