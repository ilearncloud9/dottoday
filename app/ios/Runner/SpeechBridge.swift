import AVFoundation
import Foundation
import Speech

#if os(iOS)
  import Flutter
  import UIKit
#else
  import AppKit
  import FlutterMacOS
#endif

/// `dottoday/speech` + `dottoday/speech/events` (lib/data/speech/
/// channel_speech_transport.dart, docs/09 M14.4, ADR-0014): dictation with
/// Apple's own recognizer, on the device only — a locale whose recognizer
/// can't run on-device is "unavailable" and the mic hides (D2), and every
/// request sets `requiresOnDeviceRecognition`. Compiled into the iOS and
/// the macOS Runner (one file, R-13). Audio goes from the input tap to the
/// recognizer and nowhere else; text goes to Dart only, never to a log or
/// a file. No network API is used here (speech_on_device_test). On iOS
/// the audio session is active only while listening, so alarms and
/// reminder sounds are unaffected; listening stops on an interruption and
/// when the app leaves the foreground.
final class SpeechBridge: NSObject, FlutterStreamHandler {
  static let shared = SpeechBridge()

  private var sink: FlutterEventSink?
  private let engine = AVAudioEngine()
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var task: SFSpeechRecognitionTask?
  /// Set by stop(): the final result ends the session, not an error.
  private var stopping = false

  static func register(_ messenger: FlutterBinaryMessenger) {
    let methods = FlutterMethodChannel(name: "dottoday/speech", binaryMessenger: messenger)
    FlutterEventChannel(name: "dottoday/speech/events", binaryMessenger: messenger)
      .setStreamHandler(shared)
    methods.setMethodCallHandler { call, result in shared.handle(call, result) }
    shared.observeLifecycle()
  }

  private func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let locale = (call.arguments as? [String: Any])?["locale"] as? String ?? ""
    switch call.method {
    case "availability":
      result(availability(locale))
    case "requestPermission":
      requestPermission { result(self.availability(locale)) }
    case "start":
      if let code = start(locale) {
        result(FlutterError(code: code, message: nil, details: nil))
      } else {
        result(nil)
      }
    case "stop":
      stop()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: Availability and permission

  /// The recognizer for [tag]'s language: the device's own region when it
  /// speaks that language ("en" on an en-GB phone → en-GB), else the first
  /// locale Apple supports for it. Nil when there is none.
  private func recognizer(for tag: String) -> SFSpeechRecognizer? {
    let language = String(tag.split(separator: "-").first ?? "")
    guard !language.isEmpty else { return nil }
    let current = Locale.current
    if current.identifier.hasPrefix(language), let r = SFSpeechRecognizer(locale: current) {
      return r
    }
    if tag.contains("-"), let r = SFSpeechRecognizer(locale: Locale(identifier: tag)) {
      return r
    }
    let match = SFSpeechRecognizer.supportedLocales()
      .filter { $0.identifier.hasPrefix(language) }
      .sorted { $0.identifier < $1.identifier }
      .first
    return match.flatMap { SFSpeechRecognizer(locale: $0) }
  }

  private func availability(_ tag: String) -> String {
    guard let r = recognizer(for: tag), r.supportsOnDeviceRecognition else { return "unavailable" }
    switch SFSpeechRecognizer.authorizationStatus() {
    case .denied, .restricted: return "denied"
    case .notDetermined: return "needs_permission"
    default: break
    }
    switch microphone() {
    case .denied: return "denied"
    case .undetermined: return "needs_permission"
    case .granted: return "available"
    }
  }

  private enum Mic { case granted, denied, undetermined }

  private func microphone() -> Mic {
    #if os(iOS)
      if #available(iOS 17.0, *) {
        switch AVAudioApplication.shared.recordPermission {
        case .granted: return .granted
        case .denied: return .denied
        default: return .undetermined
        }
      }
      switch AVAudioSession.sharedInstance().recordPermission {
      case .granted: return .granted
      case .denied: return .denied
      default: return .undetermined
      }
    #else
      switch AVCaptureDevice.authorizationStatus(for: .audio) {
      case .authorized: return .granted
      case .notDetermined: return .undetermined
      default: return .denied
      }
    #endif
  }

