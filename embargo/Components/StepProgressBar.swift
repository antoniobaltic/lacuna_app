import SwiftUI

struct StepProgressBar: View {
    let currentStep: CreateStep

    var body: some View {
        HStack(spacing: 8) {
            ForEach(CreateStep.allCases, id: \.self) { step in
                SwiftUI.Capsule()
                    .fill(step.rawValue <= currentStep.rawValue ? Color.primary : Color.primary.opacity(0.18))
                    .frame(height: 2)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
}
