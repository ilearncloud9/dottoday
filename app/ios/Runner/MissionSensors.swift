import AVFoundation
import CoreMotion
import Flutter
import ImageIO

/// The missions' sensors (docs/15 §8; owner, 2026-11-01: an in-house
/// bridge, no plugin), for lib/data/wake_up/channel_mission_sensors.dart.
/// `dottoday/mission` answers whether a sensor is there and allowed, asks
/// once (from Settings, never while ringing), and says whether CarPlay is
/// on; `dottoday/mission/readings` streams one sensor while the mission
/// screen listens. Raw values only: every threshold is in Dart. Nothing is
/// kept.
///
/// - steps: Core Motion's pedometer, steps since listening began.
/// - light: iPhone has no public light sensor, so the back camera's own
///   brightness measurement (EXIF BrightnessValue, APEX) from each frame's
///   metadata, as a linear value; no pixel is read and no picture kept.
/// - motion: gravity along the long axis and user acceleration, in g.
enum MissionSensors {
  static func register(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/mission", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      let kind = (call.arguments as? [String: Any])?["kind"] as? String ?? ""
      switch call.method {
      case "support": result(support(kind))
      case "request": request(kind) { result($0) }
      case "driving": result(driving())
      default: result(FlutterMethodNotImplemented)
      }
    }
    FlutterEventChannel(name: "dottoday/mission/readings", binaryMessenger: messenger)
      .setStreamHandler(Readings.shared)
  }

  private static func support(_ kind: String) -> String {
    switch kind {
    case "steps":
      guard CMPedometer.isStepCountingAvailable() else { return "missing" }
      switch CMPedometer.authorizationStatus() {
      case .authorized: return "ready"
      case .notDetermined: return "needsPermission"
      default: return "denied"
      }
    case "light":
      guard AVCaptureDevice.default(for: .video) != nil else { return "missing" }
      switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .authorized: return "ready"
      case .notDetermined: return "needsPermission"
      default: return "denied"
      }
    default:
      return CMMotionManager().isDeviceMotionAvailable ? "ready" : "missing"
    }
  }

  /// The system prompt, once; true when the sensor is ready after it.
  private static func request(_ kind: String, done: @escaping (Bool) -> Void) {
    switch kind {
    case "steps":
      // A short query is what asks for Motion & Fitness.
      CMPedometer().queryPedometerData(from: Date().addingTimeInterval(-60), to: Date()) { _, _ in
        DispatchQueue.main.async { done(support(kind) == "ready") }
      }
    case "light":
      AVCaptureDevice.requestAccess(for: .video) { granted in
        DispatchQueue.main.async { done(granted) }
      }
    default:
      done(support(kind) == "ready")
    }
  }

  /// CarPlay is playing: missions step aside (15 §8 rule 3).
  private static func driving() -> Bool {
    AVAudioSession.sharedInstance().currentRoute.outputs.contains { $0.portType == .carAudio }
  }

  /// One sensor at a time, while Dart listens.
  final class Readings: NSObject, FlutterStreamHandler, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = Readings()
    private var sink: FlutterEventSink?
    private var start = Date()
    private let pedometer = CMPedometer()
    private let motion = CMMotionManager()
    private var camera: AVCaptureSession?
    private let cameraQueue = DispatchQueue(label: "dottoday.mission.camera")
    private var lastLight = Date.distantPast

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      sink = events
      start = Date()
      switch (arguments as? [String: Any])?["kind"] as? String {
      case "steps": steps()
      case "light": light()
      default: moves()
      }
      return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
      pedometer.stopUpdates()
      motion.stopDeviceMotionUpdates()
      camera?.stopRunning()
      camera = nil
      sink = nil
      return nil
    }

    private var t: Int { Int(Date().timeIntervalSince(start) * 1000) }

    private func send(_ reading: [String: Any]) {
      DispatchQueue.main.async { [weak self] in self?.sink?(reading) }
    }

    private func steps() {
      pedometer.startUpdates(from: start) { [weak self] data, error in
        guard let self else { return }
        if let error {
          return DispatchQueue.main.async {
            self.sink?(FlutterError(code: "steps", message: error.localizedDescription, details: nil))
          }
        }
        send(["t": t, "steps": data?.numberOfSteps.intValue ?? 0])
      }
    }

    private func moves() {
      motion.deviceMotionUpdateInterval = 0.1
      motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
        guard let self, let data else { return }
        let a = data.userAcceleration
        // Upright, screen facing you: gravity points down the long axis.
        send([
          "t": t,
          "upright": -data.gravity.y,
          "moving": (a.x * a.x + a.y * a.y + a.z * a.z).squareRoot(),
        ])
      }
    }

    private func light() {
      guard let device = AVCaptureDevice.default(for: .video),
        let input = try? AVCaptureDeviceInput(device: device)
      else {
        sink?(FlutterError(code: "missing", message: "light", details: nil))
        return
      }
      let session = AVCaptureSession()
      session.sessionPreset = .low
      let output = AVCaptureVideoDataOutput()
      output.alwaysDiscardsLateVideoFrames = true
      output.setSampleBufferDelegate(self, queue: cameraQueue)
      guard session.canAddInput(input), session.canAddOutput(output) else { return }
      session.addInput(input)
      session.addOutput(output)
      camera = session
      cameraQueue.async { session.startRunning() }
    }

    /// Reads only the frame's EXIF metadata, twice a second.
    func captureOutput(_ output: AVCaptureOutput, didOutput buffer: CMSampleBuffer, from connection: AVCaptureConnection) {
      guard Date().timeIntervalSince(lastLight) >= 0.5,
        let exif = CMGetAttachment(buffer, key: kCGImagePropertyExifDictionary, attachmentModeOut: nil)
          as? [String: Any],
        let bv = exif[kCGImagePropertyExifBrightnessValue as String] as? Double
      else { return }
      lastLight = Date()
      // APEX Bv is a log2 scale: a linear value, so "3× as bright" holds.
      send(["t": t, "brightness": pow(2, bv)])
    }
  }
}
