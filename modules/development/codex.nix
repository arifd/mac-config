{ username, dotfiles, ... }:

{
  home-manager.users.${username} = {
    # Installl global AGENTS.md:
    home.file.".codex" = {
      source = dotfiles + "/codex/config";
      recursive = true;
    };

    # Install skills:
    home.file.".agents/skills" = {
      source = dotfiles + "/codex/skills";
      recursive = true;
    };
  };
}
