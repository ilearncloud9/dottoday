// Android "Share → Dottoday" end to end (docs/09 M12.4;
// tool/share_capture_check.sh): the script sends a real ACTION_SEND to
// MainActivity, whose ShareIntake queues it before Flutter starts; this
// test opens the app, which drains the queue, and finds the Inbox task
// with the shared link kept as its note.
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'live_activity_test.dart' show waitUntil;
import 'support/cal_app.dart';

const _title = 'Dentist booking';
const _link = 'https://dentist.example/book';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a shared link is an Inbox task with its source', (
    tester,
  ) async {
    final container = await startApp(tester);
    final profile = await container.read(localProfileProvider.future);
    final repo = container.read(occurrenceRepositoryProvider);
    await waitUntil(tester, () async {
      final inbox = await repo.watchInbox(profile.id).first;
      return inbox.any((o) => o.title == _title && o.notes == '$_title $_link');
    });
    debugPrint('SHARE_CAPTURE ok');
  });
}
