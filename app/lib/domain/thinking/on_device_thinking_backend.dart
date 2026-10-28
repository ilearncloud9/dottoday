import 'dart:async';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/domain/thinking/model_output.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';

/// How a platform's on-device model is reached: a method channel to Swift
/// (Foundation Models) or Kotlin (Gemini Nano), or Chrome's Prompt API.
/// Implementations live in `data/thinking/` and make no network call
/// (policy test).
abstract interface class ThinkingTransport {
  Future<ThinkingAvailability> availability();

  /// The model's raw answer to [prompt], or null. May throw; the backend
  /// catches.
  Future<String?> generate(ThinkingPrompt prompt);
}

/// [ThinkingBackend] over a [ThinkingTransport]: builds the prompt, waits
/// at most [timeout], validates the answer with [ModelOutput] and records
/// the exchange in the local [journal]. Same code for iOS, macOS, Android
/// and web, so their answers are checked alike.
final class OnDeviceThinkingBackend implements ThinkingBackend {
  OnDeviceThinkingBackend({
    required ThinkingTransport transport,
    required ThinkingJournal journal,
    required Clock clock,
    this.timeout = const Duration(seconds: 10),
    void Function(ThinkingKind? kind, {required bool timedOut})? onError,
  }) : _transport = transport,
       _journal = journal,
       _clock = clock,
       _onError = onError;

  final ThinkingTransport _transport;
  final ThinkingJournal _journal;
  final Clock _clock;

  /// What failed (null: asking whether the model is there) and whether it
  /// was the timeout; never the error text, which may quote the prompt.
  final void Function(ThinkingKind? kind, {required bool timedOut})? _onError;

  /// Generous: the 2 s target (11 B1) is measured by the perf test; this
  /// only stops a stuck model from holding the sheet.
  final Duration timeout;

  @override
  ThinkingPath get path => ThinkingPath.onDevice;

  @override
  Future<ThinkingAvailability> availability() async {
    try {
      return await _transport.availability().timeout(timeout);
    } on Object catch (e) {
      _onError?.call(null, timedOut: e is TimeoutException);
      return ThinkingAvailability.unknown;
    }
  }

  @override
  Future<BreakdownProposal?> breakDown(BreakdownRequest request) async {
    final text = await _ask(ThinkingPrompts.breakDown(request));
    final steps = ModelOutput.breakdown(text, request.stepLimit);
    return steps == null
        ? null
        : BreakdownProposal(steps: steps, origin: ThinkingOrigin.onDevice);
  }

  @override
  Future<TextPlanProposal?> planFromText(TextPlanRequest request) async {
    final dots = ModelOutput.dots(
      await _ask(ThinkingPrompts.planFromText(request)),
    );
    return dots == null
        ? null
        : TextPlanProposal(dots: dots, origin: ThinkingOrigin.onDevice);
  }

  @override
  Future<DurationProposal?> suggestDuration(DurationRequest request) async {
    final minutes = ModelOutput.minutes(
      await _ask(ThinkingPrompts.suggestDuration(request)),
    );
    return minutes == null
        ? null
        : DurationProposal(minutes: minutes, origin: ThinkingOrigin.onDevice);
  }

  Future<String?> _ask(ThinkingPrompt prompt) async {
    String? output;
    try {
      output = await _transport.generate(prompt).timeout(timeout);
    } on Object catch (e) {
      // No error text: it may quote the prompt (CLAUDE.md §4).
      _onError?.call(prompt.kind, timedOut: e is TimeoutException);
    }
    await _journal.record(
      ThinkingExchange(
        kind: prompt.kind.wire,
        prompt: prompt.prompt,
        output: output,
        atUtc: _clock.nowUtc(),
      ),
    );
    return output;
  }
}
