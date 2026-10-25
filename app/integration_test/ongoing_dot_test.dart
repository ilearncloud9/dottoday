// The Android ongoing notification on the emulator (docs/09 M9.4): a live
// task posts it; its own +15 action adds 15 and Done removes
// it, both through DotActionReceiver and the queue, so the task in the
// database follows. Notification permission: tool/device_tests.sh grants it. Android only; the killed-app variant is
// tool/ongoing_killed_check.sh.
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
import 'package:integration_test/integration_test.dart';

import 'live_activity_test.dart' show waitUntil;
import 'support/cal_app.dart';

const _channel = MethodChannel('dottoday/ongoing');

Future<String?> _active() => _channel.invokeMethod<String>('activeId');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('posts, +15 once, Done removes it and ticks the task', (
    tester,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final container = await startApp(tester);
    final profile = await container.read(localProfileProvider.future);
    final now = DateTime.now().toUtc();
    final id = const UuidV7Generator().newId();
    await container
        .read(writeUseCaseProvider)
        .apply(
          WriteBatch(
            userId: profile.id,
            occurrences: [
              Occurrence(
                id: id,
                userId: profile.id,
                title: 'Ongoing check',
                tzId: profile.tzId,
                startUtc: now.subtract(const Duration(minutes: 5)),
                durationMin: 30,
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
        );
    await waitUntil(tester, () async => await _active() == id);

    final repo = container.read(occurrenceRepositoryProvider);
    Future<Occurrence> stored() async => (await repo.findById(profile.id, id))!;

    await _channel.invokeMethod<void>('perform', {'action': 'plus'});
    await waitUntil(tester, () async => (await stored()).durationMin == 45);
    // Re-posted with the new end, still on show.
    expect(await _active(), id);

    await _channel.invokeMethod<void>('perform', {'action': 'done'});
    await waitUntil(
      tester,
      () async => (await stored()).status == OccurrenceStatus.done,
    );
    await waitUntil(tester, () async => await _active() == null);
  });
}
