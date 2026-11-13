import SwiftUI

@MainActor
public struct LauncherView: View {
    @ObservedObject var model: LauncherModel

    public init(model: LauncherModel) {
        self.model = model
    }

    public var body: some View {
        let results = model.searchResults(matching: model.query)
        let resultIDs = results.map(\.id)

        VStack(spacing: 12) {
            SearchBar(
                text: $model.query,
                override: model.launchingApplication.map { "Starting \($0.name)…" },
                focusRequest: model.focusRequest,
                isLoading: model.isLoading
            )

            if model.isLoading || !model.query.isEmpty {
                ResultsList(
                    results: results,
                    selectedID: model.selectedResultID,
                    onSelect: model.selectResult,
                    isLoading: model.isLoading && model.applications.isEmpty,
                    emptyMessage: model.query.isEmpty
                        ? "No Applications Found"
                        : "No Matches"
                )
            }
        }
        .padding(14)
        .frame(width: 640, height: 450, alignment: .top)
        .task {
            model.requestFocus()
            await model.loadApplications()
        }
        .onChange(of: resultIDs, initial: true) {
            model.updateResults(resultIDs)
        }
        .alert(
            "Launcher Error",
            isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.dismissError() } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "Something went wrong.")
        }
    }
}
