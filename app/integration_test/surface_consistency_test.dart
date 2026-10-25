// The consistency gate on a device (docs/09 M9.8): Done, +15 and a rename,
// and within 1 s the widgets' snapshot (App Group / home_widget prefs, as
// Swift and Kotlin read it) and the live surface (iOS Live Activity,
// Android ongoing notification) show the same dot. iOS and Android.
import 'dart:convert';

import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/widgets/home_widget_sink.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/intents/dot_action.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget/home_widget.dart';
import 'package:integration_test/integration_test.dart';

import 'support/cal_app.dart';

typedef Shown = ({String id, String title, int endMs})?;

/// The live dot in the widgets' stored snapshot (the native rule).
Future<Shown> widgets() async {
  await HomeWidget.setAppGroupId(HomeWidgetSink.appGroupId);
  final raw = await HomeWidget.getWidgetData<String>(HomeWidgetSink.dataKey);
  if (raw == null) return null;
  final json = jsonDecode(raw) as Map<String, Object?>;
  final ms = DateTime.now().millisecondsSinceEpoch;
  for (final b in (json['blocks']! as List).cast<Map<String, Object?>>()) {
    final live = (b['start_ms']! as int) <= ms && ms < (b['end_ms']! as int);
    if (b['done'] != true && live) {
      return (
        id: b['id']! as String,
        title: b['title']! as String,
        endMs: b['end_ms']! as int,
      );
    }
  }
  return null;
}

/// The Live Activity (iOS) or the ongoing notification (Android).
Future<Shown> liveSurface() async {
  final Map<String, Object?>? content;
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final states = await const MethodChannel(
      'dottoday/live_activity',
    ).invokeListMethod<String>('activeStates');
    content = (states == null || states.isEmpty)
        ? null
        : jsonDecode(states.first) as Map<String, Object?>;
  } else {
    final raw = await const MethodChannel(
      'dottoday/ongoing',
    ).invokeMethod<String>('activeContent');
    content = raw == null ? null : jsonDecode(raw) as Map<String, Object?>;
  }
  if (content == null || content['live'] != true) return null;
  return (
    id: content['id']! as String,
    title: content['title']! as String,
    endMs: (content['end_ms']! as num).toInt(),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every surface shows the same dot within 1 s', (tester) async {
    final container = await startApp(tester);
    final profile = await container.read(localProfileProvider.future);
    final writes = container.read(writeUseCaseProvider);
    final intents = container.read(dotIntentsProvider);
    final now = DateTime.now().toUtc();
    final task = Occurrence(
      id: const UuidV7Generator().newId(),
      userId: profile.id,
      title: 'Consistency check',
      tzId: profile.tzId,
      startUtc: now.subtract(const Duration(minutes: 5)),
      durationMin: 30,
      createdAt: now,
      updatedAt: now,
    );
    final end = task.endUtc!.millisecondsSinceEpoch;

    Future<void> expectAll(Shown expected, String step) async {
      final watch = Stopwatch()..start();
      var shown = (await widgets(), await liveSurface());
      while (shown != (expected, expected) &&
          watch.elapsedMilliseconds < 1000) {
        await tester.pump(const Duration(milliseconds: 50));
        shown = (await widgets(), await liveSurface());
      }
      debugPrint('CONSISTENCY $step ${watch.elapsedMilliseconds} ms');
      expect(shown.$1, expected, reason: '$step: widgets');
      expect(shown.$2, expected, reason: '$step: live surface');
    }

    await writes.apply(WriteBatch(userId: profile.id, occurrences: [task]));
    await expectAll((id: task.id, title: task.title, endMs: end), 'write');

    await writes.apply(
      WriteBatch(
        userId: profile.id,
        occurrences: [task.copyWith(title: 'Renamed check')],
      ),
    );
    await expectAll((
      id: task.id,
      title: 'Renamed check',
      endMs: end,
    ), 'rename');

    await intents.run(AddFifteen(task.id, plannedEndUtc: task.endUtc!));
    await expectAll((
      id: task.id,
      title: 'Renamed check',
      endMs: end + 15 * 60000,
    ), '+15');

    await intents.run(MarkDone(task.id));
    await expectAll(null, 'done');
  });
}
