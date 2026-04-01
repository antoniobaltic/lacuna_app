import Foundation

enum CapsuleType: String, Codable, CaseIterable {
    case text
    case photo
    case voice

    var iconName: String {
        switch self {
        case .text: "doc.text.fill"
        case .photo: "photo.fill"
        case .voice: "waveform"
        }
    }

    var label: String {
        switch self {
        case .text: "text"
        case .photo: "photo"
        case .voice: "voice"
        }
    }
}
