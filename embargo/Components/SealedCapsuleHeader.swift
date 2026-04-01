import SwiftUI

struct SealedCapsuleHeader: View {
    let capsule: Capsule
    let isReady: Bool
    var onOpenTap: (() -> Void)? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathing = false
    @State private var openHaptic = false

    private var headerSubtitle: String? {
        let hasTitle = !capsule.title.isEmpty
        let sender = capsule.senderName

        if hasTitle {
            // title is main → subtitle shows type + optionally sender
            if let sender {
                return "\(capsule.type.label) · received from \(sender)"
            } else {
                return capsule.type.label
            }
        } else {
            // type.label is main → subtitle shows sender only
            if let sender {
                return "received from \(sender)"
            } else {
                return nil
            }
        }
    }

    private var breathingAnimation: Animation {
        let total = capsule.unlocksAt.timeIntervalSince(capsule.createdAt)
        let remaining = max(0, capsule.unlocksAt.timeIntervalSince(Date.now))
        let progress = total > 0 ? 1.0 - (remaining / total) : 1.0
        let duration = Design.breatheFarDuration - (progress * (Design.breatheFarDuration - Design.breatheNearDuration))
        return .easeInOut(duration: max(Design.breatheNearDuration, duration)).repeatForever(autoreverses: true)
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Outer pulse ring
                Circle()
                    .stroke(Color.primary.opacity(isReady ? 0.25 : 0.18), lineWidth: 1)
                    .frame(width: 110, height: 110)
                    .scaleEffect(breathing ? (isReady ? 1.15 : 1.05) : 1.0)
                    .opacity(breathing && isReady ? 0.0 : 1.0)

                // Single circle — animates between stroke and fill
                Circle()
                    .fill(isReady ? Design.fg : .clear)
                    .frame(width: 90, height: 90)
                    .scaleEffect(breathing ? (isReady ? 1.03 : 1.0) : 1.0)
                    .overlay {
                        Circle()
                            .stroke(Color.primary.opacity(isReady ? 0 : 0.18), lineWidth: 1)
                    }

                Image(systemName: isReady ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 30, weight: isReady ? .regular : .regular))
                    .foregroundStyle(isReady ? Design.bg : .primary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(breathingAnimation) { breathing = true }
            }
            .accessibilityLabel(isReady ? "capsule ready to open" : "capsule sealed")
            .contentShape(.circle)
            .onTapGesture {
                if isReady {
                    openHaptic.toggle()
                    onOpenTap?()
                }
            }
            .sensoryFeedback(.impact(weight: .heavy), trigger: openHaptic)
            .accessibilityAddTraits(isReady ? .isButton : [])

            VStack(spacing: 6) {
                Text(capsule.title.isEmpty ? capsule.type.label : capsule.title)
                    .font(.title3.weight(.medium))
                    .tracking(Design.trackingWide)

                if let subtitle = headerSubtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .tracking(Design.trackingNormal)
                }
            }
        }
        .padding(.top, 32)
    }
}
