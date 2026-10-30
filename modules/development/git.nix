{ username, dotfiles, ... }:

{
  # Install git:
  home-manager.users.${username} =
    { config, ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          core.excludesFile = "${config.xdg.configHome}/git/.gitignore";
        };
      };

      home.file.".config/git/.gitignore".source = "${dotfiles}/git/.gitignore";
    };
}
