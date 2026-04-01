import SwiftUI
import StoreKit
import RevenueCat
import UserNotifications

struct OnboardingView: View {
    @Environment(StoreManager.self) private var storeManager
    @Environment(NotificationManager.self) private var notificationManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("pendingFirstCapsule") private var pendingFirstCapsule = false

    @State private var step = 0
    @State private var stepTrigger = false

    let onComplete: () -> Void

    private var totalSteps: Int { 9 }

    private var buttonLabel: String {
        switch step {
        case 0: "do I?"
        case 1: "i want to"
        case 2: "i am patient"
        case 3: "show me more"
        case 4: "that's beautiful"
        case 5: "i will decide now"
        case 7: "gladly"
        case 8: "capture it now"
        default: "continue"
        }
    }

    var body: some View {
        ZStack {
            Design.bg
                .ignoresSafeArea()

            VStack(spacing: 0) {
                OnboardingProgressBar(current: step, total: totalSteps)
                    .padding(.bottom, 16)

                Group {
                    switch step {
                    case 0:
                        ExistentialStepContent()
                            .transition(stepTransition)
                    case 1:
                        ConceptStepContent()
                            .transition(stepTransition)
                    case 2:
                        TensionStepContent()
                            .transition(stepTransition)
                    case 3:
                        CapsuleTypesStepContent()
                            .transition(stepTransition)
                    case 4:
                        SocialStepContent()
                            .transition(stepTransition)
                    case 5:
                        NotificationStepContent()
                            .transition(stepTransition)
                    case 6:
                        OfferStepContent(storeManager: storeManager, onPurchase: {
                            Task {
                                let success = await storeManager.purchase()
                                if success { advanceStep() }
                            }
                        })
                            .transition(stepTransition)
                    case 7:
                        RatingStepContent()
                            .transition(stepTransition)
                    default:
                        InvitationStepContent(onStart: { completeOnboarding() })
                            .transition(stepTransition)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, step == 6 ? 160 : 40)
            }
            .overlay { FloatingParticlesView().ignoresSafeArea() }
            .overlay(alignment: .bottom) {
                Group {
                    if step != 6 {
                        OnboardingButton(label: buttonLabel) {
                            handleAdvance()
                        }
                    } else {
                        OfferStepButtons(
                            storeManager: storeManager,
                            onPurchased: { advanceStep() },
                            onSkip: { advanceStep() }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: stepTrigger)
    }

    private func handleAdvance() {
        if step == 5 {
            // Notification permission step — request, then advance
            Task {
                _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                await notificationManager.checkNotificationStatus()
                if storeManager.isPro {
                    // Skip paywall if already pro
                    stepTrigger.toggle()
                    withAnimation(Design.springSnappy) { step = 7 }
                } else {
                    advanceStep()
                }
            }
            return
        } else if step == 7 {
            // Rating step — request review, then advance
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                AppStore.requestReview(in: windowScene)
            }
            advanceStep()
        } else if step == 8 {
            completeOnboarding()
        } else {
            advanceStep()
        }
    }

    private var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    private func advanceStep() {
        stepTrigger.toggle()
        withAnimation(Design.springSnappy) {
            step += 1
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
        pendingFirstCapsule = true
        onComplete()
    }
}

// MARK: - Screen 0: The Existential Opener

private struct ExistentialStepContent: View {
    @State private var appeared = false
    @State private var whisperAppeared = false
    @State private var whisperBreathing = false
    @State private var starGlow = false
    @State private var starBreathing = false

    var body: some View {
        ZStack {
            // Main content — centered
            VStack(spacing: 20) {
                // The star — a tiny point of light
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(.primary.opacity(starGlow ? 0.04 : 0))
                        .frame(width: 32, height: 32)
                        .scaleEffect(starBreathing ? 1.3 : 1.0)

                    // Middle soft glow
                    Circle()
                        .fill(.primary.opacity(starGlow ? 0.08 : 0))
                        .frame(width: 12, height: 12)
                        .scaleEffect(starBreathing ? 1.15 : 1.0)

                    // The point itself
                    Circle()
                        .fill(.primary)
                        .frame(width: 4, height: 4)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.1)
                }

                Text("__you__ exist only now.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .tracking(Design.trackingNormal)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
            }

            // Bottom whisper
            VStack {
                Spacer()
                Text("•  you do  •")
                    .font(.caption)
                    .tracking(Design.trackingWide)
                    .foregroundStyle(.primary.opacity(whisperAppeared ? (whisperBreathing ? 0.1 : 0.3) : 0))
                    .offset(y: whisperAppeared ? 0 : 8)
                    .padding(.bottom, 80)
            }
        }
        .onAppear {
            // Star appears first — a point emerging from nothing
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) { appeared = true }
            // Glow fades in after the dot appears
            withAnimation(.easeOut(duration: 1.5).delay(0.8)) { starGlow = true }
            // Gentle breathing — the star is alive
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true).delay(1.5)) { starBreathing = true }
            // Whisper text
            withAnimation(.easeOut(duration: 1.2).delay(1.5)) { whisperAppeared = true }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(2.7)) { whisperBreathing = true }
        }
    }
}

