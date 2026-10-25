// The Live Activity on the iPhone simulator (docs/09 M9.3): a live task
// starts it; the activity's own Done path (the same Swift the button runs)
// ends it at once and, through the action queue, ticks the task in the
// database; +15 moves the task's end once. iOS only.
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget/home_widget.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';

const _channel = MethodChannel('dottoday/live_activity');

Future<List<String>> _active() async =>
    (await _channel.invokeListMethod<String>('activeIds')) ?? const [];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('starts, +15 once, Done ends it and ticks the task', (
    tester,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    final container = await startApp(tester);
    final profile = await container.read(localProfileProvider.future);
    final now = DateTime.now().toUtc();
    final id = const UuidV7Generator().newId();
    final task = Occurrence(
      id: id,
      userId: profile.id,
      title: 'Live Activity check',
      tzId: profile.tzId,
      startUtc: now.subtract(const Duration(minutes: 5)),
      durationMin: 30,
      createdAt: now,
      updatedAt: now,
    );
    await container
        .read(writeUseCaseProvider)
        .apply(WriteBatch(userId: profile.id, occurrences: [task]));
    await container.read(afterWriteEffectsProvider).idle;
    await waitUntil(tester, () async => (await _active()).contains(id));

    final repo = container.read(occurrenceRepositoryProvider);
    Future<Occurrence> stored() async => (await repo.findById(profile.id, id))!;

    // +15 on the activity, twice with the same planned end: applied once.
    for (var i = 0; i < 2; i++) {
      await _channel.invokeMethod<void>('perform', {
        'kind': 'add_fifteen',
        'id': id,
        'planned_end_ms': task.endUtc!.millisecondsSinceEpoch.toDouble(),
      });
    }
    await waitUntil(tester, () async => (await stored()).durationMin == 45);

    await _channel.invokeMethod<void>('perform', {'kind': 'done', 'id': id});
    expect(await _active(), isNot(contains(id)));
    await waitUntil(
      tester,
      () async => (await stored()).status == OccurrenceStatus.done,
      why: () async =>
          'queue: ${await HomeWidget.getWidgetData<String>('action_queue')}',
    );
    expect((await stored()).durationMin, 45);
  });
}

/// Pumps until [check] holds (the drain runs on the queue's Darwin ping).
Future<void> waitUntil(
  WidgetTester tester,
  Future<bool> Function() check, {
  Duration timeout = const Duration(seconds: 20),
  Future<String> Function()? why,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (await check()) return;
    await tester.pump(const Duration(milliseconds: 300));
  }
  fail('condition not met within $timeout; ${await why?.call()}');
}
