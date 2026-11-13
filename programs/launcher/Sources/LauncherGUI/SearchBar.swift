import SwiftUI

/// Shared query input styled by the active launcher mode.
struct SearchBar: View {
    /// The text value of a the search field.
    @Binding var text: String
    /// An overridden text value.
    let override: String?
    /// A counter that when changed focuses the text field.
    let focusRequest: Int
    let isLoading: Bool

    @FocusState private var isFocused: Bool

    let font = Font.system(size: 25)

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 27, style: .continuous)
    }

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 21, weight: .medium))
                .foregroundStyle(.secondary)

            if let override {
                HStack(spacing: 10) {
                    ProgressView().controlSize(.small)
                    Text(override)
                        .font(font)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                TextField("Search", text: $text)
                    .textFieldStyle(.plain)
                    .font(font)
                    .focused($isFocused)
                    .frame(height: 34)
            }

            // Show the loading spinner if loading but no override:
            if isLoading && override == nil {
                ProgressView().controlSize(.small)
            }
        }
        .padding(.horizontal, 19)
        .frame(height: 66)
        .background(.regularMaterial, in: shape)
        .overlay {
            shape.strokeBorder(.white.opacity(0.5))
        }
        .onAppear {
            isFocused = true
        }
        .onChange(of: focusRequest) {
            isFocused = true
        }
    }
}
