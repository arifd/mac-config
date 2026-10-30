import AppKit
import Foundation

/// The identity of an installed application bundle.
public struct Application: Identifiable, Equatable, Sendable {
    public let name: String
    public let path: URL

    public var id: String { path.path }

    public init(name: String, path: URL) {
        self.name = name
        self.path = path
    }

    /// Returns the containing directory as a path for display.
    public func containingDirectoryDisplayPath() -> String {
        (path.deletingLastPathComponent().path as NSString).abbreviatingWithTildeInPath
    }

    /// Loads the icon for this installed copy of the application.
    public func icon() -> NSImage {
        NSWorkspace.shared.icon(forFile: path.path)
    }

    /// Opens this installed copy of the application.
    @MainActor
    public func launch() async throws {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true

        try await NSWorkspace.shared.openApplication(
            at: path,
            configuration: configuration
        )
    }
}
