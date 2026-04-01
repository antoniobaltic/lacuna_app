import SwiftUI
import SwiftData

@main
struct LacunaApp: App {
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.automatic.rawValue
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var notificationManager = NotificationManager.shared
    @State private var storeManager = StoreManager.shared
    @State private var showOnboarding = false
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Capsule.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        // Configure RevenueCat — must happen once, before any purchase calls
        StoreManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .overlay { FloatingParticlesView().ignoresSafeArea() }
                .environment(notificationManager)
                .environment(storeManager)
                .preferredColorScheme(AppearanceResolver.resolve(rawValue: appearanceMode))
                .onAppear {
                    RatingManager.recordSession()

                    if !hasCompletedOnboarding {
                        showOnboarding = true
                    } else {
                        notificationManager.requestPermission()

                        // Trigger 5: 5th app launch
                        if RatingManager.sessionCount == 5 {
                            // Small delay so the UI settles first
                            Task { @MainActor in
                                try? await Task.sleep(for: .seconds(2))
                                RatingManager.requestIfEligible()
                            }
                        }
                    }
                }
                .task {
                    await storeManager.loadProducts()
                    await storeManager.checkEntitlement()
                    storeManager.listenForTransactions()
                }
                .onOpenURL { url in
                    handleIncomingFile(url: url)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIScene.didActivateNotification)) { notification in
                    guard let scene = notification.object as? UIWindowScene else { return }
                    setupToastWindow(in: scene)
                }
                .onChange(of: notificationManager.inAppNotification) { _, notification in
                    updateToastContent(notification: notification)
                }
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(onComplete: {
                        showOnboarding = false
                    })
                    .environment(notificationManager)
                    .environment(storeManager)
                    .preferredColorScheme(AppearanceResolver.resolve(rawValue: appearanceMode))
                }
        }
        .modelContainer(container)
    }

    private func handleIncomingFile(url: URL) {
        let context = container.mainContext
        if let capsule = CapsuleImporter.importCapsule(from: url, modelContext: context) {
            let senderName = capsule.senderName ?? "someone"
            let notification = InAppNotification(
                capsuleID: capsule.id.uuidString,
                customTitle: "time capsule received from \(senderName)"
            )
            withAnimation(Design.springSnappy) {
                notificationManager.inAppNotification = notification
            }

            // Trigger 4: After importing a received capsule
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(3))
                RatingManager.requestIfEligible()
            }
        }
    }

    private func setupToastWindow(in scene: UIWindowScene) {
        ToastWindow.shared.show(in: scene) {
            ToastOverlayView(notificationManager: notificationManager)
                .preferredColorScheme(AppearanceResolver.resolve(rawValue: appearanceMode))
        }
    }

    private func updateToastContent(notification: InAppNotification?) {
        ToastWindow.shared.update {
            ToastOverlayView(notificationManager: notificationManager)
                .preferredColorScheme(AppearanceResolver.resolve(rawValue: appearanceMode))
        }
    }
}

/// Thin wrapper view that lives in the toast UIWindow
private struct ToastOverlayView: View {
    @Bindable var notificationManager: NotificationManager

    var body: some View {
        VStack {
            if let notification = notificationManager.inAppNotification {
                InAppToastView(
                    notification: notification,
                    onDismiss: {
                        withAnimation(Design.springSnappy) {
                            notificationManager.inAppNotification = nil
                        }
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 4)
            }
            Spacer()
        }
        .animation(Design.springSnappy, value: notificationManager.inAppNotification)
    }
}
