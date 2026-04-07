import SwiftUI

struct EmptyStateView: View {
    var onIconTap: (() -> Void)? = nil
    @State private var appeared = false
    @State private var pulsing = false
    @State private var tapTrigger = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(pulsing ? 0 : 0.2), lineWidth: 1)
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulsing ? 1.3 : 1.0)

                Circle()
                    .fill(Design.fg)
                    .frame(width: 80, height: 80)

                Circle()
                    .fill(Design.bg)
                    .frame(width: 36, height: 36)

                Circle()
                    .stroke(Design.bg.opacity(pulsing ? 0 : 0.3), lineWidth: 1)
                    .frame(width: 36, height: 36)
                    .scaleEffect(pulsing ? 1.8 : 1.0)
            }
            .contentShape(.circle)
            .onTapGesture { tapTrigger.toggle(); onIconTap?() }
            .sensoryFeedback(.impact(weight: .medium), trigger: tapTrigger)
            .padding(.bottom, 4)

            Text("seal a message, photo, or voice note\nfor the future.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .tracking(Design.trackingTight)
                .multilineTextAlignment(.center)

            Spacer()
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulsing = true
            }
        }
    }
}

#Preview("empty state") {
    ZStack {
        Design.bg.ignoresSafeArea()
        EmptyStateView()
            .overlay { FloatingParticlesView() }
    }
}

#Preview("empty state — dark") {
    ZStack {
        Design.bg.ignoresSafeArea()
        EmptyStateView()
            .overlay { FloatingParticlesView() }
    }
    .preferredColorScheme(.dark)
}
