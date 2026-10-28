import 'package:dottoday/domain/thinking/on_device_thinking_backend.dart';
import 'package:dottoday/domain/thinking/rules_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../../support/thinking_fakes.dart';

// B4 contract (docs/09 M10.1, ADR-0009): every backend answers the same
// three questions through one fake, never throws, and only proposes —
// lengths in the schema's ranges, titles non-empty and ≤ 200, lists capped.
// The on-device backend is the same code on iOS, macOS, Android and the web
// (only the transport differs), so one row per platform runs it.

const _good = {
  ThinkingKind.breakDown:
      '{"steps":[{"title":"Clear the counter","minutes":5},'
      '{"title":"Load the dishwasher","minutes":10},'
      '{"title":"Wipe surfaces","minutes":5}]}',
  ThinkingKind.planFromText:
      '{"dots":[{"title":"Gym","start":"07:00","minutes":45},'
      '{"title":"Call mum"}]}',
  ThinkingKind.suggestDuration: '{"minutes":40}',
};

final _clock = FakeClock(DateTime.utc(2026, 10, 25, 8));

ThinkingBackend _onDevice(FakeThinkingTransport t) => OnDeviceThinkingBackend(
  transport: t,
  journal: MemoryThinkingMemory(),
  clock: _clock,
  timeout: const Duration(milliseconds: 200),
);

final _backends = <String, ThinkingBackend Function(FakeThinkingTransport)>{
  'iOS · Foundation Models': _onDevice,
  'macOS · Foundation Models': _onDevice,
  'Android · Gemini Nano': _onDevice,
  'web · Prompt API': _onDevice,
  'rules': (_) => RulesThinkingBackend(
    MemoryThinkingMemory(),
    learning:
        (FakeLearning()..lengths['Clean the kitchen'] = [30, 40, 50, 40]).call,
  ),
};

const _breakdown = BreakdownRequest(
  title: 'Clean the kitchen',
  language: 'en',
  durationMin: 30,
);
final _text = TextPlanRequest(
  text: 'Gym 7am 45m\nCall mum',
  language: 'en',
  nowUtc: _clock.nowUtc(),
  tzId: 'Europe/Berlin',
);
const _duration = DurationRequest(title: 'Clean the kitchen', language: 'en');

void _expectValidSteps(BreakdownProposal p, {required bool template}) {
  expect(p.steps.length, inInclusiveRange(1, _breakdown.stepLimit));
  for (final s in p.steps) {
    if (!template) expect(s.title.trim(), isNotEmpty);
    expect(s.title.length, lessThanOrEqualTo(200));
    if (s.durationMin != null) {
      expect(s.durationMin, inInclusiveRange(1, 1440));
    }
  }
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final MapEntry(key: name, value: make) in _backends.entries) {
    group(name, () {
      test('answers all three with valid proposals', () async {
        final backend = make(FakeThinkingTransport(answers: {..._good}));
        expect(await backend.availability(), ThinkingAvailability.available);
        final steps = (await backend.breakDown(_breakdown))!;
        _expectValidSteps(
          steps,
          template: steps.origin == ThinkingOrigin.rules,
        );
        final plan = (await backend.planFromText(_text))!;
        expect(plan.dots.map((d) => d.title), ['Gym', 'Call mum']);
        expect(plan.dots.first.minuteOfDay, 7 * 60);
        expect(plan.dots.first.durationMin, 45);
        final length = (await backend.suggestDuration(_duration))!;
        expect(length.minutes, 40);
      });

      test('a broken model never throws', () async {
        final backend = make(
          FakeThinkingTransport(error: StateError('model crashed')),
        );
        await expectLater(backend.breakDown(_breakdown), completes);
        await expectLater(backend.planFromText(_text), completes);
        await expectLater(backend.suggestDuration(_duration), completes);
      });
    });
  }

  group('on-device answers are untrusted', () {
    test('garbage, empty and wrong shapes give no proposal', () async {
      for (final answer in [
        null,
        '',
        'Sure! Here are the steps:',
        '{"steps":"nope"}',
        '{"steps":[{"title":"   "}]}',
        '[1,2]',
      ]) {
        final backend = _onDevice(
          FakeThinkingTransport(answers: {ThinkingKind.breakDown: answer}),
        );
        expect(await backend.breakDown(_breakdown), isNull, reason: answer);
      }
    });

    test('a slow model times out to null', () async {
      final backend = _onDevice(
        FakeThinkingTransport(
          answers: {..._good},
          delay: const Duration(seconds: 1),
        ),
      );
      expect(await backend.breakDown(_breakdown), isNull);
    });

    test(
      'every exchange is journaled locally, with or without output',
      () async {
        final journal = MemoryThinkingMemory();
        final transport = FakeThinkingTransport(answers: {..._good});
        final backend = OnDeviceThinkingBackend(
          transport: transport,
          journal: journal,
          clock: _clock,
        );
        await backend.breakDown(_breakdown);
        transport.error = StateError('x');
        await backend.suggestDuration(_duration);
        expect(journal.exchanges.map((e) => e.kind), [
          'break_down',
          'suggest_duration',
        ]);
        expect(journal.exchanges.first.prompt, contains('Clean the kitchen'));
        expect(journal.exchanges.last.output, isNull);
      },
    );

    test('the prompt carries language, schema and the step cap', () async {
      final transport = FakeThinkingTransport(answers: {..._good});
      await _onDevice(transport).breakDown(
        const BreakdownRequest(
          title: 'Aufräumen',
          language: 'de',
          stepLimit: 5,
        ),
      );
      final wire = transport.prompts.single.toWire();
      expect(wire['kind'], 'break_down');
      expect(wire['language'], 'de');
      expect(wire['instructions'], contains('"de"'));
      expect(wire['prompt'], contains('2 to 5 steps'));
      expect(wire['schema'], contains('"maxItems":5'));
    });

    test('an availability error reads as unknown', () async {
      final backend = OnDeviceThinkingBackend(
        transport: _ThrowingAvailability(),
        journal: MemoryThinkingMemory(),
        clock: _clock,
      );
      expect(await backend.availability(), ThinkingAvailability.unknown);
    });
  });
}

final class _ThrowingAvailability extends FakeThinkingTransport {
  @override
  Future<ThinkingAvailability> availability() => throw StateError('no api');
}
