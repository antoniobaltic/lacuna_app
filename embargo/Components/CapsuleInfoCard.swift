import SwiftUI

struct CapsuleInfoCard: View {
    let capsule: Capsule

    var body: some View {
        VStack(spacing: 14) {
            InfoRow(icon: "calendar.badge.plus", label: "sealed", value: Design.formatDateTime(capsule.createdAt))

            Divider()
                .overlay(Design.divider)

            InfoRow(icon: "calendar", label: "opens", value: Design.formatDateTime(capsule.unlocksAt))

            Divider()
                .overlay(Design.divider)

            InfoRow(icon: capsule.type.iconName, label: "contains", value: capsule.type.label)
        }
        .padding(20)
        .background(Design.surface)
        .clipShape(.rect(cornerRadius: Design.radiusLarge))
        .overlay {
            RoundedRectangle(cornerRadius: Design.radiusLarge)
                .strokeBorder(Design.border, lineWidth: 1)
        }
    }
}
