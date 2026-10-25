import 'dart:ui' show Locale;

import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/live_activity/web_live_dot.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'web_live_dot_providers.g.dart';

/// The day snapshot the web sink wrote last, kept in memory with its
/// titles (the stored copy has none, M9.1) for the tab (M9.7).
@Riverpod(keepAlive: true)
class LastDaySnapshot extends _$LastDaySnapshot {
  @override
  DaySnapshot? build() => null;

  // A plain setter for the sink; state is the notifier's own.
  // ignore: use_setters_to_change_properties
  void set(DaySnapshot snapshot) => state = snapshot;
}

/// The tab's title, favicon and badge, moving on every minute (M9.7).
@Riverpod(keepAlive: true)
WebLiveDot webLiveDotState(Ref ref) {
  final now = ref.watch(minuteTickProvider).value;
  final snapshot = ref.watch(lastDaySnapshotProvider);
  final code = ref.watch(currentProfileProvider).value?.locale ?? 'en';
  if (now == null) return WebLiveDot.none;
  final known = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == code,
  );
  final l10n = lookupAppLocalizations(Locale(known ? code : 'en'));
  return webLiveDot(snapshot, now, l10n);
}
