{ username, homeDirectory, ... }:

{
  system.activationScripts.postActivation.text = ''
    # Change only the hotkeys managed here. Writing AppleSymbolicHotKeys as a
    # whole replaces every other shortcut stored in that preference.
    # Identify an undocumented ID by comparing `defaults read
    # com.apple.symbolichotkeys AppleSymbolicHotKeys` before and after
    # changing the shortcut in System Settings > Keyboard > Keyboard Shortcuts.
    hotkeys=${homeDirectory}/Library/Preferences/com.apple.symbolichotkeys.plist
    # 60: Select the previous input source (Control-Space).
    /usr/bin/sudo -u ${username} /usr/libexec/PlistBuddy \
      -c 'Set :AppleSymbolicHotKeys:60:enabled false' "$hotkeys"
    # 61: Select the next source in the Input menu (Control-Option-Space).
    /usr/bin/sudo -u ${username} /usr/libexec/PlistBuddy \
      -c 'Set :AppleSymbolicHotKeys:61:enabled false' "$hotkeys"
    # 64: Show Spotlight search (Command-Space).
    /usr/bin/sudo -u ${username} /usr/libexec/PlistBuddy \
      -c 'Set :AppleSymbolicHotKeys:64:enabled false' "$hotkeys"
    # 65: Show the Finder search window (Command-Option-Space).
    /usr/bin/sudo -u ${username} /usr/libexec/PlistBuddy \
      -c 'Set :AppleSymbolicHotKeys:65:enabled true' "$hotkeys"

    # Avoid a logout/login cycle when changing settings:
    sudo -u ${username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings
  '';
}
