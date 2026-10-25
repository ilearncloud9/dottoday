import 'dart:ui' show Locale;

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/intents/action_queue_drainer.dart';
import 'package:dottoday/data/intents/native_action_queue_store.dart';
import 'package:dottoday/data/intents/no_action_queue_store.dart';
import 'package:dottoday/data/intents/web_action_queue_store.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/snapshot/web_snapshot_sink.dart';
import 'package:dottoday/data/widgets/home_widget_sink.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/intents/action_queue_store.dart';
import 'package:dottoday/domain/intents/dot_intents.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'intent_providers.g.dart';

/// The five B6 intents (docs/09 M9.2).
@Riverpod(keepAlive: true)
DotIntents dotIntents(Ref ref) => DotIntents(
  clock: ref.watch(clockProvider),
  writes: ref.watch(writeUseCaseProvider),
  occurrences: ref.watch(occurrenceRepositoryProvider),
  series: ref.watch(seriesRepositoryProvider),
  profile: () => latestProfile(ref),
  snapshot: () async =>
      ref.read(daySnapshotWriterProvider).write((await latestProfile(ref)).id),
  untitled: (language) => _l10n(language).inboxUntitled,
);

/// Where this platform's surfaces queue actions (docs/09 M9.2).
@Riverpod(keepAlive: true)
ActionQueueStore actionQueueStore(Ref ref) {
  if (HomeWidgetSink.supported) return const NativeActionQueueStore();
  if (WebSnapshotSink.supported) return const WebActionQueueStore();
  return const NoActionQueueStore();
}

@Riverpod(keepAlive: true)
ActionQueueDrainer actionQueueDrainer(Ref ref) => ActionQueueDrainer(
  store: ref.watch(actionQueueStoreProvider),
  intents: ref.watch(dotIntentsProvider),
  logger: ref.watch(loggerProvider),
  now: ref.watch(clockProvider).nowUtc,
  // Start focus from a control, tile or Siri opens Focus (M10.5).
  onFocus: (id) => ref.read(focusRequestProvider.notifier).request(id),
);

AppLocalizations _l10n(String code) {
  final known = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == code,
  );
  return lookupAppLocalizations(Locale(known ? code : 'en'));
}
