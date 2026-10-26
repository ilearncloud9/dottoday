import Cocoa
import Social
import UniformTypeIdentifiers

/// The Mac's Share menu "Dottoday" (docs/11 B6, docs/09 M12.4): as on the
/// iPhone (ios/DottodayShare), the system compose sheet lets the person
/// edit the text, and Post queues one `shared` add_task entry in the App
/// Group (`ShareQueue`, ios/Shared/DotStore.swift). The app makes the Inbox
/// task when it drains. Nothing leaves the device.
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

  /// The first URL attachment, if any (Safari, Notes, most apps).
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
