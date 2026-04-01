import SwiftUI

/// Manages a separate UIWindow that sits above all sheets/modals
/// so in-app toast notifications are always visible.
final class ToastWindow {
    static let shared = ToastWindow()

    private var window: UIWindow?
    private var hostingController: UIHostingController<AnyView>?

    private init() {}

    func show<Content: View>(in windowScene: UIWindowScene, @ViewBuilder content: () -> Content) {
        let view = content()
        let hosting = UIHostingController(rootView: AnyView(view))
        hosting.view.backgroundColor = .clear

        let window = PassthroughWindow(windowScene: windowScene)
        window.rootViewController = hosting
        window.isHidden = false
        window.windowLevel = .alert + 1

        self.window = window
        self.hostingController = hosting
    }

    func update<Content: View>(@ViewBuilder content: () -> Content) {
        hostingController?.rootView = AnyView(content())
    }

    func hide() {
        window?.isHidden = true
        window = nil
        hostingController = nil
    }
}

/// A UIWindow that passes through touches to views below
/// when the touch doesn't hit any opaque subview.
private final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let result = super.hitTest(point, with: event) else { return nil }
        // If the hit view is the root hosting view (transparent background), pass through
        if result === rootViewController?.view {
            return nil
        }
        return result
    }
}
