// The daily refresh in the OS background (docs/09 M5.2), Android: a repeat
// whose window has run out is rolled forward by the WorkManager worker in
// its own isolate, with its own database connection. iOS's BGTaskScheduler
// doesn't run on the simulator; that check is on a device (M8.5).
// Run: flutter test integration_test/background_refresh_test.dart
//   -d <android device> --dart-define-from-file=.env
import 'package:dottoday/background_refresh.dart';
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/dev/demo_day_loader.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:workmanager/workmanager.dart';

import 'pass_onboarding.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the background worker rolls a run-out repeat forward', (
    tester,
  ) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await passOnboarding(tester);
    final c = ProviderScope.containerOf(
      tester.element(find.byType(TodayScreen)),
    );
    await c.read(demoDayLoaderProvider).load();
    final db = c.read(appDatabaseProvider);
    final series = await db.select(db.seriesTable).getSingle();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    // As if the last refresh were 90 days ago.
    await (db.update(db.seriesTable)..where((s) => s.id.equals(series.id)))
        .write(SeriesTableCompanion(materialisedThroughUtc: Value(now)));

    await Workmanager().registerOneOffTask(
      'dottoday.refresh.check',
      backgroundRefreshTask,
    );
    const day = 24 * 60 * 60 * 1000;
    int? through;
    final end = DateTime.now().add(const Duration(seconds: 90));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(seconds: 2));
      through =
          (await (db.select(
                db.seriesTable,
              )..where((s) => s.id.equals(series.id))).getSingle())
              .materialisedThroughUtc;
      if (through! > now + 80 * day) break;
    }
    debugPrint('BACKGROUND materialisedThrough +${(through! - now) ~/ day} d');
    expect(through, greaterThan(now + 80 * day));
  });
}
