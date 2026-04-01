import UIKit
import LinkPresentation

final class CapsuleShareItem: NSObject, UIActivityItemSource {
    private let fileURL: URL
    private let unlockDate: Date

    init(fileURL: URL, unlockDate: Date) {
        self.fileURL = fileURL
        self.unlockDate = unlockDate
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        fileURL
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        fileURL
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        "lacuna time capsule"
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = "lacuna time capsule"

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        metadata.originalURL = fileURL
        metadata.url = fileURL

        // App icon as preview
        if let iconImage = UIImage(named: "AppIcon") {
            metadata.iconProvider = NSItemProvider(object: iconImage)
        }

        return metadata
    }
}
