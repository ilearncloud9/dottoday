import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';

// The words `dottoday/speech` and `dottoday/speech/events` carry (docs/09
// M14.4): Swift, Kotlin and the web transport send only these
// (`speech_on_device_test.dart`). An event never carries more than the
// recognizer's text and a code — no error message, which can quote speech.

/// An availability word; anything else is unavailable (D2: hide the mic).
SpeechAvailability parseSpeechAvailability(String? word) => switch (word) {
  'available' => SpeechAvailability.available,
  'needs_permission' => SpeechAvailability.needsPermission,
  'denied' => SpeechAvailability.denied,
  'downloadable' => SpeechAvailability.downloadable,
  'downloading' => SpeechAvailability.downloading,
  _ => SpeechAvailability.unavailable,
};

/// One event map from a recognizer; null when it is not one.
SpeechEvent? parseSpeechEvent(Object? raw) {
  if (raw is! Map) return null;
  final text = raw['text'];
  return switch (raw['type']) {
    'partial' when text is String => SpeechPartial(text),
    'final' when text is String => SpeechFinal(text),
    'stopped' => const SpeechStopped(),
    'error' => SpeechError(speechFailureOf(raw['code'] as String?)),
    _ => null,
  };
}

/// An error code as a typed failure.
AppFailure speechFailureOf(String? code) => switch (code) {
  'permission' => const PermissionFailure(AppPermission.microphone),
  'unavailable' => const SpeechFailure(SpeechFailureKind.unavailable),
  'interrupted' => const SpeechFailure(SpeechFailureKind.interrupted),
  _ => const SpeechFailure(SpeechFailureKind.recognizer),
};