// MARK: - Screen 1: The Concept (content only)

private struct ConceptStepContent: View {
    @State private var appeared = false
    @State private var starAppeared = false
    @State private var starBreathing = false

    var body: some View {
        ZStack {
            // Main content — centered
            VStack(spacing: 24) {
                TimelineView(.animation) { timeline in
                    let seconds = timeline.date.timeIntervalSinceReferenceDate
                    let rotation = -30.0 + (seconds.truncatingRemainder(dividingBy: 30.0) / 30.0 * 360.0)

                    Image(systemName: "moon.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.primary)
                        .rotationEffect(.degrees(rotation))
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.5), value: appeared)

                Text("so treasure a thought\nfor the future")
                    .font(.title2.weight(.light))
                    .tracking(Design.trackingNormal)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

                Text("for yourself or a loved one.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .tracking(Design.trackingTight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
            }

            // Bottom whisper
            VStack {
                Spacer()
                Text("•  it will be fine  •")
                    .font(.caption)
                    .tracking(Design.trackingWide)
                    .foregroundStyle(.primary.opacity(starAppeared ? (starBreathing ? 0.1 : 0.3) : 0))
                    .offset(y: starAppeared ? 0 : 8)
                    .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            withAnimation(.easeOut(duration: 1.2).delay(1.0)) { starAppeared = true }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(2.2)) { starBreathing = true }
        }
    }
}

// MARK: - Screen 2: The Tension (content only)

private struct TensionStepContent: View {
    @State private var appeared = false
    @State private var whisperAppeared = false
    @State private var whisperBreathing = false

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                TimelineView(.animation) { timeline in
                    let seconds = timeline.date.timeIntervalSinceReferenceDate
                    let angle = (seconds.truncatingRemainder(dividingBy: 20.0) / 20.0) * 360.0

                    OnboardingClockView(hourAngle: angle)
                        .frame(width: 56, height: 56)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.5), value: appeared)

                Text("waiting will be involved")
                    .font(.title2.weight(.light))
                    .tracking(Design.trackingNormal)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

                Text("no peeking. no extending.\nthat is the point.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .tracking(Design.trackingTight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
            }

            VStack {
                Spacer()
                Text("•  you got time, still  •")
                    .font(.caption)
                    .tracking(Design.trackingWide)
                    .foregroundStyle(.primary.opacity(whisperAppeared ? (whisperBreathing ? 0.1 : 0.3) : 0))
                    .offset(y: whisperAppeared ? 0 : 8)
                    .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            withAnimation(.easeOut(duration: 1.2).delay(1.0)) { whisperAppeared = true }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(2.2)) { whisperBreathing = true }
        }
    }
}

// MARK: - Screen 3: Capsule Types

private struct CapsuleTypesStepContent: View {
    @State private var appeared = false
    @State private var ringBreathing = false
    @State private var whisperAppeared = false
    @State private var whisperBreathing = false

