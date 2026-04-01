import SwiftUI

enum AppearanceResolver {
    /// Resolves an AppearanceMode to a concrete ColorScheme.
    /// Never returns nil — for "automatic", reads the true device setting
    /// via UITraitCollection.current (bypasses SwiftUI's overridden environment).
    static func resolve(mode: AppearanceMode) -> ColorScheme {
        switch mode {
        case .light: .light
        case .dark: .dark
        case .automatic:
            UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
        }
    }

    /// Convenience: resolve from raw AppStorage string value.
    static func resolve(rawValue: String) -> ColorScheme {
        resolve(mode: AppearanceMode(rawValue: rawValue) ?? .automatic)
    }
}
