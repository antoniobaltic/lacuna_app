import SwiftUI

struct AddButtonPulse: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if !reduceMotion {
            Circle()
                .stroke(Color.primary, lineWidth: 1.5)
                .phaseAnimator([false, true]) { content, expanding in
                    content
                        .scaleEffect(expanding ? 1.7 : 1.0)
                        .opacity(expanding ? 0 : 0.4)
                } animation: { expanding in
                    expanding
                        ? .easeOut(duration: 1.8)
                        : .linear(duration: 0)
                }
        }
    }
}
