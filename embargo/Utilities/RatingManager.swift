import StoreKit

enum RatingManager {
    private static let installDateKey = "ratingInstallDate"
    private static let sessionCountKey = "ratingSessionCount"
    private static let lastPromptDateKey = "ratingLastPromptDate"
    private static let lastPromptVersionKey = "ratingLastPromptVersion"

    // MARK: - Session tracking

    /// Call once per app foreground (in LacunaApp.onAppear or scenePhase change)
    static func recordSession() {
        let defaults = UserDefaults.standard

        // Set install date on first ever launch
        if defaults.object(forKey: installDateKey) == nil {
            defaults.set(Date.now, forKey: installDateKey)
        }

        let count = defaults.integer(forKey: sessionCountKey)
        defaults.set(count + 1, forKey: sessionCountKey)
    }

    static var sessionCount: Int {
        UserDefaults.standard.integer(forKey: sessionCountKey)
    }

    static var installDate: Date? {
        UserDefaults.standard.object(forKey: installDateKey) as? Date
    }

    // MARK: - Request review (aggressive but Apple-throttled)

    /// Call at every emotional high point. Apple throttles to 3/year — no user annoyance risk.
    /// We add a 30-day cooldown and one-per-version gate as minimal hygiene.
    @MainActor
    static func requestIfEligible() {
        guard isEligible() else { return }
        // AppStore.requestReview is the modern replacement for SKStoreReviewController
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: windowScene)
        }
        recordPrompt()
    }

    // MARK: - Eligibility

    private static func isEligible() -> Bool {
        let defaults = UserDefaults.standard

        // Must have installed ≥3 days ago
        if let install = installDate {
            let daysSinceInstall = Date.now.timeIntervalSince(install) / 86400
            if daysSinceInstall < 3 { return false }
        }

        // Must have ≥2 sessions
        if sessionCount < 2 { return false }

        // Must be ≥30 days since last prompt
        if let lastPrompt = defaults.object(forKey: lastPromptDateKey) as? Date {
            let daysSincePrompt = Date.now.timeIntervalSince(lastPrompt) / 86400
            if daysSincePrompt < 30 { return false }
        }

        // Must not have prompted on this version
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        let lastVersion = defaults.string(forKey: lastPromptVersionKey) ?? ""
        if lastVersion == currentVersion { return false }

        return true
    }

    private static func recordPrompt() {
        let defaults = UserDefaults.standard
        defaults.set(Date.now, forKey: lastPromptDateKey)
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        defaults.set(currentVersion, forKey: lastPromptVersionKey)
    }
}
