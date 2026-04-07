import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(StoreManager.self) private var storeManager
    @Query(sort: \Capsule.createdAt, order: .reverse) private var allCapsules: [Capsule]
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.automatic.rawValue
    @State private var showCreateSheet = false
    @State private var showSettings = false
    @State private var showArchive = false
    @State private var capsuleToDelete: Capsule?
    @State private var createTrigger = false
    @State private var settingsTrigger = false
    @State private var archiveTrigger = false
    @State private var navigationPath = NavigationPath()
    @State private var rowTapTrigger = false
    @State private var showAllSent = false
    @State private var appeared = false
    @AppStorage("pendingFirstCapsule") private var pendingFirstCapsule = false

    // MARK: - Filtered sections (active capsules only)

    private func readyCapsules(now: Date) -> [Capsule] {
        allCapsules
            .filter { $0.isLocal && $0.isSealed && now >= $0.unlocksAt }
            .sorted { $0.unlocksAt < $1.unlocksAt }
    }

    private func receivedCapsules(now: Date) -> [Capsule] {
        allCapsules
            .filter { $0.isReceived && $0.isSealed }
            .sorted { $0.unlocksAt < $1.unlocksAt }
    }

    private func sealedCapsules(now: Date) -> [Capsule] {
        allCapsules
            .filter { $0.isLocal && $0.isSealed && now < $0.unlocksAt }
            .sorted { $0.unlocksAt < $1.unlocksAt }
    }

    private var sentCapsules: [Capsule] {
        allCapsules
            .filter { $0.isSent && $0.isSealed }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// Are there any active (non-opened) capsules to show?
    private var hasActiveCapsules: Bool {
        allCapsules.contains { $0.isSealed || $0.isSent }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                Text(storeManager.isPro ? " lacuna +" : " lacuna")
                    .font(.title3.weight(.medium))
                    .kerning(Design.trackingWide)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                if !hasActiveCapsules {
                    if pendingFirstCapsule {
                        // Hide empty state during onboarding→create transition
                        Design.bg.ignoresSafeArea()
                    } else {
                        EmptyStateView(onIconTap: { showCreateSheet = true })
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        let now = context.date
                        let ready = readyCapsules(now: now)
                        let received = receivedCapsules(now: now)
                        let sealed = sealedCapsules(now: now)
                        let sent = sentCapsules

                        List {
                            // 1. Ready — most urgent (no header, tagged inline)
                            if !ready.isEmpty {
                                capsuleRows(ready)
                            }

                            // 2. Received — from friends (sealed only)
                            if !received.isEmpty {
                                sectionHeader("received", isFirst: ready.isEmpty)
                                capsuleRows(received)
                            }

                            // 3. Sealed — your own, still waiting
                            if !sealed.isEmpty {
                                sectionHeader("sealed", isFirst: ready.isEmpty && received.isEmpty)
                                capsuleRows(sealed)
                            }

                            // 4. Sent — collapsed to 3
                            if !sent.isEmpty {
                                sectionHeader("sent", isFirst: ready.isEmpty && received.isEmpty && sealed.isEmpty)

                                let displayed = showAllSent ? sent : Array(sent.prefix(3))
                                capsuleRows(displayed, showSentLabel: false)

                                if sent.count > 3 {
                                    Button {
                                        withAnimation(Design.springSnappy) { showAllSent.toggle() }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Text(showAllSent ? "show less" : "show all (\(sent.count))")
                                                .font(.caption)
                                                .tracking(Design.trackingNormal)
                                            Image(systemName: showAllSent ? "chevron.up" : "chevron.down")
                                                .font(.system(size: 8, weight: .medium))
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .contentMargins(.bottom, 100, for: .scrollContent)
                    .mask(
                        VStack(spacing: 0) {
                            Color.black
                            LinearGradient(
                                colors: [.black, .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 125)
                        }
                    )
                }
            }
            .background(Design.bg.ignoresSafeArea())
            .onAppear {
                appeared = true
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Capsule.self) { capsule in
                if capsule.isOpened {
                    OpenedCapsuleView(capsule: capsule)
                } else {
                    SealedCapsuleView(capsule: capsule)
                }
            }
            .onChange(of: navigationPath) {
                rowTapTrigger.toggle()
            }
            .sensoryFeedback(.impact(weight: .light), trigger: rowTapTrigger)
            .overlay(alignment: .bottom) {
                HStack(alignment: .bottom, spacing: 16) {
                    Spacer()

                    Button {
                        settingsTrigger.toggle()
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Design.bg)
                            .frame(width: 44, height: 44)
                            .background(Design.fg)
                            .clipShape(.circle)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: settingsTrigger)

                    Button {
                        archiveTrigger.toggle()
                        showArchive = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Design.bg)
                            .frame(width: 44, height: 44)
                            .background(Design.fg)
                            .clipShape(.circle)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: archiveTrigger)

                    Button {
                        createTrigger.toggle()
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(Design.bg)
                            .frame(width: 52, height: 52)
                            .background(Design.fg)
                            .clipShape(.circle)
                            .overlay {
                                AddButtonPulse()
                            }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 32)
                .sensoryFeedback(.impact(weight: .medium), trigger: createTrigger)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environment(notificationManager)
                    .environment(storeManager)
                    .preferredColorScheme(AppearanceResolver.resolve(rawValue: appearanceMode))
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateCapsuleView()
                    .environment(notificationManager)
                    .environment(storeManager)
                    .preferredColorScheme(AppearanceResolver.resolve(rawValue: appearanceMode))
            }
            .sheet(isPresented: $showArchive) {
                ArchiveView()
                    .environment(notificationManager)
                    .preferredColorScheme(AppearanceResolver.resolve(rawValue: appearanceMode))
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
                        deleteCapsule(capsule)
                    }
                }
            } message: {
                Text("this moment will be lost in time. like tears in the rain. there is no undoing this.")
            }
            .sensoryFeedback(.warning, trigger: capsuleToDelete)
            .onChange(of: pendingFirstCapsule) { _, pending in
                if pending {
                    Task { @MainActor in
                        // Wait for fullScreenCover dismiss animation to complete
                        try? await Task.sleep(for: .milliseconds(350))
                        pendingFirstCapsule = false
                        showCreateSheet = true
                    }
                }
            }
            .onChange(of: notificationManager.pendingCapsuleID) { _, capsuleID in
                guard let capsuleID else { return }
                guard let capsule = allCapsules.first(where: { $0.id.uuidString == capsuleID }) else {
                    notificationManager.pendingCapsuleID = nil
                    return
                }

                showSettings = false
                showCreateSheet = false
                showArchive = false

                navigationPath = NavigationPath()

                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(800))
                    navigationPath.append(capsule)
                    notificationManager.pendingCapsuleID = nil
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .sealOneBack)) { _ in
                // Delay to let the reveal dismiss complete
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(600))
                    showCreateSheet = true
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, isFirst: Bool) -> some View {
        Text(title)
            .font(.caption)
            .tracking(Design.trackingWide)
            .foregroundStyle(.primary.opacity(0.5))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: isFirst ? 12 : 24, leading: 20, bottom: 6, trailing: 20))
    }

    private func capsuleRows(_ capsules: [Capsule], showSentLabel: Bool = true) -> some View {
        ForEach(capsules.enumerated(), id: \.element.id) { index, capsule in
            NavigationLink(value: capsule) {
                CapsuleRowView(capsule: capsule, showSentLabel: showSentLabel)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.05), value: appeared)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button("delete", systemImage: "trash", role: .destructive) {
                    capsuleToDelete = capsule
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    private func deleteCapsule(_ capsule: Capsule) {
        NotificationManager.cancelCapsuleNotification(id: capsule.id.uuidString)
        modelContext.delete(capsule)
        capsuleToDelete = nil
    }
}

