import SwiftUI

/// Visual ceremony elements: rotating lock mechanism, cardinal lines, flash overlay, center glow
struct RevealCeremonyView: View {
    let phase1Active: Bool   // anticipation: lock appears, tick ring rotates
    let phase2Active: Bool   // break: shackle lifts, lock shatters, lines shatter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if !reduceMotion {
            ZStack {
                // Cardinal lines — converge inward during Phase 1, shatter outward in Phase 2
                CardinalLinesView(converging: phase1Active, shattering: phase2Active)

                // Center glow — warm pulse at the break
                CenterGlowView(active: phase2Active)

                // Rotating lock mechanism
                RotatingLockView(phase1Active: phase1Active, phase2Active: phase2Active)

                // Radial burst lines — 12 lines radiating from center at Phase 2
                if phase2Active {
                    RadialBurstLines()
                }

                // Flash overlay
                Rectangle()
                    .fill(Design.fg)
                    .ignoresSafeArea()
                    .opacity(0)
                    .modifier(FlashModifier(active: phase2Active))
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

// MARK: - Rotating Lock

private struct RotatingLockView: View {
    let phase1Active: Bool
    let phase2Active: Bool

    // Shackle lift
    @State private var shackleLifted = false
    // Shard explosion
    @State private var shattered = false

    // Tick ring rotation
    private let tickCount = 16

    // Pre-computed shard data (positions AND sizes)
    private static let shards: [LockShardData] = {
        (0..<8).map { i in
            let angle = Double(i) * 45.0 + Double.random(in: -20...20)
            let radians = angle * .pi / 180
            let distance = CGFloat.random(in: 140...240)
            return LockShardData(
                id: i,
                offsetX: cos(radians) * distance,
                offsetY: sin(radians) * distance,
                rotation: Double.random(in: -270...270),
                width: CGFloat.random(in: 10...24),
                height: CGFloat.random(in: 6...18)
            )
        }
    }()

    var body: some View {
        ZStack {
            // Tick ring — rotates during phase1
            TickRingView(tickCount: tickCount)
                .rotationEffect(.degrees(phase1Active ? (phase2Active ? 200 : 160) : 0))
                .opacity(phase1Active ? (shattered ? 0 : 0.5) : 0)
                .scaleEffect(phase1Active ? (shattered ? 1.8 : 1.0) : 0.7)
                .animation(
                    phase2Active
                        ? .easeOut(duration: 0.35)
                        : .easeIn(duration: 1.0),
                    value: phase1Active
                )
                .animation(.easeOut(duration: 0.35), value: shattered)
                .animation(.easeOut(duration: 0.3), value: phase2Active)

            // Shackle
            ShacklePath()
                .stroke(Design.fg, lineWidth: 3.5)
                .frame(width: 32, height: 28)
                .offset(y: shackleLifted ? -54 : -38)
                .opacity(phase1Active && !shattered ? 1 : 0)
                .animation(.easeOut(duration: 0.3), value: phase1Active)
                .animation(.spring(response: 0.25, dampingFraction: 0.5), value: shackleLifted)
                .animation(.easeOut(duration: 0.2), value: shattered)

            // Lock body
            ZStack {
                Rectangle()
                    .fill(Design.fg)
                    .frame(width: 52, height: 40)

                // Keyhole — diamond shape
                Rectangle()
                    .fill(Design.bg)
                    .frame(width: 8, height: 8)
                    .rotationEffect(.degrees(45))
                    .offset(y: -3)

                // Keyhole slot
                Rectangle()
                    .fill(Design.bg)
                    .frame(width: 3, height: 10)
                    .offset(y: 4)
            }
            .opacity(phase1Active && !shattered ? 1 : 0)
            .scaleEffect(phase1Active && !phase2Active ? 1.06 : 1.0)
            .rotationEffect(.degrees(lockBodyRotation))
            .animation(.easeInOut(duration: 1.0), value: phase1Active)
            .animation(.spring(response: 0.15, dampingFraction: 0.4), value: phase2Active)
            .animation(.easeOut(duration: 0.25), value: shattered)

            // Shards — start at center, fly outward
            ForEach(Self.shards) { shard in
                Rectangle()
                    .fill(Design.fg)
                    .frame(width: shard.width, height: shard.height)
                    .offset(
                        x: shattered ? shard.offsetX : 0,
                        y: shattered ? shard.offsetY : 0
                    )
                    .rotationEffect(.degrees(shattered ? shard.rotation : 0))
                    .opacity(shattered ? 0 : (phase2Active ? 1 : 0))
                    .scaleEffect(shattered ? 0.3 : 1.0)
                    .animation(.easeOut(duration: 0.5), value: shattered)
            }
        }
        .onChange(of: phase2Active) { _, active in
            guard active else { return }
            // Step 1: Lift shackle with spring bounce
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                shackleLifted = true
            }
            // Step 2: Shatter after brief dramatic hold
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(180))
                withAnimation(.easeOut(duration: 0.5)) {
                    shattered = true
                }
            }
        }
    }

    private var lockBodyRotation: Double {
        if phase2Active { return 3 }     // snap back on break
        if phase1Active { return -12 }   // wind up tension
        return 0
    }
}

private struct LockShardData: Identifiable {
    let id: Int
    let offsetX: CGFloat
    let offsetY: CGFloat
    let rotation: Double
    let width: CGFloat
    let height: CGFloat
}

// MARK: - Center Glow

