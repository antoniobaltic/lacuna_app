import SwiftUI

struct InAppToastView: View {
    let notification: InAppNotification
    let onDismiss: () -> Void

    @State private var toastTrigger = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: notification.customTitle != nil ? "lock.fill" : "lock.open.fill")
                .font(.body.weight(.regular))

            Text(notification.customTitle ?? "a time capsule is ready")
                .font(.subheadline)
                .tracking(Design.trackingNormal)
        }
        .foregroundStyle(Design.bg)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(Design.fg)
        .sensoryFeedback(.impact(weight: .medium), trigger: toastTrigger)
        .onAppear { toastTrigger.toggle() }
        .task {
            try? await Task.sleep(for: .seconds(6))
            onDismiss()
        }
    }
}

#Preview("toast — light") {
    VStack {
        InAppToastView(
            notification: InAppNotification(capsuleID: "preview"),
            onDismiss: {}
        )
        .padding(.top, 4)
        Spacer()
    }
}

#Preview("toast — dark") {
    VStack {
        InAppToastView(
            notification: InAppNotification(capsuleID: "preview"),
            onDismiss: {}
        )
        .padding(.top, 4)
        Spacer()
    }
    .preferredColorScheme(.dark)
}

#Preview("toast — custom title") {
    VStack {
        InAppToastView(
            notification: InAppNotification(capsuleID: "preview", customTitle: "time capsule received from sarah"),
            onDismiss: {}
        )
        .padding(.top, 4)
        Spacer()
    }
}
