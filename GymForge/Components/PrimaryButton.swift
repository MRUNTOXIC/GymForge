import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: {
            if isEnabled { action() }
        }) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title).font(.headline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(isEnabled ? GFTheme.accent : Color.white.opacity(0.12))
            .foregroundStyle(isEnabled ? Color.white : Color.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: title)
    }
}

struct StatCard: View {
    let title: String; let value: String; let icon: String
    var body: some View { VStack(alignment: .leading, spacing: 8) { Image(systemName: icon).foregroundStyle(GFTheme.accent); Text(value).font(.title2.bold()); Text(title).font(.caption).foregroundStyle(.secondary) }.frame(maxWidth: .infinity, alignment: .leading).gfCard() }
}
