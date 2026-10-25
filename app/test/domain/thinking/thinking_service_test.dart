import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/thinking/on_device_thinking_backend.dart';
import 'package:dottoday/domain/thinking/rules_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:dottoday/domain/thinking/thinking_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/fake_clock.dart';
import '../../support/thinking_fakes.dart';

// The order of paths (docs/09 M10.1, ADR-0009 §1–2, 11 B1): saved
// breakdown first with no model, then on-device, then the template; text
// and lengths likewise; depth capped at 3; nothing here can write.

const _steps =
    '{"steps":[{"title":"Clear","minutes":5},{"title":"Wipe","minutes":5}]}';

final _clock = FakeClock(DateTime.utc(2026, 10, 25, 8));

({
  ThinkingService service,
  FakeThinkingTransport model,
  MemoryThinkingMemory memory,
})
_setUp({ThinkingAvailability state = ThinkingAvailability.available}) {
  final memory = MemoryThinkingMemory();
  final model = FakeThinkingTransport(
    state: state,
    answers: {
      ThinkingKind.breakDown: _steps,
      ThinkingKind.planFromText: '{"dots":[{"title":"Gym"}]}',
      ThinkingKind.suggestDuration: '{"minutes":25}',
    },
  );
  final service = ThinkingService(
    rules: RulesThinkingBackend(memory),
    onDevice: [
      OnDeviceThinkingBackend(transport: model, journal: memory, clock: _clock),
    ],
  );
  return (service: service, model: model, memory: memory);
}

T _ok<T>(Result<T, ValidationFailure> r) => switch (r) {
  Ok(:final value) => value,
  Err(:final failure) => throw TestFailure(failure.code),
};

const _kitchen = BreakdownRequest(title: 'Clean the kitchen', language: 'en');

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('breakDown', () {
    test('the saved breakdown comes first and asks no model', () async {
      final s = _setUp();
      s.memory.saved['clean the kitchen'] = const [
        ProposedStep(title: 'Dishes', durationMin: 10),
      ];
      final p = _ok(await s.service.breakDown(_kitchen));
      expect(p.origin, ThinkingOrigin.saved);
      expect(p.steps.single.title, 'Dishes');
      expect(s.model.prompts, isEmpty);
    });

    test('then the on-device model', () async {
      final s = _setUp();
      final p = _ok(await s.service.breakDown(_kitchen));
      expect(p.origin, ThinkingOrigin.onDevice);
      expect(p.steps.map((x) => x.title), ['Clear', 'Wipe']);
      expect(p.totalMin, 10);
    });

    test(
      'without a model: the empty 3-step template sharing the length',
      () async {
        final s = _setUp(state: ThinkingAvailability.downloadable);
        final p = _ok(
          await s.service.breakDown(
            const BreakdownRequest(
              title: 'Tidy',
              language: 'en',
              durationMin: 45,
            ),
          ),
        );
        expect(p.origin, ThinkingOrigin.rules);
        expect(p.steps.map((x) => x.title), ['', '', '']);
        expect(p.steps.map((x) => x.durationMin), [15, 15, 15]);
        expect(s.model.prompts, isEmpty);
      },
    );

    test('a model that answers badly falls back to the template', () async {
      final s = _setUp();
      s.model.answers[ThinkingKind.breakDown] = 'no json';
      final p = _ok(await s.service.breakDown(_kitchen));
      expect(p.origin, ThinkingOrigin.rules);
    });

    test(
      'depth is capped at 3: a step at depth 2 may split, at 3 not',
      () async {
        final s = _setUp();
        for (final depth in [0, 1, 2]) {
          final r = await s.service.breakDown(
            BreakdownRequest(title: 'Step', language: 'en', depth: depth),
          );
          expect(r, isA<Ok<BreakdownProposal, ValidationFailure>>());
        }
        for (final depth in [3, 4, -1]) {
          final r = await s.service.breakDown(
            BreakdownRequest(title: 'Step', language: 'en', depth: depth),
          );
          expect(
            r,
            const Err<BreakdownProposal, ValidationFailure>(
              ValidationFailure(
                ValidationField.subtasks,
                ValidationRule.outOfRange,
              ),
            ),
          );
        }
      },
    );

    test('empty and over-long titles are refused before any model', () async {
      final s = _setUp();
      expect(
        await s.service.breakDown(
          const BreakdownRequest(title: ' ', language: 'en'),
        ),
        isA<Err<BreakdownProposal, ValidationFailure>>(),
      );
      expect(
        await s.service.breakDown(
          BreakdownRequest(title: 'x' * 201, language: 'en'),
        ),
        isA<Err<BreakdownProposal, ValidationFailure>>(),
      );
      expect(s.model.prompts, isEmpty);
    });
  });

  group('planFromText', () {
    final request = TextPlanRequest(
      text: 'Gym 7am\n- Call mum 30m',
      language: 'en',
      nowUtc: _clock.nowUtc(),
      tzId: 'Europe/Berlin',
    );

    test('on-device first', () async {
      final p = _ok(await _setUp().service.planFromText(request))!;
      expect(p.origin, ThinkingOrigin.onDevice);
    });

    test("then Quick Add's parser, bullets and times understood", () async {
      final s = _setUp(state: ThinkingAvailability.unavailable);
      final p = _ok(await s.service.planFromText(request))!;
      expect(p.origin, ThinkingOrigin.rules);
      expect(p.dots.map((d) => d.title), ['Gym', 'Call mum']);
      expect(p.dots.first.minuteOfDay, 7 * 60);
      expect(p.dots.last.durationMin, 30);
    });

    test('empty and over-long text is refused', () async {
      final s = _setUp();
      Future<Object> plan(String text) async => s.service.planFromText(
        TextPlanRequest(
          text: text,
          language: 'en',
          nowUtc: _clock.nowUtc(),
          tzId: 'Europe/Berlin',
        ),
      );
      expect(
        await plan('  '),
        isA<Err<TextPlanProposal?, ValidationFailure>>(),
      );
      expect(
        await plan('x' * 10001),
        isA<Err<TextPlanProposal?, ValidationFailure>>(),
      );
    });
  });

  group('suggestDuration', () {
    const request = DurationRequest(title: 'Gym', language: 'en');

    test('trusted history beats the model', () async {
      final s = _setUp();
      s.memory.lengths['gym'] = [40, 50, 45];
      final p = _ok(await s.service.suggestDuration(request))!;
      expect(p.origin, ThinkingOrigin.history);
      expect(p.minutes, 45);
      expect(p.samples, 3);
      expect(s.model.prompts, isEmpty);
    });

    test('thin history: the model, else the thin history', () async {
      final s = _setUp();
      s.memory.lengths['gym'] = [60];
      expect(_ok(await s.service.suggestDuration(request))!.minutes, 25);
      s.model.state = ThinkingAvailability.unavailable;
      final p = _ok(await s.service.suggestDuration(request))!;
      expect((p.origin, p.minutes), (ThinkingOrigin.history, 60));
    });

    test('nothing known: no suggestion', () async {
      final s = _setUp(state: ThinkingAvailability.unavailable);
      expect(_ok(await s.service.suggestDuration(request)), isNull);
    });
  });

  test('splitLength and medianLength', () {
    expect(splitLength(50, 3), [15, 15, 20]);
    expect(splitLength(60, 3), [20, 20, 20]);
    expect(splitLength(7, 3), [2, 2, 2]);
    expect(splitLength(null, 3), isNull);
    expect(medianLength([30, 50, 40]), 40);
    expect(medianLength([30, 41]), 35);
    expect(medianLength([1]), 5);
    expect(medianLength([]), isNull);
  });
}
