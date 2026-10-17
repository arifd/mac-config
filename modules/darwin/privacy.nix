{ ... }:

{
  system.defaults = {

    # System diagnostics & Telemetry
    CustomSystemPreferences = {
      "com.apple.SubmitDiagInfo" = {
        # Disable automatic submission of diagnostic reports to Apple,
        # including system diagnostics and crashes.
        AutoSubmit = false;

        # Disable sharing diagnostic information from third-party applications
        # with their developers.
        ThirdPartyDataSubmit = false;
      };
    };

    # User privacy and Apple Services
    CustomUserPreferences = {
      "com.apple.AdLib" = {
        # Disable personalized Apple advertising.
        # (This does not remove ads from Apple services).
        allowApplePersonalizedAdvertising = false;
      };

      "com.apple.assistant.support" = {
        # Legacy preference intended to disable Siri.
        # May be ignored on newer macOS versions.
        "Assistant Enabled" = false;
      };

      "com.apple.Siri" = {
        # Hide the Siri icon from the menu bar.
        # This only affects the UI, not the Siri service.
        StatusMenuVisible = false;
      };

      # Spotlight and Lookup
      "com.apple.lookup.shared" = {
        # Legacy preference for disabling online Lookup suggestions.
        # Version-dependent.
        LookupSuggestionsDisabled = true;
      };


      # Apple suggestions
      "com.apple.suggestions" =
        let
          siriAppBlacklist = [
            "com.apple.AppStore"
            "com.apple.iCal"
            "com.apple.AddressBook"
            "com.apple.FaceTime"
            "com.apple.mail"
            "com.apple.Maps"
            "com.apple.MobileSMS"
            "com.apple.news"
            "com.apple.Notes"
            "com.apple.Photos"
            "com.apple.podcasts"
            "com.apple.reminders"
            "com.apple.Safari"
          ];
        in
        {
          # Disable location-based geocoding suggestions.
          # This is an undocumented preference and may be ignored.
          SuggestionsAllowGeocode = false;
          # Prevent Siri from learning from these applications.
          # The list is not exhaustive.
          SiriCanLearnFromAppBlacklist = siriAppBlacklist;
          # Suppress Siri suggestions for the same applications.
          # Undocumented and potentially version-dependent.
          AppCanShowSiriSuggestionsBlacklist = siriAppBlacklist;
        };

      "com.apple.Safari" = {
        # Ask websites not to track across sites.
        # This is a legacy preference; verify in Safari settings.
        SendDoNotTrackHTTPHeader = true;
      };

      "com.apple.CrashReporter" = {
        # Suppress legacy crash reporter dialogs.
        # Does NOT disable crash logging or report submission.
        DialogType = "none";
      };

      # Finder and network volumes
      "com.apple.desktopservices" = {
        # Avoid writing .DS_Store metadata files on network shares, reducing
        # metadata left on remote servers.
        DSDontWriteNetworkStores = true;

        # Avoid writing .DS_Store files on USB/external volumes.
        DSDontWriteUSBStores = true;
      };
    };
  };

  system.activationScripts.postActivation.text = ''
    # Disable automatic diagnostic submission.
    /usr/bin/defaults write \
      /Library/Preferences/com.apple.SubmitDiagInfo \
      AutoSubmit -bool false

    # Disable third-party diagnostic submission.
    /usr/bin/defaults write \
      /Library/Preferences/com.apple.SubmitDiagInfo \
      ThirdPartyDataSubmit -bool false
  '';
}