  /// Speech recognition first, then the microphone; [done] on main.
  private func requestPermission(_ done: @escaping () -> Void) {
    SFSpeechRecognizer.requestAuthorization { status in
      guard status == .authorized else { return DispatchQueue.main.async(execute: done) }
      #if os(iOS)
        if #available(iOS 17.0, *) {
          AVAudioApplication.requestRecordPermission { _ in DispatchQueue.main.async(execute: done) }
        } else {
          AVAudioSession.sharedInstance().requestRecordPermission { _ in
            DispatchQueue.main.async(execute: done)
          }
        }
      #else
        AVCaptureDevice.requestAccess(for: .audio) { _ in DispatchQueue.main.async(execute: done) }
      #endif
    }
  }

  // MARK: Listening

  /// Starts listening; an error code, or nil when it started.
  private func start(_ tag: String) -> String? {
    teardown()
    guard let recognizer = recognizer(for: tag), recognizer.supportsOnDeviceRecognition else {
      return "unavailable"
    }
    guard availability(tag) == "available" else { return "permission" }
    let request = SFSpeechAudioBufferRecognitionRequest()
    request.shouldReportPartialResults = true
    // D1: never a server, whatever the OS would prefer.
    request.requiresOnDeviceRecognition = true
    if #available(iOS 16.0, macOS 13.0, *) { request.addsPunctuation = true }
    do {
      #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
      #endif
      let input = engine.inputNode
      input.installTap(onBus: 0, bufferSize: 1024, format: input.outputFormat(forBus: 0)) {
        buffer, _ in request.append(buffer)
      }
      engine.prepare()
      try engine.start()
    } catch {
      teardown()
      return "recognizer"
    }
    self.request = request
    stopping = false
    task = recognizer.recognitionTask(with: request) { [weak self] result, error in
      DispatchQueue.main.async { self?.received(result, error) }
    }
    return nil
  }

  private func received(_ result: SFSpeechRecognitionResult?, _ error: Error?) {
    guard task != nil else { return }
    if let result {
      send(["type": result.isFinal ? "final" : "partial", "text": result.bestTranscription.formattedString])
    }
    guard error != nil || result?.isFinal == true else { return }
    // No message: it can quote what was said.
    let failed = error != nil && !stopping
    teardown()
    send(failed ? ["type": "error", "code": "recognizer"] : ["type": "stopped"])
  }

  /// Ends the audio; the recognizer then sends its final result, which
  /// ends the session (at most 1 s later, else it is cancelled).
  func stop() {
    guard task != nil else { return }
    stopping = true
    request?.endAudio()
    engine.stop()
    engine.inputNode.removeTap(onBus: 0)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      guard let self, self.stopping, self.task != nil else { return }
      self.teardown()
      self.send(["type": "stopped"])
    }
  }

  /// The OS took the microphone: end now and say why.
  private func interrupted() {
    guard task != nil else { return }
    teardown()
    send(["type": "error", "code": "interrupted"])
  }

  private func teardown() {
    task?.cancel()
    task = nil
    request = nil
    stopping = false
    if engine.isRunning { engine.stop() }
    engine.inputNode.removeTap(onBus: 0)
    #if os(iOS)
      try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    #endif
  }

  private func observeLifecycle() {
    let center = NotificationCenter.default
    #if os(iOS)
      center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) {
        _ in self.stop()
      }
      center.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) {
        _ in self.interrupted()
      }
    #else
      center.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: .main) {
        _ in self.stop()
      }
    #endif
  }

  private func send(_ event: [String: String]) {
    sink?(event)
  }

  // MARK: FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    stop()
    return nil
  }
}
