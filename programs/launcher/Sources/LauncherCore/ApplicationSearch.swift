import Foundation

/// A matching application from a search query.
public struct ApplicationSearchMatch: Identifiable {
    public let application: Application
    public let matchingNameRange: Range<String.Index>?

    public var id: String { application.id }

    fileprivate init(application: Application, matchingNameRange: Range<String.Index>?) {
        self.application = application
        self.matchingNameRange = matchingNameRange
    }
}

/// Searches for applications by query, `*` lists the catalog.
public func searchApplications(
    _ applications: [Application],
    matching query: String
) -> [ApplicationSearchMatch] {
    let normalizedQuery = query.normalizedForSearch()

    guard !normalizedQuery.isEmpty else {
        return []
    }

    if normalizedQuery == "*" {
        return
            applications
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            .map { ApplicationSearchMatch(application: $0, matchingNameRange: nil) }
    }

    return
        applications
        .compactMap { application in
            RankedApplication(application: application, query: normalizedQuery)
        }
        .sorted(by: RankedApplication.precedes)
        .map(\.match)
}

/// A search result ranked by exact, prefix, and substring matches.
private struct RankedApplication {
    let application: Application
    let matchingNameRange: Range<String.Index>
    private let matchRank: Int
    private let matchedTextLength: Int

    /// Rejects nonmatches up front so sorting only handles valid candidates.
    init?(application: Application, query: String) {
        let name = application.name.normalizedForSearch()
        guard let rank = Self.rank(for: name, matching: query) else {
            return nil
        }
        guard
            let matchingNameRange = application.name.range(
                of: query,
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: .current
            )
        else {
            return nil
        }

        matchRank = rank
        matchedTextLength = name.count
        self.application = application
        self.matchingNameRange = matchingNameRange
    }

    var match: ApplicationSearchMatch {
        ApplicationSearchMatch(
            application: application,
            matchingNameRange: matchingNameRange
        )
    }

    /// Excludes fuzzy subsequence matches, keeping results predictable as a query grows.
    private static func rank(for text: String, matching query: String) -> Int? {
        if text == query {
            return 0
        } else if text.hasPrefix(query) {
            return 1
        } else if text.contains(query) {
            return 2
        }

        return nil
    }

    /// Prioritizes specific matches and gives ties deterministic, readable ordering.
    static func precedes(_ lhs: RankedApplication, _ rhs: RankedApplication) -> Bool {
        if lhs.matchRank != rhs.matchRank {
            return lhs.matchRank < rhs.matchRank
        }

        if lhs.matchedTextLength != rhs.matchedTextLength {
            return lhs.matchedTextLength < rhs.matchedTextLength
        }

        return lhs.application.name.localizedCaseInsensitiveCompare(rhs.application.name)
            == .orderedAscending
    }
}

extension String {
    /// Makes equivalent names match regardless of case, accents, or query-edge spaces.
    fileprivate func normalizedForSearch() -> String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
