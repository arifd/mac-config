import AppKit
// Carbon provides system-wide hotkey registration, unlike AppKit.
import Carbon
import Darwin
import LauncherGUI
import SwiftUI

@main
@MainActor
enum LauncherApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = LauncherAppDelegate()
        app.delegate = delegate
        app.run()
    }
}

/// Manages the launcher surface and global keyboard shortcut.
@MainActor
final class LauncherAppDelegate: NSObject, NSApplicationDelegate {
    private let model: LauncherModel
    private let panel: LauncherPanel
    private var hasBeenPositioned = false
    private var hotKey: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    override init() {
        let model = LauncherModel()
        self.model = model
        panel = LauncherPanel(model: model)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard !anotherInstanceIsRunning() else {
            fputs("LauncherApp is already running.\n", stderr)
            exit(EXIT_FAILURE)
        }

        NSApp.setActivationPolicy(.accessory)

        // Keep the development launcher independent from any previously
        // installed and currently live app.
        #if DEBUG
            showLauncher()
        #else
            registerHotKey()
        #endif
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows: Bool
    ) -> Bool {
        showLauncher()
        return false
    }

    private func anotherInstanceIsRunning() -> Bool {
        let currentPID = ProcessInfo.processInfo.processIdentifier

        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            return NSRunningApplication.runningApplications(
                withBundleIdentifier: bundleIdentifier
            ).contains { $0.processIdentifier != currentPID }
        }

        guard let executableURL = Bundle.main.executableURL?.standardizedFileURL else {
            return false
        }

        return NSWorkspace.shared.runningApplications.contains {
            $0.processIdentifier != currentPID
                && $0.executableURL?.standardizedFileURL == executableURL
        }
    }

    func applicationDidResignActive(_ notification: Notification) {
        hideLauncher()
    }

    private func showLauncher() {
        guard
            let screen = NSScreen.screens.first(where: {
                $0.frame.contains(NSEvent.mouseLocation)
            }) ?? NSScreen.main
        else { return }

        // Preserve the panel's position after its first appearance.
        if !hasBeenPositioned {
            let frame = screen.visibleFrame
            panel.setFrameOrigin(
                NSPoint(
                    x: frame.midX - panel.frame.width / 2,
                    y: frame.midY - panel.frame.height / 2
                ))
            hasBeenPositioned = true
        }

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        model.requestFocus()
    }

    private func hideLauncher() {
        panel.orderOut(nil)

        // Prevent reopening with a stale selection.
        model.clearSelection()
    }

    private func toggleLauncher() {
        if panel.isVisible {
            hideLauncher()
        } else {
            showLauncher()
        }
    }

    // Registers Command + Space to toggle the launcher.
    private func registerHotKey() {
        var type = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handlerStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData in
                guard let userData else { return noErr }

                let delegate = Unmanaged<LauncherAppDelegate>
                    .fromOpaque(userData)
                    .takeUnretainedValue()

                Task { @MainActor in
                    delegate.toggleLauncher()
                }
                return noErr
            },
            1,
            &type,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )

        guard handlerStatus == noErr else {
            model.reportError(
                "Could not install the Command-Space shortcut (\(handlerStatus))."
            )
            return
        }

        let hotKeyID = EventHotKeyID(
            signature: OSType(0x4C41_554E),
            id: 1
        )

        let status = RegisterEventHotKey(
            UInt32(kVK_Space),
            UInt32(cmdKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKey
        )

        if status != noErr {
            model.reportError(
                "Could not register the Command-Space shortcut (\(status))."
            )
        }
    }
}

/// A nonactivating surface that supports keyboard input for the launcher.
/// (Rather than a traditional window)
@MainActor
private final class LauncherPanel: NSPanel {
    private let model: LauncherModel

    /// Creates a borderless panel that appears across all Spaces.
    init(model: LauncherModel) {
        self.model = model

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 668, height: 450),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        titleVisibility = .hidden
        level = .screenSaver
        collectionBehavior = [
            .canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle,
        ]
        isMovableByWindowBackground = true
        contentView = NSHostingView(rootView: LauncherView(model: model))
    }

    /// This panel only supports programmatic initialization.
    required init?(coder: NSCoder) {
        fatalError("LauncherPanel does not support coder initialization.")
    }

    /// Allow the borderless panel to receive keyboard input.
    override var canBecomeKey: Bool { true }

    /// Allow the panel to become the main window.
    override var canBecomeMain: Bool { true }

    // Handle keyboard events.
    override func sendEvent(_ event: NSEvent) {
        guard event.type == .keyDown else {
            super.sendEvent(event)
            return
        }

        switch event.specialKey {
        case .upArrow:
            model.moveSelection(by: -1)
        case .downArrow:
            model.moveSelection(by: 1)
        case .carriageReturn, .enter:
            model.selectCurrentResult()
        default:
            if event.keyCode == 53 {
                model.dismiss()
            } else {
                super.sendEvent(event)
            }
        }
    }
}
