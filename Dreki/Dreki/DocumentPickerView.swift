import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
struct DocumentPickerView: View {
    let exportFile: ExportFile
    let completion: (() -> Void)?

    var body: some View {
        Button("Export Document") {
            showPanel()
        }
    }

    func showPanel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                // You can copy the file to the selected directory here
                completion?()
            } else {
                completion?()
            }
        }
    }
}
#else
struct DocumentPickerView: UIViewControllerRepresentable {
    let exportFile: ExportFile
    let completion: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        print("Exporting file is: \(exportFile.url)")
        let picker = UIDocumentPickerViewController(forExporting: [exportFile.url], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (() -> Void)?
        init(completion: (() -> Void)?) {
            self.completion = completion
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            completion?()
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            completion?()
        }
    }
}
#endif
