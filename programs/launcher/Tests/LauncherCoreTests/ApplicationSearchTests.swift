import Foundation
import Testing

@testable import LauncherCore

@Test("Application search ranks exact, prefix, then substring matches")
func applicationSearchRanksMatchTypes() {
    let applications = [
        application("Notes Alpha"),
        application("Alpha Notes"),
        application("Alpha"),
        application("Apple Banana"),
    ]

    let results = searchApplications(applications, matching: "alpha")

    // Check match quality determines the result order:
    #expect(results.map(\.application.name) == ["Alpha", "Alpha Notes", "Notes Alpha"])
}

@Test("Application search requires query characters to be contiguous and ordered")
func applicationSearchRequiresContiguousQuery() {
    let applications = [
        application("Firefox Browser"),
        application("File Backup Browser"),
    ]

    let results = searchApplications(applications, matching: "fb")

    // Check separated initials do not match as a fuzzy subsequence:
    #expect(results.isEmpty)
}

@Test("Application search ignores case and diacritics")
func applicationSearchIgnoresCaseAndDiacritics() {
    let applications = [application("Café Notes")]
    let results = searchApplications(applications, matching: "cafe")

    // Check an unaccented lowercase query matches an accented title:
    #expect(results.map(\.application.name) == ["Café Notes"])
    // Check the range refers to the original accented application name:
    #expect(results.first?.matchingNameRange.map { String("Café Notes"[$0]) } == "Café")
}

@Test("Application search handles blank queries and returns every match")
func applicationSearchHandlesBlankQueriesAndReturnsEveryMatch() {
    let applications = [
        application("Alpha"),
        application("Alpha Notes"),
    ]

    // Check blank and whitespace-only queries produce no results:
    #expect(searchApplications(applications, matching: "   ").isEmpty)
    // Check every matching application is returned:
    #expect(
        searchApplications(applications, matching: "alpha").map(\.application.name) == [
            "Alpha", "Alpha Notes",
        ])
}

@Test("Wildcard returns all applications")
func wildcardReturnsAllApplactions() {
    let applications = [
        application("A"),
        application("B"),
    ]

    // Check wildcard yields all applications, despite not having the wildcard
    // in their name:
    #expect(searchApplications(applications, matching: "*").map(\.application.name) == ["A", "B"])
}

private func application(_ name: String) -> Application {
    Application(name: name, path: URL(fileURLWithPath: "/Applications/\(name).app"))
}
