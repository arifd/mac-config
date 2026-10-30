import Testing

@testable import LauncherCore

// Historically, Safari missing from results indicated a regression in
// application discovery.
@Test("Application discovery includes Safari")
func discoverApplicationsIncludesSafari() throws {
    let applications = try discoverApplications()
    #expect(applications.contains { $0.name == "Safari" })
}
