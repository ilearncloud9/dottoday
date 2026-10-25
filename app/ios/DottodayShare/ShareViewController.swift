import Social
import UIKit
import UniformTypeIdentifiers

/// The share sheet's "Dottoday" (docs/11 B6, docs/09 M12.4): text or a
/// link shared from any app becomes an Inbox task. The system compose
/// sheet lets the person edit the text first; Post appends one `add_task`
/// entry marked `shared` to the App Group queue (`DotStore`) — the app
/// makes the title and keeps the source as the note when it drains
/// (`lib/domain/quick_add/shared_capture.dart`). Nothing leaves the device
/// and nothing here talks to the network (CLAUDE.md §11 surface rule).
final class ShareViewController: SLComposeServiceViewController {
  override func isContentValid() -> Bool { true }

  override func didSelectPost() {
    let item = extensionContext?.inputItems.first as? NSExtensionItem
    let subject = item?.attributedTitle?.string
    let typed = contentText ?? ""
    sharedLink(in: item) { link in
      ShareQueue.append(text: typed, link: link?.absoluteString, subject: subject)
      self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
  }

  override func configurationItems() -> [Any]! { [] }

  /// The first URL attachment, if any (Safari, News, most apps).
  private func sharedLink(in item: NSExtensionItem?, done: @escaping (URL?) -> Void) {
    let provider = item?.attachments?.first {
      $0.hasItemConformingToTypeIdentifier(UTType.url.identifier)
    }
    guard let provider else { return done(nil) }
    provider.loadItem(forTypeIdentifier: UTType.url.identifier) { value, _ in
      DispatchQueue.main.async { done(value as? URL) }
    }
  }
}
