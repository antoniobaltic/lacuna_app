import SwiftUI

struct ButtonPulse: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if !reduceMotion {
            Rectangle()
                .stroke(Color.primary, lineWidth: 1.5)
                .phaseAnimator([false, true]) { content, expanding in
                    content
                        .scaleEffect(x: expanding ? 1.05 : 1.0, y: expanding ? 1.4 : 1.0)
                        .opacity(expanding ? 0 : 0.35)
                } animation: { expanding in
                    expanding
                        ? .easeOut(duration: 1.8)
                        : .linear(duration: 0)
                }
        }
    }
}
