import Flutter
import UIKit

/// The app's root Flutter view controller (Main.storyboard). It says when
/// a disappear has really finished. The iPad's native tabs replace the
/// window's root (NativeIPadTabs), and UIKit ends that disappear a moment
/// later; telling Flutter "appeared" before then leaves UIKit's own end
/// call unbalanced.
final class DotFlutterViewController: FlutterViewController {
  private var disappearing = false
  private var afterDisappear: [() -> Void] = []

  /// Runs [action] now, or once a disappear in progress has finished.
  func afterDisappearing(_ action: @escaping () -> Void) {
    if disappearing {
      afterDisappear.append(action)
    } else {
      action()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    disappearing = true
    super.viewWillDisappear(animated)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    disappearing = false
    let pending = afterDisappear
    afterDisappear = []
    // Next turn of the run loop: UIKit's own transition has closed.
    DispatchQueue.main.async { pending.forEach { $0() } }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // A cancelled disappear: the view is back by itself.
    disappearing = false
    afterDisappear = []
  }
}
