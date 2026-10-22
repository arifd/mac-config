# Generate Finder Quick Actions from shell scripts in dotfiles/automator/scripts/.
# Each .sh file becomes a service named after the file (without the extension).
# The Automator template uses {{TITLE}} and {{COMMAND}} placeholders.
# To add a service, simply add a new .sh file to the scripts directory.
#
# NOTE: Quick actions still need manual enabling via GUI:
#       Context Menu > Quick Actions > Customise...

{
  username,
  lib,
  dotfiles,
  pkgs,
  ...
}:

let
  scriptsDir = dotfiles + "/automator/scripts";
  template = dotfiles + "/automator/template.workflow";

  scripts = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".sh" name) (
    builtins.readDir scriptsDir
  );

  mkWorkflow =
    name:
    let
      title = lib.removeSuffix ".sh" name;
      script = scriptsDir + "/${name}";

      # Keep the action reproducible on a new system from this configuration.
      scriptPath = lib.escapeShellArg "${script}";
      templatePath = lib.escapeShellArg "${template}";

      command = "exec /bin/bash ${scriptPath} \"$@\"";
    in
    pkgs.runCommand "${lib.strings.sanitizeDerivationName title}.workflow" { } ''
      cp -R ${templatePath} "$out"
      chmod -R u+w "$out"

      substituteInPlace "$out/Contents/Info.plist" \
        --replace-fail '{{TITLE}}' ${lib.escapeShellArg title}

      substituteInPlace "$out/Contents/document.wflow" \
        --replace-fail '{{COMMAND}}' ${lib.escapeShellArg command}
    '';
in
{
  home-manager.users.${username}.home.file = lib.mapAttrs' (name: _: {
    name = "Library/Services/${lib.removeSuffix ".sh" name}.workflow";
    value.source = mkWorkflow name;
  }) scripts;
}
