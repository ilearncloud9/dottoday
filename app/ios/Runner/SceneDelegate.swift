import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  // A link that launches the app arrives here. The engine forwards it once
  // the first frame is up, but on a cold start that can beat the router
  // ("Failed to handle route information"), so it is also queued for Dart
  // to take when it starts listening (docs/09 M5.0). Links to a running app
  // go through the engine as usual.
  override func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    for context in connectionOptions.urlContexts where context.url.scheme == "dottoday" {
      DeepLinkBridge.shared.queue(context.url)
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }
}