    private let types: [(icon: String, label: String)] = [
        ("doc.text.fill", "text"),
        ("photo.fill", "photo"),
        ("waveform", "voice")
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                ZStack {
                    // Breathing ring behind the icons
                    SwiftUI.Capsule()
                        .stroke(Color.primary.opacity(ringBreathing ? 0 : 0.12), lineWidth: 1)
                        .frame(width: 200, height: 72)
                        .scaleEffect(ringBreathing ? 1.1 : 1.0)

                    HStack(spacing: 20) {
                        ForEach(Array(types.enumerated()), id: \.offset) { index, type in
                            Circle()
                                .fill(Design.fg)
                                .frame(width: 48, height: 48)
                                .overlay {
                                    Image(systemName: type.icon)
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(Design.bg)
                                }
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 12)
                                .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.15), value: appeared)
                        }
                    }
                }

                Text("three ways to seal a moment")
                    .font(.title2.weight(.light))
                    .tracking(Design.trackingNormal)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: appeared)

                Text("write it. photograph it. say it.\neach becomes a capsule, locked in time.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .tracking(Design.trackingTight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.6), value: appeared)
            }

            VStack {
                Spacer()
                Text("•  choose wisely, or don't  •")
                    .font(.caption)
                    .tracking(Design.trackingWide)
                    .foregroundStyle(.primary.opacity(whisperAppeared ? (whisperBreathing ? 0.1 : 0.3) : 0))
                    .offset(y: whisperAppeared ? 0 : 8)
                    .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.8)) { ringBreathing = true }
            withAnimation(.easeOut(duration: 1.2).delay(1.0)) { whisperAppeared = true }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(2.2)) { whisperBreathing = true }
        }
    }
}

// MARK: - Screen 4: Social / Sending

private struct SocialStepContent: View {
    @State private var appeared = false
    @State private var whisperAppeared = false
    @State private var whisperBreathing = false

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Two circles with a paper plane arcing between them
                TimelineView(.animation) { timeline in
                    OnboardingPlaneView(date: timeline.date)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.5), value: appeared)

                Text("seal something for\nsomeone you love")
                    .font(.title2.weight(.light))
                    .tracking(Design.trackingNormal)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

                Text("send a capsule to someone.\nthey will wait alongside you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .tracking(Design.trackingTight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
            }

            VStack {
                Spacer()
                Text("•  patience, together  •")
                    .font(.caption)
                    .tracking(Design.trackingWide)
                    .foregroundStyle(.primary.opacity(whisperAppeared ? (whisperBreathing ? 0.1 : 0.3) : 0))
                    .offset(y: whisperAppeared ? 0 : 8)
                    .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            withAnimation(.easeOut(duration: 1.2).delay(1.0)) { whisperAppeared = true }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(2.2)) { whisperBreathing = true }
        }
    }
}

// MARK: - Animated paper plane

private struct OnboardingPlaneView: View {
    let date: Date

    var body: some View {
        let t = date.timeIntervalSinceReferenceDate
        // 3-second cycle: fly right (0-1.2), pause (1.2-1.8), fly left (1.8-3.0)
        let cycle = t.truncatingRemainder(dividingBy: 3.0)
        let goingRight = cycle < 1.8
        let rawProgress = goingRight
            ? (cycle < 1.2 ? cycle / 1.2 : 1.0)
            : (cycle - 1.8) / 1.2
        let eased = rawProgress < 1.0 ? 0.5 - 0.5 * cos(rawProgress * .pi) : 1.0
        let x = goingRight ? -28.0 + eased * 56.0 : 28.0 - eased * 56.0
        let arcY = -16.0 * sin(eased * .pi)
        let rotation = goingRight ? -15.0 * cos(eased * .pi) : 180.0 - 15.0 * cos(eased * .pi)
        let planeOpacity = min(1.0, sin(max(0.01, eased) * .pi) * 2.0)

        ZStack {
            Circle()
                .fill(Design.fg)
                .frame(width: 36, height: 36)
                .offset(x: -46)

            Circle()
                .fill(Design.fg)
                .frame(width: 36, height: 36)
                .offset(x: 46)

            Image(systemName: "paperplane.fill")
                .font(.system(size: 13))
                .foregroundStyle(Design.fg)
                .rotationEffect(.degrees(rotation))
                .offset(x: x, y: arcY)
                .opacity(planeOpacity)
        }
        .frame(width: 128, height: 56)
    }
}

// MARK: - Screen 5: Notifications

