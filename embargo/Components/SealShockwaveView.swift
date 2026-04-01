import SwiftUI

struct SealShockwaveView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let trigger: Bool
    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(Color.primary.opacity(animate ? 0 : 0.3), lineWidth: animate ? 0.5 : 2)
            .frame(width: 60, height: 60)
            .scaleEffect(animate ? Design.shockwaveScale : 1.0)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .onChange(of: trigger) {
                guard !reduceMotion else { return }
                animate = false
                withAnimation(.spring(response: Design.shockwaveDuration, dampingFraction: 0.7)) {
                    animate = true
                }
            }
    }
}
