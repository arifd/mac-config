import AppKit
import LauncherCore
import SwiftUI

struct ResultsList: View {
    let results: [ApplicationSearchMatch]
    let selectedID: String?
    let onSelect: (String) -> Void
    let isLoading: Bool
    let emptyMessage: String

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if results.isEmpty {
                Text(emptyMessage)
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(results) { result in
                                ResultRow(
                                    result: result,
                                    isSelected: result.id == selectedID
                                ) {
                                    onSelect(result.id)
                                }
                                .id(result.id)
                            }
                        }
                        .padding(8)
                    }
                    .onChange(of: selectedID) { _, id in
                        guard let id else { return }
                        withAnimation(.easeOut(duration: 0.12)) {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(height: 340)
        .background(.ultraThinMaterial, in: shape)
        .overlay {
            shape.strokeBorder(.white.opacity(0.22))
        }
    }
}

private struct ResultRow: View {
    let result: ApplicationSearchMatch
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                ApplicationIcon(application: result.application)

                VStack(alignment: .leading, spacing: 3) {
                    title

                    Text(result.application.containingDirectoryDisplayPath())
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                if isSelected {
                    Text("Return")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.16), in: Capsule())
                }
            }
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.accentColor : .clear)
            .clipShape(.rect(cornerRadius: 12))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var title: some View {
        let name = result.application.name

        if let range = result.matchingNameRange {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(String(name[..<range.lowerBound]))
                Text(String(name[range]))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 2)
                    .background(.yellow, in: .rect(cornerRadius: 3))
                Text(String(name[range.upperBound...]))
            }
            .font(.headline)
        } else {
            Text(name)
                .font(.headline)
        }
    }
}

private struct ApplicationIcon: View {
    let application: Application
    @State private var icon: NSImage?

    var body: some View {
        Group {
            if let icon {
                Image(nsImage: icon)
                    .resizable()
            } else {
                Color.clear
                    .task(id: application.id) {
                        icon = await ApplicationIconLoader.shared
                            .loadIcon(for: application)?.image
                    }
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(.rect(cornerRadius: 9))
    }
}

private struct LoadedApplicationIcon: @unchecked Sendable {
    let image: NSImage
}

private actor ApplicationIconLoader {
    static let shared = ApplicationIconLoader()

    func loadIcon(for application: Application) -> LoadedApplicationIcon? {
        guard !Task.isCancelled else { return nil }
        return LoadedApplicationIcon(image: application.icon())
    }
}
