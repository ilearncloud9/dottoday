import Foundation

#if os(iOS)
  import Flutter
#else
  import FlutterMacOS
#endif
#if canImport(FoundationModels)
  import FoundationModels
#endif

/// `dottoday/thinking` (lib/data/thinking/channel_thinking_transport.dart,
/// docs/09 M10.1, ADR-0009): Apple Foundation Models on iOS/macOS 26+, on
/// the device only. `availability` answers "available", "downloading"
/// (Apple Intelligence still preparing the model), "not_enabled" (Apple
/// Intelligence is off), "not_eligible" (device, OS or region can't) or
/// "unknown" (docs/09 M14.1; words pinned by thinking_wire_contract_test);
/// `generate` runs one guided generation and returns its JSON, which Dart
/// validates before anything is proposed. Compiled into the iOS and the
/// macOS Runner (one file, R-13). No network API is used here (policy test).
enum ThinkingBridge {
  static func register(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/thinking", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "availability":
        result(availability())
      case "generate":
        guard let args = call.arguments as? [String: Any],
          let kind = args["kind"] as? String,
          let instructions = args["instructions"] as? String,
          let prompt = args["prompt"] as? String
        else { return result(FlutterError(code: "bad_args", message: nil, details: nil)) }
        Task {
          let json = await generate(kind: kind, instructions: instructions, prompt: prompt)
          DispatchQueue.main.async {
            result(json ?? FlutterError(code: "no_answer", message: nil, details: nil))
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  static func availability() -> String {
    #if canImport(FoundationModels)
      if #available(iOS 26.0, macOS 26.0, *) {
        switch SystemLanguageModel.default.availability {
        case .available: return "available"
        case .unavailable(.appleIntelligenceNotEnabled): return "not_enabled"
        case .unavailable(.deviceNotEligible): return "not_eligible"
        case .unavailable(.modelNotReady): return "downloading"
        default: return "unknown"
        }
      }
    #endif
    // Before iOS/macOS 26 there is no on-device model to turn on.
    return "not_eligible"
  }

  /// The model's answer as JSON, or nil (unavailable, refused, failed).
  /// Errors are dropped without their text: it can quote the prompt.
  static func generate(kind: String, instructions: String, prompt: String) async -> String? {
    #if canImport(FoundationModels)
      if #available(iOS 26.0, macOS 26.0, *) {
        let session = LanguageModelSession(instructions: instructions)
        do {
          switch kind {
          case "break_down":
            return encode(try await session.respond(to: prompt, generating: GenSteps.self).content)
          case "plan_from_text":
            return encode(try await session.respond(to: prompt, generating: GenDots.self).content)
          case "suggest_duration":
            return encode(try await session.respond(to: prompt, generating: GenMinutes.self).content)
          default:
            return nil
          }
        } catch {
          return nil
        }
      }
    #endif
    return nil
  }

  private static func encode<T: Encodable>(_ value: T) -> String? {
    (try? JSONEncoder().encode(value)).flatMap { String(data: $0, encoding: .utf8) }
  }
}

#if canImport(FoundationModels)
  // Guided generation: the model can only produce these shapes, which
  // mirror the JSON schemas in lib/domain/thinking/thinking_prompts.dart.

  @available(iOS 26.0, macOS 26.0, *)
  @Generable
  struct GenSteps: Encodable {
    @Guide(description: "The steps in the order they are done", .maximumCount(5))
    var steps: [GenStep]
  }

  @available(iOS 26.0, macOS 26.0, *)
  @Generable
  struct GenStep: Encodable {
    @Guide(description: "One small physical step, starting with a verb")
    var title: String
    @Guide(description: "Minutes this step takes", .range(1...240))
    var minutes: Int
  }

  @available(iOS 26.0, macOS 26.0, *)
  @Generable
  struct GenDots: Encodable {
    var dots: [GenDot]
  }

  @available(iOS 26.0, macOS 26.0, *)
  @Generable
  struct GenDot: Encodable {
    @Guide(description: "The task, in the user's words")
    var title: String
    @Guide(description: "24-hour HH:MM when the text names a time, else empty")
    var start: String
    @Guide(description: "Minutes the task takes", .range(5...600))
    var minutes: Int
  }

  @available(iOS 26.0, macOS 26.0, *)
  @Generable
  struct GenMinutes: Encodable {
    @Guide(description: "Minutes a typical person needs", .range(5...480))
    var minutes: Int
  }
#endif
