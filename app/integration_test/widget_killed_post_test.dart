// Phase 1 of "Done from a widget ticks the task with the app killed"
// (docs/09 M9.5; tool/widget_killed_check.sh): writes one live task, lets
// the snapshot follow, prints the task's id and its planned end, ends.
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('writes the live dot', (tester) async {
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
                title: 'Widget killed check',
                tzId: profile.tzId,
                startUtc: now.subtract(const Duration(minutes: 5)),
                durationMin: 30,
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
        );
    await container.read(afterWriteEffectsProvider).idle;
    debugPrint('WIDGET_KILLED id=$id');
  });
}
