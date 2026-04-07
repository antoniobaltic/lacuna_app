import UIKit
import LinkPresentation

nonisolated final class CapsuleShareItem: NSObject, UIActivityItemSource {
    private let fileURL: URL
    private let unlockDate: Date

    init(fileURL: URL, unlockDate: Date) {
        self.fileURL = fileURL
        self.unlockDate = unlockDate
        super.init()
    }

    nonisolated func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        fileURL
    }

    nonisolated func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        fileURL
    }

    nonisolated func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        "lacuna time capsule"
    }

    nonisolated func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = "lacuna time capsule"
        metadata.originalURL = fileURL
        metadata.url = fileURL

        if let icon = UIImage(named: "ShareIcon") {
            metadata.iconProvider = NSItemProvider(object: icon)
        }

        return metadata
    }
}
