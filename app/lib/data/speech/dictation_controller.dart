import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/data/speech/speech_providers.dart';
import 'package:dottoday/domain/speech/dictation_text.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dictation_controller.g.dart';

/// Where a dictation is: [starting] while the permission flow runs,
/// [fetching] while Android downloads the language's model.
enum DictationPhase { idle, starting, fetching, listening }

/// The app's one dictation (docs/09 M14.5): which field ([owner]) it
/// writes into, its phase, the [dictation] so far and why it last ended
/// early ([failure]). Fields apply [Dictation.text] only when they own it.
final class DictationState {
  const DictationState({
    this.owner,
    this.phase = DictationPhase.idle,
    this.dictation,
    this.failure,
    this.ready = false,
  });

  final Object? owner;
  final DictationPhase phase;
  final Dictation? dictation;
  final AppFailure? failure;

  /// The language's model just arrived: the next tap listens.
  final bool ready;

  bool listeningFor(Object owner) =>
      this.owner == owner && phase != DictationPhase.idle;
}

/// How often a fetching language model is checked, and how long at most.
const _fetchEvery = Duration(seconds: 2);
const _fetchFor = Duration(minutes: 10);

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
  Timer? _fetchCheck;

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

  /// The language has no model on the device yet (Android 13+): asks the
  /// OS to fetch it and checks every [_fetchEvery] until it is there,
  /// then says so ([DictationState.ready]); the user taps again to speak.
  /// Gives up quietly if the download doesn't start (declined) or takes
  /// longer than [_fetchFor].
  Future<void> prepareLanguage(Object owner, String localeTag) async {
    await stop();
    final recognizer = ref.read(speechRecognizerProvider);
    state = DictationState(owner: owner, phase: DictationPhase.fetching);
    final asked = await recognizer.download(localeTag);
    if (asked == SpeechAvailability.unavailable) {
      return notStarted(
        owner,
        failure: const SpeechFailure(SpeechFailureKind.unavailable),
      );
    }
    var waited = Duration.zero;
    var idle = 0;
    _fetchCheck?.cancel();
    _fetchCheck = Timer.periodic(_fetchEvery, (t) async {
      waited += _fetchEvery;
      final a = await recognizer.availability(localeTag);
      if (state.owner != owner || state.phase != DictationPhase.fetching) {
        return t.cancel();
      }
      if (a == SpeechAvailability.downloadable) idle++;
      final done =
          a != SpeechAvailability.downloading &&
          a != SpeechAvailability.downloadable;
      if (done || idle >= 3 || waited >= _fetchFor) {
        t.cancel();
        ref.invalidate(speechAvailabilityProvider(localeTag));
        state = DictationState(
          owner: owner,
          ready: a != SpeechAvailability.unavailable && done,
        );
      }
    });
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
    _fetchCheck?.cancel();
    _fetchCheck = null;
    _ticker?.cancel();
    _ticker = null;
    unawaited(_events?.cancel());
    _events = null;
  }
}
