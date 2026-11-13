{ ... }:

{
  # Hide the Spotlight menu icon:
  system.defaults.CustomUserPreferences."com.apple.Spotlight".MenuItemHidden = true;

  system.activationScripts.postActivation.text = ''
    # Disable metadata indexing on all mounted volumes:
    /usr/bin/mdutil -a -i off >/dev/null 2>&1 || true

    # Disable Spotlight indexing and searching on all mounted volumes:
    /usr/bin/mdutil -a -d >/dev/null 2>&1 || true

    # Resolve the currently logged-in console user.
    #
    # nix-darwin activation runs as root, so we must explicitly target the
    # user's GUI launchd domain.
    user=$(/usr/bin/stat -f %Su /dev/console)

    # Skip user agents when no graphical user is logged in.
    if [ "$user" != "root" ] && [ "$user" != "loginwindow" ]; then
      uid=$(/usr/bin/id -u "$user")

      # Disable Spotlight search and UI.
      /bin/launchctl disable "gui/$uid/com.apple.Spotlight" || true

      # Disable Spotlight knowledge processing and updates.
      /bin/launchctl disable "gui/$uid/com.apple.spotlightknowledged" || true
      /bin/launchctl disable "gui/$uid/com.apple.spotlightknowledged.updater" || true
      /bin/launchctl disable "gui/$uid/com.apple.spotlightknowledged.importer" || true

      # Disable Core Spotlight indexing and integration.
      /bin/launchctl disable "gui/$uid/com.apple.corespotlightd" || true
      /bin/launchctl disable "gui/$uid/com.apple.corespotlightservice" || true
      /bin/launchctl disable "gui/$uid/com.apple.managedcorespotlightd" || true
    else
      echo "Error: no logged-in user; cannot disable Spotlight agents." >&2
      exit 1
    fi
  '';
}
