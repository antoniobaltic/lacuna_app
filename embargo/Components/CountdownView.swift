import SwiftUI

struct CountdownView: View {
    let targetDate: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let interval = targetDate.timeIntervalSince(now)
            let totalSeconds = Int(max(0, interval))
            let isExpired = interval <= 1

            Group {
                if isExpired {
                    Text("ready")
                        .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                        .tracking(Design.trackingButton)
                        .foregroundStyle(.primary)
                } else {
                    let days = totalSeconds / 86400
                    let hours = (totalSeconds % 86400) / 3600
                    let minutes = (totalSeconds % 3600) / 60
                    let seconds = totalSeconds % 60

                    HStack(spacing: 20) {
                        if days > 0 {
                            CountdownUnit(value: days, label: "days")
                        }
                        CountdownUnit(value: hours, label: "hrs")
                        CountdownUnit(value: minutes, label: "min")
                        CountdownUnit(value: seconds, label: "sec")
                    }
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isExpired)
            .transition(.blurReplace)
        }
    }
}
