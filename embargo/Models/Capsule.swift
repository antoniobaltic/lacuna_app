import Foundation
import SwiftData

@Model
final class Capsule {
    #Index<Capsule>([\.createdAt], [\.unlocksAt])

    var id: UUID = UUID()
    var title: String = ""
    var type: CapsuleType = CapsuleType.text
    var textContent: String?
    @Attribute(.externalStorage) var imageData: Data?
    var audioFileName: String?  // Legacy — kept for backward compat, no longer written to
    @Attribute(.externalStorage) var audioData: Data?  // iCloud-synced audio
    var createdAt: Date = Date.now
    var unlocksAt: Date = Date.now
    var openedAt: Date?
    var senderName: String?
    var isSent: Bool = false

    var isUnlockable: Bool {
        Date.now >= unlocksAt && openedAt == nil
    }

    var isSealed: Bool {
        openedAt == nil
    }

    var isOpened: Bool {
        openedAt != nil
    }

    var isReceived: Bool {
        senderName != nil
    }

    var isLocal: Bool {
        !isReceived && !isSent
    }

    /// Returns audio data from either the new audioData property or legacy file reference
    var resolvedAudioData: Data? {
        if let audioData { return audioData }
        // Fallback: try reading from legacy file (safety net for partial migration)
        if let audioFileName {
            let url = URL.documentsDirectory.appending(path: audioFileName)
            return try? Data(contentsOf: url)
        }
        return nil
    }

    var hasAudio: Bool {
        audioData != nil || audioFileName != nil
    }

    init(
        title: String = "",
        type: CapsuleType = CapsuleType.text,
        textContent: String? = nil,
        imageData: Data? = nil,
        audioData: Data? = nil,
        unlocksAt: Date = Date.now,
        senderName: String? = nil,
        isSent: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.type = type
        self.textContent = textContent
        self.imageData = imageData
        self.audioData = audioData
        self.createdAt = .now
        self.unlocksAt = unlocksAt
        self.openedAt = nil
        self.senderName = senderName
        self.isSent = isSent
    }
}
