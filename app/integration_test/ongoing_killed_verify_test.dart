// Phase 2 (tool/ongoing_killed_check.sh, docs/09 M9.4): Done was tapped on
// the ongoing notification while the app was killed; opening the app
// drains the queue, so the task is done.
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'live_activity_test.dart' show waitUntil;
import 'support/cal_app.dart';

const _id = String.fromEnvironment('ONGOING_KILLED_ID');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the task Done was tapped on is done', (tester) async {
    expect(_id, isNotEmpty);
    final container = await startApp(tester);
    final profile = await container.read(localProfileProvider.future);
    final repo = container.read(occurrenceRepositoryProvider);
    await waitUntil(
      tester,
      () async =>
          (await repo.findById(profile.id, _id))?.status ==
          OccurrenceStatus.done,
    );
  });
}
