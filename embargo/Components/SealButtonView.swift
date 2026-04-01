import SwiftUI

struct SealButtonView: View {
    let action: () -> Void
    @State private var isPressed = false
    @State private var sealTrigger = false
    @State private var pulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 16) {
            Button {
                sealTrigger.toggle()
                withAnimation(Design.springSnappy) {
                    isPressed = true
                } completion: {
                    action()
                }
            } label: {
                ZStack {
                    // Pulse ring
                    Circle()
                        .stroke(Color.primary.opacity(pulsing ? 0 : 0.3), lineWidth: 1)
                        .frame(width: 88, height: 88)
                        .scaleEffect(pulsing ? 1.3 : 1.0)

                    // Filled circle
                    Circle()
                        .fill(Design.fg)
                        .frame(width: 72, height: 72)

                    // Lock icon
                    Image(systemName: "lock.fill")
                        .font(.title2.weight(.light))
                        .foregroundStyle(Design.bg)
                }
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .buttonStyle(.plain)
            .overlay { SealShockwaveView(trigger: sealTrigger) }
            .sensoryFeedback(.success, trigger: sealTrigger)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    pulsing = true
                }
            }

            Text("seal")
                .font(.caption)
                .tracking(Design.trackingButton)
                .foregroundStyle(.secondary)
        }
    }
}
