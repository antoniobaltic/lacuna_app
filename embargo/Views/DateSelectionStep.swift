import SwiftUI

struct DateSelectionStep: View {
    @Binding var unlockDate: Date
    @State private var selectedQuick: String?
    @State private var quickTrigger = false
    @State private var expectedQuickDate: Date?
    @State private var appeared = false

    private let quickOptions: [(label: String, date: () -> Date)] = [
        ("1d", { Calendar.current.date(byAdding: .day, value: 1, to: .now)! }),
        ("1w", { Calendar.current.date(byAdding: .weekOfYear, value: 1, to: .now)! }),
        ("1m", { Calendar.current.date(byAdding: .month, value: 1, to: .now)! }),
        ("1y", { Calendar.current.date(byAdding: .year, value: 1, to: .now)! }),
        ("5y", { Calendar.current.date(byAdding: .year, value: 5, to: .now)! }),
    ]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("when should it open?")
                .font(.title2.weight(.light))
                .tracking(Design.trackingNormal)

            Text("once sealed, this date cannot be changed.")
                .font(.caption)
                .tracking(Design.trackingNormal)
                .foregroundStyle(.secondary)

            // Quick select chips
            HStack(spacing: 10) {
                ForEach(quickOptions, id: \.label) { option in
                    Button {
                        quickTrigger.toggle()
                        let date = option.date()
                        expectedQuickDate = date
                        selectedQuick = option.label
                        withAnimation(Design.springSnappy) {
                            unlockDate = date
                        }
                    } label: {
                        Text(option.label)
                            .font(.caption.weight(.medium))
                            .tracking(Design.trackingNormal)
                            .foregroundStyle(selectedQuick == option.label ? Design.bg : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(selectedQuick == option.label ? Design.fg : .clear)
                            .overlay {
                                Rectangle()
                                    .strokeBorder(selectedQuick == option.label ? .clear : Design.border, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .sensoryFeedback(.selection, trigger: quickTrigger)

            DatePicker(
                "unlock date",
                selection: $unlockDate,
                in: Date.now.addingTimeInterval(600)...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .tint(.primary)

            Spacer()
        }
        .padding(.horizontal, 24)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) { appeared = true }
        }
        .onChange(of: unlockDate) {
            if let expected = expectedQuickDate {
                let diff = abs(unlockDate.timeIntervalSince(expected))
                if diff > 60 {
                    selectedQuick = nil
                    expectedQuickDate = nil
                }
            }
        }
    }
}
