import Foundation

enum CapsuleExporter {
    static func export(capsule: Capsule, senderName: String) -> URL? {
        let package = CapsulePackage(from: capsule, senderName: senderName)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(package) else { return nil }

        let fileName = "\(capsule.title.isEmpty ? capsule.type.label : capsule.title).capsule"
        let tempURL = FileManager.default.temporaryDirectory.appending(path: fileName)

        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            return nil
        }
    }
}
