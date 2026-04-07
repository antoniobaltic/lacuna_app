import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Capsule.createdAt, order: .reverse) private var allCapsules: [Capsule]

    @State private var doneTrigger = false
    @State private var capsuleToDelete: Capsule?

    private var openedCapsules: [Capsule] {
        allCapsules
            .filter { $0.isOpened }
            .sorted { ($0.openedAt ?? .distantPast) > ($1.openedAt ?? .distantPast) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Text("archive")
                        .font(.title3.weight(.medium))
                        .tracking(Design.trackingWide)

                    Spacer()

                    Button {
                        doneTrigger.toggle()
                        dismiss()
                    } label: {
                        Text("done")
                            .font(.body.weight(.medium))
                            .tracking(Design.trackingNormal)
                            .foregroundStyle(Design.bg)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Design.fg)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: doneTrigger)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)

                if openedCapsules.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Spacer()

                        ArchiveIconView()
                            .padding(.bottom, 4)

                        Text("nothing here yet")
                            .font(.title3.weight(.medium))
                            .tracking(Design.trackingNormal)

                        Text("your past moments will appear here\nonce you've opened them.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .tracking(Design.trackingTight)
                            .multilineTextAlignment(.center)

                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                } else {
                    List {
                        ForEach(openedCapsules) { capsule in
                            NavigationLink(value: capsule) {
                                CapsuleRowView(capsule: capsule)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("delete", systemImage: "trash", role: .destructive) {
                                    capsuleToDelete = capsule
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .contentMargins(.bottom, 60, for: .scrollContent)
                }
            }
            .background(Design.bg.ignoresSafeArea())
            .overlay { FloatingParticlesView().ignoresSafeArea() }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Capsule.self) { capsule in
                OpenedCapsuleView(capsule: capsule)
            }
            .confirmationDialog(
                "let it go?",
                isPresented: Binding(
                    get: { capsuleToDelete != nil },
                    set: { if !$0 { capsuleToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("annihilate", role: .destructive) {
                    if let capsule = capsuleToDelete {
                        NotificationManager.cancelCapsuleNotification(id: capsule.id.uuidString)
                        modelContext.delete(capsule)
                        capsuleToDelete = nil
                    }
                }
            } message: {
                Text("this moment will be lost in time. like tears in the rain. there is no undoing this.")
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: capsuleToDelete)
        }
    }
}

// MARK: - Animated Archive Icon

private struct ArchiveIconView: View {
    @State private var pulsing = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(pulsing ? 0 : 0.2), lineWidth: 1)
                .frame(width: 100, height: 100)
                .scaleEffect(pulsing ? 1.3 : 1.0)

            Circle()
                .fill(Design.fg)
                .frame(width: 80, height: 80)

            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(Design.bg)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulsing = true
            }
        }
    }
}
