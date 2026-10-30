import 'package:dottoday/core/failures/app_failure.dart';

/// Whether dictation can run for a language on this device (ADR-0014).
enum SpeechAvailability {
  /// An on-device recognizer for the language, and the user said yes.
  available,

  /// An on-device recognizer exists; the OS hasn't asked the user yet.
  needsPermission,

  /// The user said no to the microphone (or speech recognition).
  denied,

  /// The device can recognize the language on-device but hasn't got its
  /// model yet (Android 13+): the mic shows, and the first tap asks the OS
  /// to fetch it (owner, 2026-10-30, amending D2).
  downloadable,

  /// The OS is fetching the language's model: the mic waits.
  downloading,

  /// No on-device recognizer for the language here (D2: the mic hides).
  unavailable,
}

/// What a running recognizer reports (ADR-0014). Text is the user's
/// words: never logged, never stored apart from the field (CLAUDE.md §4).
sealed class SpeechEvent {
  const SpeechEvent();
}

/// The recognizer's current guess for the utterance in progress; each
/// one replaces the last (iOS and Android send the whole utterance so
/// far, the web its unfinished result).
final class SpeechPartial extends SpeechEvent {
  const SpeechPartial(this.text);

  final String text;
}

/// The utterance is settled: [text] is final, and the next partial
/// starts a new utterance.
final class SpeechFinal extends SpeechEvent {
  const SpeechFinal(this.text);

  final String text;
}

/// Listening ended: the user stopped, the app left the foreground, or
/// the OS interrupted (a call, an alarm).
final class SpeechStopped extends SpeechEvent {
  const SpeechStopped();
}

/// Listening ended with [failure] (a [SpeechFailure] or a
/// [PermissionFailure] for the microphone).
final class SpeechError extends SpeechEvent {
  const SpeechError(this.failure);

  final AppFailure failure;
}

/// The platform's own on-device speech recognizer (ADR-0014, D1):
/// `SFSpeechRecognizer` with on-device recognition required on iOS and
/// macOS, `createOnDeviceSpeechRecognizer` on Android 12+, the Web Speech
/// API with `processLocally` in Chrome. Audio and words never leave the
/// device. [localeTag] is a BCP 47 tag ("en-US", "de").
abstract interface class SpeechRecognizer {
  Future<SpeechAvailability> availability(String localeTag);

  /// Asks the OS for the microphone (and speech recognition on Apple);
  /// the app shows its own rationale first (D5).
  Future<SpeechAvailability> requestPermission(String localeTag);

  /// Asks the OS to fetch [localeTag]'s on-device model; the answer is
  /// the availability right after asking (usually [downloading]). Only
  /// Android does this; elsewhere it is [SpeechAvailability.unavailable].
  /// The model comes from the OS itself, never through Dottoday.
  Future<SpeechAvailability> download(String localeTag);

  /// Starts listening; the stream ends after [SpeechStopped] or
  /// [SpeechError].
  Stream<SpeechEvent> start(String localeTag);

  /// Stops listening; the stream then ends with [SpeechStopped].
  Future<void> stop();
}
