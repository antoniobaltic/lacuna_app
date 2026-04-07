import Foundation
import SwiftData

enum CapsuleImporter {
    static func importCapsule(from url: URL, modelContext: ModelContext) -> Capsule? {
        guard url.pathExtension == "capsule" else { return nil }

        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing { url.stopAccessingSecurityScopedResource() }
        }

        guard let data = try? Data(contentsOf: url) else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let package = try? decoder.decode(CapsulePackage.self, from: data) else { return nil }
        guard let capsuleType = CapsuleType(rawValue: package.type) else { return nil }

        // Deduplication: check if a received capsule with same sender, unlock date, and creation date exists
        let senderName = package.senderName
        let title = package.title
        let unlocksAt = package.unlocksAt
        let createdAt = package.createdAt

        let descriptor = FetchDescriptor<Capsule>(predicate: #Predicate<Capsule> {
            $0.senderName == senderName &&
            $0.unlocksAt == unlocksAt &&
            $0.createdAt == createdAt
        })

        if let existingCount = try? modelContext.fetchCount(descriptor), existingCount > 0 {
            return nil // Already imported
        }

        // Handle audio data — store inline for iCloud sync
        var audioData: Data?
        if let audioBase64 = package.audioData {
            audioData = Data(base64Encoded: audioBase64)
        }

        // Handle image data
        var imageData: Data?
        if let imageBase64 = package.imageData {
            imageData = Data(base64Encoded: imageBase64)
        }

        let capsule = Capsule(
            title: title,
            type: capsuleType,
            textContent: package.textContent,
            imageData: imageData,
            audioData: audioData,
            unlocksAt: unlocksAt,
            senderName: senderName
        )

        modelContext.insert(capsule)

        // Schedule notification (silent fail if permissions denied)
        NotificationManager.scheduleCapsuleNotification(
            id: capsule.id.uuidString,
            title: title,
            unlockDate: unlocksAt
        )

        return capsule
    }
}
