import Foundation
import SwiftData

/// Snapshot of the original shipped schema — DO NOT MODIFY
nonisolated enum CapsuleSchemaV1: VersionedSchema {
    nonisolated(unsafe) static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Capsule.self]
    }

    @Model
    final class Capsule {
        #Index<Capsule>([\.createdAt], [\.unlocksAt])

        var id: UUID
        var title: String
        var type: CapsuleType
        var textContent: String?
        @Attribute(.externalStorage) var imageData: Data?
        var audioFileName: String?
        var createdAt: Date
        var unlocksAt: Date
        var openedAt: Date?
        var senderName: String?
        var isSent: Bool

        init(
            title: String = "",
            type: CapsuleType = .text,
            textContent: String? = nil,
            imageData: Data? = nil,
            audioFileName: String? = nil,
            unlocksAt: Date = .now,
            senderName: String? = nil,
            isSent: Bool = false
        ) {
            self.id = UUID()
            self.title = title
            self.type = type
            self.textContent = textContent
            self.imageData = imageData
            self.audioFileName = audioFileName
            self.createdAt = .now
            self.unlocksAt = unlocksAt
            self.openedAt = nil
            self.senderName = senderName
            self.isSent = isSent
        }
    }
}
