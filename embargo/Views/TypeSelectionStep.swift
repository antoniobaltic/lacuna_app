import SwiftUI

struct TypeSelectionStep: View {
    @Environment(StoreManager.self) private var storeManager
    @Binding var selectedType: CapsuleType?
    @Binding var typeTrigger: Bool
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("what would you like\nto seal?")
                .font(.title2.weight(.light))
                .tracking(Design.trackingNormal)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                ForEach(Array(CapsuleType.allCases.enumerated()), id: \.element) { index, type in
                    Button {
                        typeTrigger.toggle()
                        withAnimation(Design.springSnappy) {
                            selectedType = type
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: type.iconName)
                                .font(.body.weight(.light))
                                .frame(width: 24)
                            Text(type.label.lowercased())
                                .font(.body)
                                .tracking(Design.trackingNormal)
                            Spacer()
                            Circle()
                                .strokeBorder(selectedType == type ? Color.primary : Color.primary.opacity(0.25), lineWidth: selectedType == type ? 6 : 1)
                                .frame(width: 22, height: 22)
                                .animation(Design.springSnappy, value: selectedType)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(Design.surface)
                        .clipShape(.rect(cornerRadius: Design.radiusMedium))
                    }
                    .buttonStyle(.plain)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08), value: appeared)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}
