import SwiftUI

/// Twenty horizontal lines that dissolve in a center-outward wave pattern
struct LineCurtainView: View {
    let dissolving: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let lineCount = 20

    var body: some View {
        if !reduceMotion {
            GeometryReader { geo in
                let spacing = geo.size.height / Double(lineCount)

                ForEach(0..<lineCount, id: \.self) { index in
                    let distanceFromCenter = abs(Double(index) - Double(lineCount - 1) / 2.0)
                    let delay = distanceFromCenter * 0.05

                    Rectangle()
                        .fill(Design.fg)
                        .frame(width: geo.size.width, height: dissolving ? 0 : 3)
                        .opacity(dissolving ? 0 : 1)
                        .position(x: geo.size.width / 2, y: spacing * Double(index) + spacing / 2)
                        .animation(.easeOut(duration: 0.8).delay(delay), value: dissolving)
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
