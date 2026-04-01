import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var storeManager: StoreManager
    @State private var purchaseTrigger = false
    @State private var restoreTrigger = false
    @State private var closeTrigger = false
    @State private var appeared = false
    @State private var pulsing = false
    @State private var iconTapTrigger = false
    @State private var restoreMessage: String?

    let reason: PaywallReason

    private var buttonBg: Color { Design.fg }
    private var buttonFg: Color { Design.bg }

    var body: some View {
        ZStack {
            Design.bg
                .ignoresSafeArea()

            FloatingParticlesView()

            VStack(spacing: 0) {
                // Header — matches onboarding and settings style
                HStack {
                    Text("+")
                        .font(.title3.weight(.medium))
                        .tracking(Design.trackingWide)

                    Spacer()

                    Button {
                        closeTrigger.toggle()
                        dismiss()
                    } label: {
                        Text("close")
                            .font(.body.weight(.medium))
                            .tracking(Design.trackingNormal)
                            .foregroundColor(buttonFg)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(buttonBg)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: closeTrigger)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)

                // Content — centered, matching onboarding layout
                Group {
                    VStack(spacing: 28) {
                        // Pulsing lock icon — tappable to purchase
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
                            Task {
                                let success = await storeManager.purchase()
                                if success { dismiss() }
                            }
                        }
                        .sensoryFeedback(.impact(weight: .medium), trigger: iconTapTrigger)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel("purchase lacuna +")

                        VStack(spacing: 12) {
                            Text("lacuna +")
                                .font(.title2.weight(.medium))
                                .tracking(Design.trackingWide)

                            Text("unlock everything. forever.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .tracking(Design.trackingNormal)
                        }

                        // Reason-specific message (only for contextual paywalls)
                        if let message = reason.message {
                            Text(message)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .tracking(Design.trackingNormal)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }

                        // Feature list — left-aligned within centered block
                        VStack(alignment: .leading, spacing: 16) {
                            featureRow("unlimited capsules", detail: "text, photo & voice")
                            featureRow("send to loved ones", detail: "share time capsules")
                            featureRow("camera capture", detail: "snapshots of your life")
                        }
                        .fixedSize(horizontal: true, vertical: false)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 160)

                Spacer(minLength: 0)
            }
            .overlay(alignment: .bottom) {
                // Bottom buttons — matching onboarding exactly
                VStack(spacing: 16) {
                    // Purchase button
                    Button {
                        purchaseTrigger.toggle()
                        Task {
                            let success = await storeManager.purchase()
                            if success { dismiss() }
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

                    // Restore purchase
                    Button {
                        restoreTrigger.toggle()
                        Task {
                            let result = await storeManager.restore()
                            switch result {
                            case .restored:
                                dismiss()
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
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .alert("restore", isPresented: Binding(
            get: { restoreMessage != nil },
            set: { if !$0 { restoreMessage = nil } }
        )) {} message: {
            Text(restoreMessage ?? "")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) { appeared = true }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { pulsing = true }
        }
    }

    private var priceText: String {
        if let product = storeManager.proProduct {
            return "\(product.localizedPriceString) · one time"
        }
        return "loading..."
    }

    private func featureRow(_ title: String, detail: String) -> some View {
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

// MARK: - Paywall Reason

enum PaywallReason: Identifiable {
    var id: Self { self }
    case generic
    case textLimit
    case photoLimit
    case voiceGated
    case sendGated
    case cameraGated

    var message: String? {
        switch self {
        case .generic:
            nil
        case .textLimit:
            "you've reached the free limit of 3 active text capsules."
        case .photoLimit:
            "you've reached the free limit of 1 active photo capsule."
        case .voiceGated:
            "you've reached the free limit of 1 active voice capsule."
        case .sendGated:
            "sending time capsules to loved ones\nis a + feature."
        case .cameraGated:
            "camera capture is a pro feature.\nyou can still choose photos from your library."
        }
    }
}
