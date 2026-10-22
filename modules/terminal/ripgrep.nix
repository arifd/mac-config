{ username, ... }:

{
  # Install Ripgrep:
  home-manager.users.${username}.programs.ripgrep.enable = true;
}
