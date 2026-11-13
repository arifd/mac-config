import Foundation

/// Filesystem roots scanned to build the application catalog.
public let applicationSearchDirectories: [URL] = {
    let fileManager = FileManager.default
    return [
        URL(fileURLWithPath: "/Applications"),
        URL(fileURLWithPath: "/System/Applications"),
        fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Applications"),
        URL(fileURLWithPath: "/System/Library/CoreServices/Applications"),
        URL(fileURLWithPath: "/Library/Input Methods"),
        fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Input Methods"),
        URL(fileURLWithPath: "/opt/homebrew/Caskroom"),
        URL(fileURLWithPath: "/usr/local/Caskroom"),
    ]
}()

/// Builds one searchable application for each discovered install location.
public func discoverApplications(
    fileManager: FileManager = .default
) throws -> [Application] {
    var applications: [Application] = []
    var seenPaths = Set<URL>()

    for directory in applicationSearchDirectories {
        guard fileManager.fileExists(atPath: directory.path) else {
            continue
        }

        for application in try discoverApplications(in: directory, fileManager: fileManager) {
            guard seenPaths.insert(application.path).inserted else {
                continue
            }

            applications.append(application)
        }
    }

    return applications
}

public enum ApplicationDiscoveryError: Error, LocalizedError {
    /// Discovery could not inspect a configured root.
    case couldNotEnumerate(URL)
    /// A candidate app path did not contain readable bundle metadata.
    case invalidApplicationBundle(URL)
    /// Makes filesystem discovery failures useful to the caller.
    public var errorDescription: String? {
        switch self {
        case .couldNotEnumerate(let url):
            return "Could not enumerate applications in \(url.path)"
        case .invalidApplicationBundle(let url):
            return "Could not read application bundle at \(url.path)"
        }
    }
}

/// Scans a single directory tree for applications.
private func discoverApplications(
    in directory: URL,
    fileManager: FileManager = .default
) throws -> [Application] {
    let resourceKeys: Set<URLResourceKey> = [
        .isApplicationKey,
        .isHiddenKey,
        .isSymbolicLinkKey,
        .localizedNameKey,
    ]

    var enumerationError: Error?

    guard
        let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [],
            errorHandler: { _, error in
                enumerationError = error
                return false
            }
        )
    else {
        throw ApplicationDiscoveryError.couldNotEnumerate(directory)
    }

    var applications: [Application] = []

    for case let url as URL in enumerator {
        let resourceValues = try url.resourceValues(forKeys: resourceKeys)

        let isApplication =
            resourceValues.isApplication == true || url.pathExtension.lowercased() == "app"

        // We must not universally skip hidden, since some (system) app bundles are
        // hidden.
        if resourceValues.isHidden == true && !isApplication {
            enumerator.skipDescendants()
            continue
        }

        guard isApplication else {
            continue
        }

        enumerator.skipDescendants()

        let canonicalURL = url.resolvingSymlinksInPath().standardizedFileURL

        if resourceValues.isSymbolicLink == true
            && !fileManager.fileExists(atPath: canonicalURL.path)
        {
            continue
        }

        guard let bundle = Bundle(url: canonicalURL) else {
            throw ApplicationDiscoveryError.invalidApplicationBundle(canonicalURL)
        }

        let name =
            (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
            ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
            ?? resourceValues.localizedName
            ?? canonicalURL.deletingPathExtension().lastPathComponent

        applications.append(
            Application(
                name: name,
                path: canonicalURL
            )
        )
    }

    if let enumerationError {
        throw enumerationError
    }

    return applications
}
