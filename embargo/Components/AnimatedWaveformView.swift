import SwiftUI

struct AnimatedWaveformView: View {
    var isPlaying: Bool

    private let barCount = 30
    private let barWidth: Double = 3
    private let barSpacing: Double = 3.5
    private let maxHeight: Double = 64

    @State private var phases: [Double] = []
    @State private var energy: Double = 0.7
    private let idleEnergy: Double = 0.4

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                let totalBarWidth = barWidth + barSpacing
                let totalWidth = Double(barCount) * totalBarWidth - barSpacing
                let startX = (size.width - totalWidth) / 2

                for i in 0..<barCount {
                    let phase = phases.indices.contains(i) ? phases[i] : 0
                    let x = startX + Double(i) * totalBarWidth
                    let height = computeBarHeight(index: i, time: time, phase: phase)
                    let y = (size.height - height) / 2

                    let rect = CGRect(x: x, y: y, width: barWidth, height: max(2, height))
                    let path = Path(roundedRect: rect, cornerRadius: barWidth / 2)
                    context.fill(path, with: .foreground)
                }
            }
            .frame(height: maxHeight)
        }
        .onAppear {
            if phases.isEmpty {
                phases = (0..<barCount).map { _ in Double.random(in: 0...(.pi * 2)) }
            }
            withAnimation(.easeOut(duration: 1.2)) {
                energy = isPlaying ? 1.0 : idleEnergy
            }
        }
        .onChange(of: isPlaying) { _, playing in
            withAnimation(.easeInOut(duration: 1.2)) {
                energy = playing ? 1.0 : idleEnergy
            }
        }
        .accessibilityHidden(true)
    }

    private func computeBarHeight(index: Int, time: Double, phase: Double) -> Double {
        let i = Double(index)
        let center = Double(barCount) / 2.0
        let distFromCenter = abs(i - center) / center // 0 at center, 1 at edges

        // Idle: gentle breathing wave
        let idleSine = sin(time * 0.8 + phase) * 0.12
        let idleBase = 0.2 - distFromCenter * 0.08
        let idleHeight = max(0.08, idleBase + idleSine)

        // Playing: energetic multi-frequency dance
        let wave1 = sin(time * 4.0 + phase) * 0.35
        let wave2 = sin(time * 6.5 + phase * 1.4 + i * 0.3) * 0.2
        let wave3 = sin(time * 2.2 + i * 0.6) * 0.15
        let wave4 = sin(time * 8.0 + phase * 0.7) * 0.1
        let playBase = 0.35 - distFromCenter * 0.1
        let playHeight = max(0.1, playBase + wave1 + wave2 + wave3 + wave4)

        // Blend between idle and playing based on energy
        let blended = idleHeight * (1 - energy) + playHeight * energy
        return blended * maxHeight
    }
}
