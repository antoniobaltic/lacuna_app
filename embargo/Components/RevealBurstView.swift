import SwiftUI

struct RevealBurstView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let isActive: Bool
    @State private var expand1 = false
    @State private var expand2 = false
    @State private var expand3 = false

    var body: some View {
        ZStack {
            // Ring 1 — smallest, fastest
            Circle()
                .stroke(Color.primary.opacity(expand1 ? 0 : 0.3), lineWidth: expand1 ? 0.5 : 2)
                .frame(width: 40, height: 40)
                .scaleEffect(expand1 ? 4.0 : 1.0)

            // Ring 2 — medium
            Circle()
                .stroke(Color.primary.opacity(expand2 ? 0 : 0.2), lineWidth: expand2 ? 0.5 : 1.5)
                .frame(width: 60, height: 60)
                .scaleEffect(expand2 ? 3.5 : 1.0)

            // Ring 3 — largest, slowest
            Circle()
                .stroke(Color.primary.opacity(expand3 ? 0 : 0.15), lineWidth: expand3 ? 0.5 : 1)
                .frame(width: 80, height: 80)
                .scaleEffect(expand3 ? 3.0 : 1.0)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onChange(of: isActive) { _, active in
            guard active, !reduceMotion else { return }
            withAnimation(.easeOut(duration: 0.5)) { expand1 = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.05)) { expand2 = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { expand3 = true }
        }
    }
}
