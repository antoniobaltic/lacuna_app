import SwiftUI

struct SendButtonView: View {
    let action: () -> Void
    @State private var sendTrigger = false
    @State private var isPressed = false
    @State private var pulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 16) {
            Button {
                sendTrigger.toggle()
                withAnimation(Design.springSnappy) {
                    isPressed = true
                } completion: {
                    action()
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(pulsing ? 0 : 0.25), lineWidth: 1)
                        .frame(width: 88, height: 88)
                        .scaleEffect(pulsing ? 1.3 : 1.0)

                    Circle()
                        .fill(Design.fg)
                        .frame(width: 72, height: 72)

                    Image(systemName: "paperplane")
                        .font(.title2.weight(.light))
                        .foregroundStyle(Design.bg)
                }
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .medium), trigger: sendTrigger)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }

            Text("send")
                .font(.caption)
                .tracking(Design.trackingButton)
                .foregroundStyle(.secondary)
        }
    }
}