private struct NotificationStepContent: View {
    @State private var appeared = false
    @State private var whisperAppeared = false
    @State private var whisperBreathing = false

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                OnboardingBellView()
                    .frame(width: 56, height: 56)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5), value: appeared)

                VStack(spacing: 12) {
                    Text("allow us to notify you")
                        .font(.title2.weight(.light))
                        .tracking(Design.trackingNormal)
                        .multilineTextAlignment(.center)

                    Text("when the time comes.\nwe will be subtle.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .tracking(Design.trackingTight)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
            }

            VStack {
                Spacer()
                Text("•  be wise  •")
                    .font(.caption)
                    .tracking(Design.trackingWide)
                    .foregroundStyle(.primary.opacity(whisperAppeared ? (whisperBreathing ? 0.1 : 0.3) : 0))
                    .offset(y: whisperAppeared ? 0 : 8)
                    .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            withAnimation(.easeOut(duration: 1.2).delay(1.0)) { whisperAppeared = true }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(2.2)) { whisperBreathing = true }
        }
    }
}

// MARK: - Animated bell

private struct OnboardingBellView: View {
    @State private var swinging = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            // Gentle swing: oscillates between -8° and +8°, with varying speed
            let angle = sin(t * 1.8) * 8.0 * (1.0 + sin(t * 0.4) * 0.3)

            Image(systemName: "bell.fill")
                .font(.system(size: 48))
                .foregroundStyle(Design.fg)
                .rotationEffect(.degrees(reduceMotion ? 0 : angle), anchor: .top)
        }
    }
}

// MARK: - Custom clock face

private struct OnboardingClockView: View {
    let hourAngle: Double

    var body: some View {
        ZStack {
            // Filled clock face
            Circle()
                .fill(Design.fg)

            // Hour markers
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(Design.bg)
                    .frame(width: i % 3 == 0 ? 3 : 1.5, height: i % 3 == 0 ? 3 : 1.5)
                    .offset(y: -23)
                    .rotationEffect(.degrees(Double(i) * 30))
            }

            // Center dot
            Circle()
                .fill(Design.bg)
                .frame(width: 4, height: 4)

            // Hour hand
            RoundedRectangle(cornerRadius: 1)
                .fill(Design.bg)
                .frame(width: 1.8, height: 14)
                .offset(y: -7)
                .rotationEffect(.degrees(hourAngle))

            // Minute hand
            RoundedRectangle(cornerRadius: 0.5)
                .fill(Design.bg)
                .frame(width: 1, height: 20)
                .offset(y: -10)
                .rotationEffect(.degrees(hourAngle * 12))
        }
    }
}

// MARK: - Screen 6: The Offer (content only)

private struct OfferStepContent: View {
    @Bindable var storeManager: StoreManager
    var onPurchase: () -> Void = {}
    @State private var appeared = false
    @State private var pulsing = false
    @State private var iconTapTrigger = false

    var body: some View {
        VStack(spacing: 28) {
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
            .onTapGesture {
                iconTapTrigger.toggle()
                onPurchase()
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: iconTapTrigger)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel("purchase lacuna +")
            .opacity(appeared ? 1 : 0)

            VStack(spacing: 12) {
                Text("lacuna +")
                    .font(.title2.weight(.medium))
                    .tracking(Design.trackingWide)

                Text("unlock everything. forever.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .tracking(Design.trackingNormal)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

            VStack(alignment: .leading, spacing: 16) {
                offerFeatureRow("unlimited capsules", detail: "text, photo & voice")
                offerFeatureRow("send to loved ones", detail: "share time capsules")
                offerFeatureRow("camera capture", detail: "snapshots of your life")
            }
            .fixedSize(horizontal: true, vertical: false)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { pulsing = true }
        }
    }

    private func offerFeatureRow(_ title: String, detail: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark")
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .tracking(Design.trackingNormal)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .tracking(Design.trackingTight)
            }
        }
    }
}

// MARK: - Screen 6: Offer buttons (separate, pinned to bottom)

private struct OfferStepButtons: View {
    @Bindable var storeManager: StoreManager
    let onPurchased: () -> Void
    let onSkip: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var purchaseTrigger = false
    @State private var restoreTrigger = false
    @State private var skipTrigger = false
    @State private var restoreMessage: String?
    @State private var whisperAppeared = false
    @State private var whisperBreathing = false

