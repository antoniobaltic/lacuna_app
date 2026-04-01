import Foundation
import SwiftData

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

    init(
        title: String = "",
        type: CapsuleType,
        textContent: String? = nil,
        imageData: Data? = nil,
        audioFileName: String? = nil,
        unlocksAt: Date,
        senderName: String? = nil,
        isSent: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.type = type
        self.textContent = textContent
        self.imageData = imageData
        self.audioFileName = audioFileName
        self.createdAt = Date.now
        self.unlocksAt = unlocksAt
        self.openedAt = nil
        self.senderName = senderName
        self.isSent = isSent
    }
}
