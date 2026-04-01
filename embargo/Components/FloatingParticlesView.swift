import SwiftUI

struct FloatingParticlesView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var placements: [ShapePlacement] = []
    @State private var generated = false

    private static let shapeCount = 20
    private static let minDistance: Double = 0.18 // as fraction of screen diagonal

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(placements) { placement in
                    GeoShapeView(placement: placement)
                }

                CometField(size: geo.size)
            }
            .onAppear {
                guard !generated else { return }
                generated = true
                placements = Self.generatePlacements(count: Self.shapeCount, size: geo.size)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .opacity(reduceMotion ? 0 : 1)
    }

    private static func generatePlacements(count: Int, size: CGSize) -> [ShapePlacement] {
        let diagonal = sqrt(size.width * size.width + size.height * size.height)
        let minDist = minDistance * diagonal
        var placed: [(x: Double, y: Double)] = []
        var result: [ShapePlacement] = []

        for i in 0..<count {
            let seed = i + Int.random(in: 0..<10000)
            let rv = RandomValues(seed: seed)

            // Try to find a position that doesn't overlap
            var foundSpot = false
            var finalX = 0.0
            var finalY = 0.0

            for _ in 0..<15 {
                let candidateX = 0.08 + Double.random(in: 0..<0.84)
                let candidateY = 0.05 + Double.random(in: 0..<0.9)
                let px = candidateX * size.width
                let py = candidateY * size.height

                let tooClose = placed.contains { existing in
                    let dx = existing.x - px
                    let dy = existing.y - py
                    return sqrt(dx * dx + dy * dy) < minDist
                }

                if !tooClose {
                    finalX = px
                    finalY = py
                    foundSpot = true
                    break
                }
            }

            // Skip this shape entirely if no clear spot found
            guard foundSpot else { continue }

            placed.append((finalX, finalY))

            result.append(ShapePlacement(
                id: i,
                x: finalX,
                y: finalY,
                values: rv
            ))
        }

        return result
    }
}

private struct ShapePlacement: Identifiable {
    let id: Int
    let x: Double
    let y: Double
    let values: RandomValues
}

// MARK: - Comet Field

private struct CometField: View {
    let size: CGSize
    @State private var comets: [CometData] = []

    var body: some View {
        ZStack {
            ForEach(comets) { comet in
                CometStreak(comet: comet)
            }
        }
        .onAppear {
            spawnLoop(size: size)
        }
    }

    private func spawnLoop(size: CGSize) {
        func scheduleNext() {
            let delay = Double.random(in: 1.5...2.5)
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled else { return }
                spawnComet(size: size)
                scheduleNext()
            }
        }

        // First comet quickly
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(Double.random(in: 0.8...1.5)))
            guard !Task.isCancelled else { return }
            spawnComet(size: size)
            scheduleNext()
        }
    }

    private func spawnComet(size: CGSize) {
        let startY = Double.random(in: -0.1...0.8) * size.height
        let comet = CometData(
            id: UUID(),
            startX: Double.random(in: -0.2...0.3) * size.width,
            startY: startY,
            angle: Double.random(in: 20...55),
            tailLength: Double.random(in: 160...320),
            duration: Double.random(in: 1.0...1.6),
            totalTravel: size.width + 200,
            goesRight: true
        )

        comets.append(comet)

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(comet.duration + 0.3))
            comets.removeAll { $0.id == comet.id }
        }
    }
}

private struct CometData: Identifiable {
    let id: UUID
    let startX: Double
    let startY: Double
    let angle: Double
    let tailLength: Double
    let duration: Double
    let totalTravel: Double
    let goesRight: Bool
}

private struct CometStreak: View {
    let comet: CometData
    @State private var offset: Double = -100
    @Environment(\.colorScheme) private var colorScheme

    private var cometOpacity: Double {
        colorScheme == .dark ? 0.5 : 0.3
    }

