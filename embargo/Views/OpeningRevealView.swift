import SwiftUI
import SwiftData

struct OpeningRevealView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let capsule: Capsule
    let onComplete: () -> Void

    // Phase states
    @State private var phase1 = false   // anticipation
    @State private var phase2 = false   // the break

    // Haptic triggers (each toggles to fire)
    @State private var haptic1 = false  // 0.0s light
    @State private var haptic2 = false  // 0.5s soft
    @State private var haptic3 = false  // 0.9s medium
    @State private var haptic4 = false  // 1.0s HEAVY
    @State private var haptic5 = false  // 1.15s rigid
    @State private var haptic6 = false  // 1.8s light

    var body: some View {
        ZStack {
            // Layer 1: Background
            Design.bg
                .ignoresSafeArea()

            // Layer 2: Background dim (Phase 1)
            if !reduceMotion {
                Design.fg
                    .ignoresSafeArea()
                    .opacity(phase1 && !phase2 ? 0.05 : 0)
                    .animation(.easeIn(duration: 0.5), value: phase1)
                    .animation(.easeOut(duration: 0.15), value: phase2)
            }

            // Layer 3: Line curtain (dissolves after break)
            LineCurtainView(dissolving: phase2)

            // Layer 4: Ceremony elements (cardinal lines, lock, flash, radial burst)
            RevealCeremonyView(phase1Active: phase1, phase2Active: phase2)

            // Layer 5: Triple ring burst (Phase 2)
            RevealBurstView(isActive: phase2)
        }
        // Haptic feedback chain
        .sensoryFeedback(.impact(weight: .light), trigger: haptic1)
        .sensoryFeedback(.impact(weight: .light), trigger: haptic2)
        .sensoryFeedback(.impact(weight: .medium), trigger: haptic3)
        .sensoryFeedback(.impact(weight: .heavy), trigger: haptic4)
        .sensoryFeedback(.impact(weight: .heavy), trigger: haptic5)
        .sensoryFeedback(.impact(weight: .light), trigger: haptic6)
        .onAppear {
            if reduceMotion {
                runReducedMotion()
            } else {
                runFullCeremony()
            }
        }
    }

    // MARK: - Full ceremony (~2.5s)

    private func runFullCeremony() {
        Task { @MainActor in
            // Phase 1: Anticipation (0.0s–1.0s)
            haptic1.toggle()  // 0.0s — light
            LockSound.playTension()
            withAnimation { phase1 = true }

            try await Task.sleep(for: .milliseconds(500))
            haptic2.toggle()  // 0.5s — soft

            try await Task.sleep(for: .milliseconds(400))
            haptic3.toggle()  // 0.9s — medium

            // Phase 2: The Break (1.0s)
            try await Task.sleep(for: .milliseconds(100))
            haptic4.toggle()  // 1.0s — HEAVY
            LockSound.playRelease()
            withAnimation { phase2 = true }

            try await Task.sleep(for: .milliseconds(50))
            RevealTone.play()

            try await Task.sleep(for: .milliseconds(100))
            haptic5.toggle()  // 1.15s — rigid aftershock

            // Let the burst and glow settle
            try await Task.sleep(for: .milliseconds(800))
            haptic6.toggle()  // light — settled

            // Mark opened and auto-dismiss
            capsule.openedAt = Date.now
            try? modelContext.save()
            onComplete()

            try await Task.sleep(for: .seconds(3))
            RatingManager.requestIfEligible()
        }
    }

    // MARK: - Reduced motion (~0.8s)

    private func runReducedMotion() {
        Task { @MainActor in
            haptic4.toggle()
            RevealTone.play()

            try await Task.sleep(for: .milliseconds(800))

            capsule.openedAt = Date.now
            try? modelContext.save()
            onComplete()

            try await Task.sleep(for: .seconds(3))
            RatingManager.requestIfEligible()
        }
    }
}
