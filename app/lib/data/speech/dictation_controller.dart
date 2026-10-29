import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/data/speech/speech_providers.dart';
import 'package:dottoday/domain/speech/dictation_text.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dictation_controller.g.dart';

/// Where a dictation is: [starting] while the permission flow runs.
enum DictationPhase { idle, starting, listening }

/// The app's one dictation (docs/09 M14.5): which field ([owner]) it
/// writes into, its phase, the [dictation] so far and why it last ended
/// early ([failure]). Fields apply [Dictation.text] only when they own it.
final class DictationState {
  const DictationState({
    this.owner,
    this.phase = DictationPhase.idle,
    this.dictation,
    this.failure,
  });

  final Object? owner;
  final DictationPhase phase;
  final Dictation? dictation;
  final AppFailure? failure;

  bool listeningFor(Object owner) =>
      this.owner == owner && phase != DictationPhase.idle;
}

/// How often a pause or a settled command word is checked while
/// listening; well under [kCommandSettle].
const _tick = Duration(milliseconds: 150);

/// Runs one dictation at a time (ADR-0014): starts the recognizer, feeds
/// its events through [Dictation] with the injected clock, ticks for
/// pauses in Brain dump, and stops on request. Starting for another field
/// stops the first. Holds no text beyond the session; nothing is logged.
@Riverpod(keepAlive: true)
class DictationController extends _$DictationController {
  StreamSubscription<SpeechEvent>? _events;
  Timer? _ticker;

  @override
  DictationState build() {
    ref.onDispose(_end);
    return const DictationState();
  }

  /// Starts listening into [text] at [cursor] for [owner].
  Future<void> start({
    required Object owner,
    required String text,
    required int cursor,
    required DictationMode mode,
    required String localeTag,
    String? command,
  }) async {
    await stop();
    final clock = ref.read(clockProvider);
    state = DictationState(
      owner: owner,
      phase: DictationPhase.listening,
      dictation: Dictation.start(
        text: text,
        cursor: cursor,
        mode: mode,
        command: command,
        now: clock.nowUtc(),
      ),
    );
    _events = ref
        .read(speechRecognizerProvider)
        .start(localeTag)
        .listen(_on, onDone: _done);
    if (mode == DictationMode.brainDump) {
      _ticker = Timer.periodic(_tick, (_) => _apply((d, now) => d.tick(now)));
    }
  }

  /// Stops listening; the field keeps what was dictated.
  Future<void> stop() async {
    if (state.phase == DictationPhase.idle) return;
    _end();
    state = DictationState(owner: state.owner, dictation: state.dictation);
  }

  /// The permission flow for [owner] is running: the mic waits.
  void preparing(Object owner) =>
      state = DictationState(owner: owner, phase: DictationPhase.starting);

  /// The permission flow ended without listening (said no, or denied).
  void notStarted(Object owner, {AppFailure? failure}) {
    if (state.owner != owner) return;
    state = DictationState(owner: owner, failure: failure);
  }

  /// Stops if [owner] is listening (its field closed or lost focus).
  Future<void> stopFor(Object owner) =>
      state.listeningFor(owner) ? stop() : Future.value();

  void _on(SpeechEvent event) {
    switch (event) {
      case SpeechPartial(:final text):
        _apply((d, now) => d.partial(text, now), listening: true);
      case SpeechFinal(:final text):
        _apply((d, now) => d.finalResult(text, now), listening: true);
      case SpeechStopped():
        _done();
      case SpeechError(:final failure):
        _end();
        state = DictationState(
          owner: state.owner,
          dictation: state.dictation,
          failure: failure,
        );
    }
  }

  void _apply(
    Dictation Function(Dictation d, DateTime now) step, {
    bool listening = false,
  }) {
    final d = state.dictation;
    if (d == null || state.phase == DictationPhase.idle) return;
    final next = step(d, ref.read(clockProvider).nowUtc());
    final phase = listening ? DictationPhase.listening : state.phase;
    if (identical(next, d) && phase == state.phase) return;
    state = DictationState(owner: state.owner, phase: phase, dictation: next);
  }

  void _done() {
    if (state.phase == DictationPhase.idle) return;
    _end();
    state = DictationState(owner: state.owner, dictation: state.dictation);
  }

  /// Ends the ticker and the subscription; cancelling it stops the
  /// recognizer (the transport's onCancel).
  void _end() {
    _ticker?.cancel();
    _ticker = null;
    unawaited(_events?.cancel());
    _events = null;
  }
}
