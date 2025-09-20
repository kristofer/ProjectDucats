import SwiftUI
import UIKit

struct DocumentPickerView: UIViewControllerRepresentable {
    //let url: URL
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
