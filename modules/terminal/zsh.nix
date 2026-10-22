{ username, dotfiles, ... }:

{
  programs.zsh.enable = true;

  home-manager.users.${username} = {
    home.sessionPath = [ "${dotfiles}/bin" ];

    programs.zsh = {
      enable = true;
      # Effectively `~/.zshrc`:
      initContent = ''
        for file in ${dotfiles}/zsh/*.zsh; do
          source "$file"
        done
      '';
    };

    # Suppress the "Last login" message when opening a terminal:
    home.file.".hushlogin".text = "";
  };
}