private struct CenterGlowView: View {
    let active: Bool
    @State private var glowOpacity: Double = 0
    @State private var glowScale: Double = 0.3

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Design.fg.opacity(0.3),
                        Design.fg.opacity(0.1),
                        Design.fg.opacity(0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 120
                )
            )
            .frame(width: 240, height: 240)
            .scaleEffect(glowScale)
            .opacity(glowOpacity)
            .onChange(of: active) { _, isActive in
                if isActive {
                    // Bloom outward
                    withAnimation(.easeOut(duration: 0.3)) {
                        glowOpacity = 1
                        glowScale = 1.0
                    }
                    // Fade away
                    withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                        glowOpacity = 0
                        glowScale = 1.5
                    }
                }
            }
    }
}

// MARK: - Tick Ring

private struct TickRingView: View {
    let tickCount: Int

    var body: some View {
        ZStack {
            ForEach(0..<tickCount, id: \.self) { i in
                Rectangle()
                    .fill(Design.fg)
                    .frame(width: i % 4 == 0 ? 2.5 : 1.5, height: i % 4 == 0 ? 12 : 7)
                    .offset(y: -64)
                    .rotationEffect(.degrees(Double(i) * (360.0 / Double(tickCount))))
            }
        }
        .frame(width: 140, height: 140)
    }
}

// MARK: - Shackle Path (squared U-shape)

private struct ShacklePath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let inset: CGFloat = 2
        // Left vertical
        p.move(to: CGPoint(x: inset, y: rect.maxY))
        p.addLine(to: CGPoint(x: inset, y: inset))
        // Top horizontal
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: inset))
        // Right vertical
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY))
        return p
    }
}

// MARK: - Cardinal Lines

private struct CardinalLinesView: View {
    let converging: Bool
    let shattering: Bool

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let stopDistance: CGFloat = 80

            // Top line
            Rectangle()
                .fill(Color.primary.opacity(lineOpacity))
                .frame(width: 1, height: lineLength(full: center.y - stopDistance, shatter: geo.size.height))
                .position(x: center.x, y: lineY(center: center.y, stopDistance: stopDistance, full: geo.size.height, isTop: true))

            // Bottom line
            Rectangle()
                .fill(Color.primary.opacity(lineOpacity))
                .frame(width: 1, height: lineLength(full: center.y - stopDistance, shatter: geo.size.height))
                .position(x: center.x, y: lineY(center: center.y, stopDistance: stopDistance, full: geo.size.height, isTop: false))

            // Left line
            Rectangle()
                .fill(Color.primary.opacity(lineOpacity))
                .frame(width: lineLength(full: center.x - stopDistance, shatter: geo.size.width), height: 1)
                .position(x: lineX(center: center.x, stopDistance: stopDistance, full: geo.size.width, isLeft: true), y: center.y)

            // Right line
            Rectangle()
                .fill(Color.primary.opacity(lineOpacity))
                .frame(width: lineLength(full: center.x - stopDistance, shatter: geo.size.width), height: 1)
                .position(x: lineX(center: center.x, stopDistance: stopDistance, full: geo.size.width, isLeft: false), y: center.y)
        }
        .animation(shattering ? .easeOut(duration: 0.3) : .easeIn(duration: 1.0), value: converging)
        .animation(.easeOut(duration: 0.3), value: shattering)
    }

    private var lineOpacity: Double {
        shattering ? 0 : (converging ? 0.3 : 0)
    }

    private func lineLength(full: CGFloat, shatter: CGFloat) -> CGFloat {
        shattering ? shatter : (converging ? full : 0)
    }

    private func lineY(center: CGFloat, stopDistance: CGFloat, full: CGFloat, isTop: Bool) -> CGFloat {
        if shattering { return isTop ? 0 : full }
        if converging { return isTop ? (stopDistance / 2) : (center + stopDistance + (center - stopDistance) / 2) }
        return isTop ? 0 : full
    }

    private func lineX(center: CGFloat, stopDistance: CGFloat, full: CGFloat, isLeft: Bool) -> CGFloat {
        if shattering { return isLeft ? 0 : full }
        if converging { return isLeft ? (stopDistance / 2) : (center + stopDistance + (center - stopDistance) / 2) }
        return isLeft ? 0 : full
    }
}

// MARK: - Radial Burst Lines

private struct RadialBurstLines: View {
    @State private var expanded = false

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let diagonal = sqrt(geo.size.width * geo.size.width + geo.size.height * geo.size.height)

            ForEach(0..<12, id: \.self) { i in
                Rectangle()
                    .fill(Color.primary.opacity(expanded ? 0 : 0.4))
                    .frame(width: expanded ? diagonal : 0, height: 1)
                    .rotationEffect(.degrees(Double(i) * 30))
                    .position(x: center.x, y: center.y)
                    .animation(
                        .easeOut(duration: 0.4).delay(Double(i) * 0.01),
                        value: expanded
                    )
            }
        }
        .onAppear {
            expanded = true
        }
    }
}

// MARK: - Flash Modifier

private struct FlashModifier: ViewModifier {
    let active: Bool
    @State private var flashOpacity: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(flashOpacity)
            .onChange(of: active) { _, isActive in
                if isActive {
                    withAnimation(.linear(duration: 0.01)) {
                        flashOpacity = 0.9
                    }
                    withAnimation(.easeOut(duration: 0.15).delay(0.01)) {
                        flashOpacity = 0
                    }
                }
            }
    }
}