    private var priceText: String {
        if let product = storeManager.proProduct {
            return "\(product.localizedPriceString) · one time"
        }
        return "loading..."
    }

    private var buttonBg: Color { Design.fg }
    private var buttonFg: Color { Design.bg }

    var body: some View {
        VStack(spacing: 16) {
            Text("•  we must ask  •")
                .font(.caption)
                .tracking(Design.trackingWide)
                .foregroundStyle(.primary.opacity(whisperAppeared ? (whisperBreathing ? 0.1 : 0.3) : 0))
                .offset(y: whisperAppeared ? 0 : 8)
                .padding(.bottom, 4)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.2).delay(0.8)) { whisperAppeared = true }
                    withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(2.0)) { whisperBreathing = true }
                }

            Button {
                purchaseTrigger.toggle()
                Task {
                    let success = await storeManager.purchase()
                    if success { onPurchased() }
                }
            } label: {
                Group {
                    if storeManager.purchaseInProgress {
                        ProgressView()
                            .tint(buttonFg)
                    } else {
                        Text(priceText)
                            .font(.body.weight(.medium))
                            .tracking(Design.trackingButton)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(buttonBg)
                .foregroundColor(buttonFg)
            }
            .buttonStyle(.plain)
            .disabled(storeManager.purchaseInProgress || storeManager.proProduct == nil)
            .opacity(storeManager.proProduct == nil ? 0.5 : 1)
            .sensoryFeedback(.impact(weight: .medium), trigger: purchaseTrigger)

            Button {
                skipTrigger.toggle()
                onSkip()
            } label: {
                Text("perhaps later")
                    .font(.body.weight(.medium))
                    .tracking(Design.trackingButton)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .overlay {
                        Rectangle()
                            .strokeBorder(Color.primary, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .light), trigger: skipTrigger)

            Button {
                restoreTrigger.toggle()
                Task {
                    let result = await storeManager.restore()
                    switch result {
                    case .restored:
                        onPurchased()
                    case .noPurchaseFound:
                        restoreMessage = "no previous purchase found."
                    case .cancelled:
                        break
                    case .failed:
                        restoreMessage = "couldn't connect to the app store. check your internet and try again."
                    }
                }
            } label: {
                Text("restore purchase")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .tracking(Design.trackingNormal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .light), trigger: restoreTrigger)
        }
        .alert("restore", isPresented: Binding(
            get: { restoreMessage != nil },
            set: { if !$0 { restoreMessage = nil } }
        )) {} message: {
            Text(restoreMessage ?? "")
        }
    }
}

// MARK: - Screen 7: Rating

private struct RatingStepContent: View {
    @State private var appeared = false
    @State private var heartBreathing = false
    @State private var whisperAppeared = false
    @State private var whisperBreathing = false

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(heartBreathing ? 0 : 0.15), lineWidth: 1)
                        .frame(width: 88, height: 88)
                        .scaleEffect(heartBreathing ? 1.3 : 1.0)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Design.fg)
                        .scaleEffect(heartBreathing ? 1.08 : 1.0)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: appeared)

                Text("if this moved you")
                    .font(.title2.weight(.light))
                    .tracking(Design.trackingNormal)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

                Text("a small rating helps others\nfind their way here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .tracking(Design.trackingTight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
            }

            VStack {
                Spacer()
                Text("•  no pressure, truly  •")
                    .font(.caption)
                    .tracking(Design.trackingWide)
                    .foregroundStyle(.primary.opacity(whisperAppeared ? (whisperBreathing ? 0.1 : 0.3) : 0))
                    .offset(y: whisperAppeared ? 0 : 8)
                    .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.3)) { heartBreathing = true }
            withAnimation(.easeOut(duration: 1.2).delay(1.0)) { whisperAppeared = true }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(2.2)) { whisperBreathing = true }
        }
    }
}

// MARK: - Screen 8: The Invitation (content only)

