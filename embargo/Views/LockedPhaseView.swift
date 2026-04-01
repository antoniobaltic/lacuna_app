import SwiftUI

struct LockedPhaseView: View {
    let onReveal: () -> Void
    @State private var appeared = false
    @State private var breathing = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "lock.open")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundStyle(.primary)
                    .scaleEffect(breathing ? 1.05 : 1.0)
                    .opacity(breathing ? 0.8 : 1.0)
                    .accessibilityHidden(true)

                Text("your capsule is ready")
                    .font(.title2.weight(.light))
                    .tracking(Design.trackingNormal)
            }
            .onAppear {
                withAnimation(Design.breathe) { breathing = true }
            }

            Spacer()

            Button("reveal", action: onReveal)
                .font(.body.weight(.medium))
                .tracking(Design.trackingButton)
                .foregroundStyle(Design.bg)
                .padding(.horizontal, 56)
                .padding(.vertical, 18)
                .background(Design.fg)
                .clipShape(SwiftUI.Capsule())
                .buttonStyle(.plain)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.6).delay(0.5)) { appeared = true }
                }

            Spacer()
                .frame(height: 60)
        }
        .padding(24)
    }
}
