import Foundation

enum AppearanceMode: String, CaseIterable {
    case automatic
    case light
    case dark

    var label: String {
        switch self {
        case .automatic: "automatic"
        case .light: "light"
        case .dark: "dark"
        }
    }

    var iconName: String {
        switch self {
        case .automatic: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }
}
