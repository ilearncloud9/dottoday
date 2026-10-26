import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/scheduling/learning_thresholds.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/reality_fixtures.dart';
import '../../support/timeline_fakes.dart';

// docs/13 §2: one injected LearningThresholds. Overriding it moves the
// live index, the one-shot read B4 uses and the history's reach.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  ProviderContainer container(LearningThresholds thresholds) {
    final c = ProviderContainer(
      overrides: [
        ...timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 8),
          occurrences: FakeOccurrenceRepository(deepWorkHistory()),
        ),
        learningThresholdsProvider.overrideWithValue(thresholds),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<int?> usual(ProviderContainer c) async {
    final sub = c.listen(learningIndexProvider, (_, _) {});
    addTearDown(sub.close);
    final index = await c.read(learningIndexProvider.future);
    return index.forTask(title: 'Deep work: roadmap').usualMinutes;
  }

  test('the standard value: four runs speak', () async {
    expect(await usual(container(LearningThresholds.standard)), 140);
  });

  test('an override reaches the index and the history range', () async {
    expect(
      await usual(container(const LearningThresholds(taskMinSamples: 5))),
      isNull,
    );
    // The runs are 5–8 days back: a 3-day reach sees none of them.
    expect(
      await usual(container(const LearningThresholds(historyDays: 3))),
      isNull,
    );
  });

  test("B4's length suggestion reads the same index", () async {
    Future<int?> suggested(LearningThresholds t) async {
      final r = await container(t)
          .read(thinkingServiceProvider)
          .suggestDuration(
            const DurationRequest(title: 'Deep work: roadmap', language: 'en'),
          );
      return switch (r) {
        Ok(:final value) => value?.minutes,
        Err() => null,
      };
    }

    expect(await suggested(LearningThresholds.standard), 140);
    expect(
      await suggested(const LearningThresholds(taskMinSamples: 5)),
      isNot(140),
    );
  });
}
