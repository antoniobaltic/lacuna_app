import SwiftUI

struct CountdownUnit: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.system(size: 40, weight: .ultraLight, design: .monospaced))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .animation(.snappy, value: value)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.lowercase)
                .tracking(Design.trackingNormal)
        }
    }
}
