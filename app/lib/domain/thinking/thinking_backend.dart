import 'package:dottoday/domain/thinking/thinking_proposals.dart';

/// The routes a thinking request can take (ADR-0009 §1, in order of
/// preference). Only [onDevice] and [rules] are wired; [cloud] and
/// [ownKey] exist as interfaces behind [ThinkingFlags.remoteBackends].
enum ThinkingPath { onDevice, rules, cloud, ownKey }

/// Whether a backend can answer right now.
enum ThinkingAvailability {
  available,

  /// The OS can fetch the model (Gemini Nano, Chrome) but hasn't yet.
  downloadable,

  /// Not on this device: too old, not eligible, switched off, or the API is
  /// missing.
  unavailable,
}

/// Language of the user's text and of the steps a model should write, as a
/// BCP 47 primary subtag ("en", "de").
typedef ThinkingLanguage = String;

/// "Break it down" input (11 B1). [depth] is the level of the thing being
/// broken down: 0 for a task, 1 for one of its steps; its steps land at
/// `depth + 1`, which may be at most [maxDepth].
final class BreakdownRequest {
  const BreakdownRequest({
    required this.title,
    required this.language,
    this.durationMin,
    this.depth = 0,
    this.stepLimit = defaultMaxSteps,
  });

  /// "Recursive on any step; depth capped at 3" (11 B1).
  static const maxDepth = 3;

  /// Steps a model proposes: small enough to answer in < 2 s on-device
  /// (11 B1; 7 steps took ~1.9 s on the simulator, 5 ~1.4 s). The user can
  /// still add steps in the sheet, up to [maxSteps].
  static const defaultMaxSteps = 5;

  /// Longest list the proposal sheet holds (the mini thread golden's 7).
  static const maxSteps = 7;

  final String title;
  final ThinkingLanguage language;

  /// The task's planned length, so steps can share it out.
  final int? durationMin;
  final int depth;

  /// Most steps to propose, at most [maxSteps].
  final int stepLimit;
}

/// Brain-dump input (11 B4): free text for one local day.
final class TextPlanRequest {
  const TextPlanRequest({
    required this.text,
    required this.language,
    required this.nowUtc,
    required this.tzId,
  });

  final String text;
  final ThinkingLanguage language;

  /// Resolves "tomorrow" and "3pm" for the rules path.
  final DateTime nowUtc;
  final String tzId;
}

/// Length suggestion input.
final class DurationRequest {
  const DurationRequest({required this.title, required this.language});

  final String title;
  final ThinkingLanguage language;
}

/// One way of answering thinking requests. Implementations never write
/// anything and never throw: `null` means "no answer from this path", and
/// the service moves on to the next one.
abstract interface class ThinkingBackend {
  ThinkingPath get path;

  Future<ThinkingAvailability> availability();

  Future<BreakdownProposal?> breakDown(BreakdownRequest request);

  Future<TextPlanProposal?> planFromText(TextPlanRequest request);

  Future<DurationProposal?> suggestDuration(DurationRequest request);
}

/// A server-side model: our metered endpoint (Pro, opt-in) or the user's
/// own OpenAI-compatible key (ADR-0009 §1). Deliberately unimplemented:
/// wiring any provider sends task text off the device, which is a
/// must-ask (CLAUDE.md §11).
abstract interface class RemoteThinkingBackend implements ThinkingBackend {
  /// The fields a request sends, for the Privacy line and review
  /// (ADR-0009 §4: "only the fields the feature needs").
  Set<String> get sentFields;
}

/// Compile-time switches for the thinking paths.
abstract final class ThinkingFlags {
  /// Off: `ThinkingService` refuses remote backends while this is false.
  static const remoteBackends = false;
}
