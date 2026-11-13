import AppKit
import ApplicationServices

////////////////////////////////////////////////////////////////////////////////
// Sets the currently active macOS window into native full-screen mode.       //
////////////////////////////////////////////////////////////////////////////////

// Exit with an error message:
func fail(_ message: String) -> Never {
    let reason =
        AXIsProcessTrusted()
        ? message
        : "Accessibility permission error"

    fputs("\(reason)\n", stderr)
    exit(1)
}

// Get the currently active application:
guard let app = NSWorkspace.shared.frontmostApplication else {
    fail("No frontmost application")
}

// Get its currently focused window:
var window: CFTypeRef?
guard
    AXUIElementCopyAttributeValue(
        AXUIElementCreateApplication(app.processIdentifier),
        kAXFocusedWindowAttribute as CFString,
        &window
    ) == .success,
    let window = window as! AXUIElement?
else {
    fail("Cannot get focused window")
}

// Enter native macOS full-screen mode:
if case let error = AXUIElementSetAttributeValue(
    window,
    "AXFullScreen" as CFString,
    kCFBooleanTrue
), error != .success {
    fail("Cannot enter full-screen: \(error.rawValue)")
}
