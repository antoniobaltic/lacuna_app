import SwiftUI

struct OnboardingProgressBar: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                SwiftUI.Capsule()
                    .fill(index <= current ? Color.primary : Color.primary.opacity(0.18))
                    .frame(height: 2)
                    .animation(.easeInOut(duration: 0.3), value: current)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
}