    var body: some View {
        let radians = comet.angle * .pi / 180
        let dx = cos(radians)
        let dy = sin(radians)

        SwiftUI.Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        .primary.opacity(0),
                        .primary.opacity(cometOpacity * 0.3),
                        .primary.opacity(cometOpacity * 0.6),
                        .primary.opacity(cometOpacity)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: comet.tailLength, height: 1.5)
            .rotationEffect(.degrees(comet.angle))
            .position(
                x: comet.startX + dx * offset,
                y: comet.startY + dy * offset
            )
            .onAppear {
                withAnimation(.linear(duration: comet.duration)) {
                    offset = comet.totalTravel
                }
            }
    }
}

// MARK: - Geometric Shapes

private struct GeoShapeView: View {
    let placement: ShapePlacement
    @State private var visible = false
    @Environment(\.colorScheme) private var colorScheme

    private var startsInstant: Bool { placement.id % 2 == 0 }
    private var darkModeBoost: Double { colorScheme == .dark ? 2.0 : 1.0 }

    var body: some View {
        let r = placement.values
        let x = placement.x
        let y = placement.y

        Group {
                switch r.kind {
                case 0:
                    // Star
                    Path { p in
                        let points = 6
                        let outerR = r.size / 2
                        let innerR = outerR * 0.4
                        for i in 0..<(points * 2) {
                            let angle = Double(i) * .pi / Double(points)
                            let radius = i.isMultiple(of: 2) ? outerR : innerR
                            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
                            if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
                        }
                        p.closeSubpath()
                    }
                    .stroke(.primary, lineWidth: 1)
                    .rotationEffect(.degrees(90))
                case 1:
                    // Circle
                    Circle()
                        .stroke(.primary, lineWidth: 1)
                        .frame(width: r.size, height: r.size)
                        .offset(x: -r.size / 2, y: -r.size / 2)
                case 2:
                    // Diamond
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: -r.size / 2))
                        p.addLine(to: CGPoint(x: r.size / 2, y: 0))
                        p.addLine(to: CGPoint(x: 0, y: r.size / 2))
                        p.addLine(to: CGPoint(x: -r.size / 2, y: 0))
                        p.closeSubpath()
                    }
                    .stroke(.primary, lineWidth: 1)
                case 3:
                    // Square
                    Rectangle()
                        .stroke(.primary, lineWidth: 1)
                        .frame(width: r.size, height: r.size)
                        .offset(x: -r.size / 2, y: -r.size / 2)
                case 4:
                    // Dot
                    Circle()
                        .fill(Design.fg)
                        .frame(width: r.size * 0.2, height: r.size * 0.2)
                default:
                    // Triangle
                    Path { p in
                        let half = r.size / 2
                        p.move(to: CGPoint(x: 0, y: -half))
                        p.addLine(to: CGPoint(x: half, y: half))
                        p.addLine(to: CGPoint(x: -half, y: half))
                        p.closeSubpath()
                    }
                    .stroke(.primary, lineWidth: 1)
                }
            }
        .opacity(visible ? r.maxOpacity * darkModeBoost : 0)
        .animation(
            .easeInOut(duration: startsInstant ? r.fadeDuration * 0.5 : r.fadeDuration)
            .repeatForever(autoreverses: true)
            .delay(startsInstant ? 0 : r.delay),
            value: visible
        )
        .position(x: x, y: y)
        .onAppear {
            visible = true
        }
    }
}

private struct RandomValues {
    let posX: Double
    let posY: Double
    let size: Double
    let maxOpacity: Double
    let fadeDuration: Double
    let delay: Double
    let kind: Int

    init(seed: Int) {
        // Deterministic pseudo-random from seed
        var h = UInt64(seed &* 2654435761)
        func next() -> Double {
            h = h &* 6364136223846793005 &+ 1442695040888963407
            return Double((h >> 33) & 0x7FFFFFFF) / Double(0x7FFFFFFF)
        }
        posX = 0.08 + next() * 0.84
        posY = 0.05 + next() * 0.9
        size = 14 + next() * 26
        maxOpacity = 0.05 + next() * 0.09
        fadeDuration = 3 + next() * 5
        delay = next() * 1.5
        kind = Int(next() * 6)
    }
}
