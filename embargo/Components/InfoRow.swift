import SwiftUI

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)
                .accessibilityHidden(true)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .tracking(Design.trackingNormal)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.light))
                .tracking(Design.trackingNormal)
        }
    }
}
