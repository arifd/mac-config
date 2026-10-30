import AppKit
import Darwin
import Foundation
import LauncherCore
import SwiftUI

/// Adapts application discovery and search results for the launcher UI.
@MainActor
public final class LauncherModel: ObservableObject {
    @Published public var query = ""
    @Published public private(set) var applications: [Application] = []
    @Published public private(set) var selectedResultID: String?
    @Published public private(set) var isLoading = true
    @Published public private(set) var launchingApplication: Application?
    @Published public private(set) var errorMessage: String?

    /// A counter that lets SearchBar detect each focus request, including
    /// repeated requests.
    @Published public private(set) var focusRequest = 0

    private var currentSearch: (query: String, results: [ApplicationSearchMatch])?
    private var hasLoadedApplications = false
    private var resultIDs: [String] = []

    public init() {}

    /// Returns cached search results when the query hasn't changed.
    func searchResults(matching query: String) -> [ApplicationSearchMatch] {
        if let currentSearch, currentSearch.query == query {
            return currentSearch.results
        }

        let results = searchApplications(applications, matching: query)
        currentSearch = (query, results)
        return results
    }

    public func loadApplications() async {
        guard !hasLoadedApplications else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            applications = try await Task.detached(priority: .userInitiated) {
                try discoverApplications()
            }.value

            currentSearch = nil
            hasLoadedApplications = true
        } catch {
            NSLog("Could not scan applications: %@", error.localizedDescription)
            Darwin.exit(EXIT_FAILURE)
        }
    }

    public func requestFocus() { focusRequest += 1 }
    public func dismissError() { errorMessage = nil }
    public func reportError(_ message: String) { errorMessage = message }
    public func clearSelection() { selectedResultID = nil }
    public func dismiss() { NSApp.hide(nil) }

    func updateResults(_ ids: [String]) {
        resultIDs = ids
        selectedResultID = ids.count == 1 ? ids.first : nil
    }

    public func moveSelection(by offset: Int) {
        guard !resultIDs.isEmpty else {
            selectedResultID = nil
            return
        }

        let currentIndex = selectedResultID.flatMap(resultIDs.firstIndex(of:))
        let startIndex = currentIndex ?? (offset < 0 ? 0 : -1)
        let nextIndex = (startIndex + offset % resultIDs.count + resultIDs.count)
            % resultIDs.count
        selectedResultID = resultIDs[nextIndex]
    }

    public func selectCurrentResult() {
        guard let selectedResultID else { return }
        selectResult(selectedResultID)
    }

    func selectResult(_ id: String) {
        guard let application = applications.first(where: { $0.id == id }) else {
            return
        }
        launch(application)
    }

    public func launch(_ application: Application) {
        launchingApplication = application

        Task {
            do {
                try await application.launch()
                query = ""
                selectedResultID = nil
                launchingApplication = nil
                NSApp.hide(nil)
            } catch {
                launchingApplication = nil
                reportError(
                    "Could not open \(application.name): \(error.localizedDescription)"
                )
            }
        }
    }
}
