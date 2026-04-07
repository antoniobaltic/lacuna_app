import Foundation
import SwiftData

nonisolated enum CapsuleMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [CapsuleSchemaV1.self, CapsuleSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    /// Migrate audio files from Documents directory into inline audioData
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: CapsuleSchemaV1.self,
        toVersion: CapsuleSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            let descriptor = FetchDescriptor<CapsuleSchemaV2.Capsule>()
            let capsules = (try? context.fetch(descriptor)) ?? []

            for capsule in capsules {
                guard let fileName = capsule.audioFileName else { continue }
                let url = URL.documentsDirectory.appending(path: fileName)

                if let data = try? Data(contentsOf: url) {
                    capsule.audioData = data
                    // Clean up the file — data is now in SwiftData
                    try? FileManager.default.removeItem(at: url)
                } else {
                    // File was already missing — clear the dangling reference
                    capsule.audioFileName = nil
                }
            }

            try context.save()
        }
    )
}