private struct InvitationStepContent: View {
    var onStart: () -> Void = {}
    @State private var appeared = false
    @State private var pulsing = false
    @State private var tapTrigger = false
    @State private var whisperAppeared = false
    @State private var whisperBreathing = false

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(pulsing ? 0 : 0.2), lineWidth: 1)
                        .frame(width: 88, height: 88)
                        .scaleEffect(pulsing ? 1.3 : 1.0)

                    Circle()
                        .fill(Design.fg)
                        .frame(width: 72, height: 72)

                    Image(systemName: "plus")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(Design.bg)
                }
                .contentShape(.circle)
                .onTapGesture {
                    tapTrigger.toggle()
                    onStart()
                }
                .sensoryFeedback(.impact(weight: .medium), trigger: tapTrigger)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel("create your first capsule")
                .opacity(appeared ? 1 : 0)

                Text("create your first capsule")
                    .font(.title2.weight(.light))
                    .tracking(Design.trackingNormal)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

                Text("seal a moment for the future.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .tracking(Design.trackingTight)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
            }

            VStack {
                Spacer()
                Text("•  tick tock  •")
                    .font(.caption)
                    .tracking(Design.trackingWide)
                    .foregroundStyle(.primary.opacity(whisperAppeared ? (whisperBreathing ? 0.1 : 0.3) : 0))
                    .offset(y: whisperAppeared ? 0 : 8)
                    .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { pulsing = true }
            withAnimation(.easeOut(duration: 1.2).delay(1.0)) { whisperAppeared = true }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(2.2)) { whisperBreathing = true }
        }
    }
}

// MARK: - Shared Button

private struct OnboardingButton: View {
    let label: String
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.body.weight(.medium))
                .tracking(Design.trackingButton)
                .foregroundStyle(Design.bg)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Design.fg)
        }
        .buttonStyle(.plain)
        .overlay { ButtonPulse() }
    }
}

// MARK: - Previews

#Preview("screen 0: existential") {
    OnboardingPreviewWrapper(startStep: 0)
}

#Preview("screen 1: concept") {
    OnboardingPreviewWrapper(startStep: 1)
}

#Preview("screen 2: tension") {
    OnboardingPreviewWrapper(startStep: 2)
}

#Preview("screen 3: capsule types") {
    OnboardingPreviewWrapper(startStep: 3)
}

#Preview("screen 4: social") {
    OnboardingPreviewWrapper(startStep: 4)
}

#Preview("screen 5: notifications") {
    OnboardingPreviewWrapper(startStep: 5)
}

#Preview("screen 6: offer") {
    OnboardingPreviewWrapper(startStep: 6)
}

#Preview("screen 7: rating") {
    OnboardingPreviewWrapper(startStep: 7)
}

#Preview("screen 8: invitation") {
    OnboardingPreviewWrapper(startStep: 8)
}

private struct OnboardingPreviewWrapper: View {
    let startStep: Int

    private var buttonLabel: String {
        switch startStep {
        case 0: "do I?"
        case 1: "i want to"
        case 2: "i am patient"
        case 3: "show me more"
        case 4: "that's beautiful"
        case 5: "i will decide now"
        case 7: "gladly"
        case 8: "capture it now"
        default: "continue"
        }
    }

    var body: some View {
        ZStack {
            Design.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                OnboardingProgressBar(current: startStep, total: 9)
                    .padding(.bottom, 16)

                Group {
                    switch startStep {
                    case 0: ExistentialStepContent()
                    case 1: ConceptStepContent()
                    case 2: TensionStepContent()
                    case 3: CapsuleTypesStepContent()
                    case 4: SocialStepContent()
                    case 5: NotificationStepContent()
                    case 6: OfferStepContent(storeManager: StoreManager.shared)
                    case 7: RatingStepContent()
                    default: InvitationStepContent()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, startStep == 6 ? 160 : 40)
            }
            .overlay { FloatingParticlesView().ignoresSafeArea() }
            .overlay(alignment: .bottom) {
                if startStep != 6 {
                    OnboardingButton(label: buttonLabel) {}
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                } else {
                    OfferStepButtons(storeManager: StoreManager.shared, onPurchased: {}, onSkip: {})
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                }
            }
        }
        .environment(NotificationManager.shared)
        .environment(StoreManager.shared)
    }
}
