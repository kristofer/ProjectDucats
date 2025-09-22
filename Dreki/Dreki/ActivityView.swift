import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
struct ActivityView: View {
    let activityItems: [Any]
    let completion: (() -> Void)?

    var body: some View {
        Button("Share") {
            share()
        }
    }

    func share() {
        guard let firstItem = activityItems.first as? NSURL else { return }
        let picker = NSSharingServicePicker(items: [firstItem])
        if let window = NSApplication.shared.windows.first {
            picker.show(relativeTo: .zero, of: window.contentView!, preferredEdge: .minY)
        }
        completion?()
    }
}
#else
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let completion: (() -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = { _, _, _, _ in
            completion?()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
