{ username, ... }:

{
  system.activationScripts.postActivation.text = ''
    # Avoid a logout/login cycle when changing settings.
    sudo -u ${username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  system.defaults.CustomUserPreferences = {
    "com.apple.symbolichotkeys" = {
      # To identify an undocumented ID, compare `defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys`
      # before and after changing that shortcut in `System Settings > Keyboard > Keyboard Shortcuts.`
      AppleSymbolicHotKeys = {
        # Select the previous input source (Control-Space).
        "60" = { enabled = false; };
        # Select the next source in the Input menu (Control-Option-Space).
        "61" = { enabled = false; };
        # Show Spotlight search (Command-Space).
        "64" = { enabled = false; };
        # Show the Finder search window (Command-Option-Space).
        "65" = { enabled = true; };
      };
    };
  };
}
