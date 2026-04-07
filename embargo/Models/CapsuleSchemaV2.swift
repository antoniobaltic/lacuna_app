import Foundation
import SwiftData

/// V2: Adds audioData for iCloud sync, defaults for CloudKit compliance
nonisolated enum CapsuleSchemaV2: VersionedSchema {
    nonisolated(unsafe) static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Capsule.self]
    }

    @Model
    final class Capsule {
        #Index<Capsule>([\.createdAt], [\.unlocksAt])

        var id: UUID = UUID()
        var title: String = ""
        var type: CapsuleType = CapsuleType.text
        var textContent: String?
        @Attribute(.externalStorage) var imageData: Data?
        var audioFileName: String?  // Retained for backward compat (can't remove with CloudKit)
        @Attribute(.externalStorage) var audioData: Data?  // NEW: synced audio data
        var createdAt: Date = Date.now
        var unlocksAt: Date = Date.now
        var openedAt: Date?
        var senderName: String?
        var isSent: Bool = false

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
            self.createdAt = Date.now
            self.unlocksAt = unlocksAt
            self.openedAt = nil
            self.senderName = senderName
            self.isSent = isSent
        }
    }
}
