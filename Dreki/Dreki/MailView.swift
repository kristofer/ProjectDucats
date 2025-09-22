import SwiftUI
#if os(macOS)
import AppKit
#else
import MessageUI
import UIKit
#endif

#if os(macOS)
struct MailView: View {
    var subject: String
    var contents: String
    var recipients: [String]?
    var attachmentData: Data?
    var attachmentMimeType: String
    var attachmentFileName: String

    func openMail() {
        var urlString = "mailto:"
        if let recipients = recipients, !recipients.isEmpty {
            urlString += recipients.joined(separator: ",")
        }
        var queryItems: [String] = []
        if !subject.isEmpty {
            queryItems.append("subject=" + subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        if !contents.isEmpty {
            queryItems.append("body=" + contents.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        if !queryItems.isEmpty {
            urlString += "?" + queryItems.joined(separator: "&")
        }
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    var body: some View {
        Button("Send Email") {
            openMail()
        }
    }
}
#else
struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    var subject: String
    var body: String
    var recipients: [String]?
    var attachmentData: Data?
    var attachmentMimeType: String
    var attachmentFileName: String

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        init(_ parent: MailView) { self.parent = parent }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.presentation.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        if let recipients = recipients {
            vc.setToRecipients(recipients)
        }
        if let data = attachmentData {
            vc.addAttachmentData(data, mimeType: attachmentMimeType, fileName: attachmentFileName)
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
#endif
