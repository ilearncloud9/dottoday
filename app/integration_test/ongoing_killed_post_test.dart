// Phase 1 of "the ongoing notification's Done works with the app killed"
// (docs/09 M9.4; driven by tool/ongoing_killed_check.sh): writes one live
// task, waits until its ongoing notification shows, prints its id, ends.
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'live_activity_test.dart' show waitUntil;
import 'support/cal_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('posts the live dot', (tester) async {
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
                title: 'Ongoing killed check',
                tzId: profile.tzId,
                startUtc: now.subtract(const Duration(minutes: 5)),
                durationMin: 30,
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
        );
    const channel = MethodChannel('dottoday/ongoing');
    await waitUntil(
      tester,
      () async => await channel.invokeMethod<String>('activeId') == id,
    );
    debugPrint('ONGOING_KILLED id=$id');
  });
}
