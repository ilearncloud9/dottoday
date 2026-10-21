import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'month_data.g.dart';

/// Timed tasks of [month] (year/month) bucketed by local start date in the
/// profile zone, for the month dots (docs/10 §3 `MonthGrid`). One range
/// query per month instead of one per day. Dependencies are read
/// synchronously (see `timelineData`).
@riverpod
Stream<Map<DateTime, List<Occurrence>>> monthOccurrences(
  Ref ref,
  DateTime month,
) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(occurrenceRepositoryProvider);
  return Stream.fromFuture(profile).asyncExpand((profile) {
    final zone = tz.getLocation(profile.tzId);
    const midnight = ClockTime(0, 0);
    final from = midnight.onDate(zone, DateTime(month.year, month.month));
    final to = midnight.onDate(zone, DateTime(month.year, month.month + 1));
    return repo
        .watchRange(profile.id, from, to)
        .map((all) => bucketByLocalDay(all, zone));
  });
}

/// Live inbox items (docs/02 F3), e.g. for "Pull from inbox · 5".
@riverpod
Stream<List<Occurrence>> inboxItems(Ref ref) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(occurrenceRepositoryProvider);
  return Stream.fromFuture(
    profile,
  ).asyncExpand((profile) => repo.watchInbox(profile.id));
}

/// [rows] grouped by the local calendar date of their start in [zone].
Map<DateTime, List<Occurrence>> bucketByLocalDay(
  List<Occurrence> rows,
  tz.Location zone,
) {
  final out = <DateTime, List<Occurrence>>{};
  for (final o in rows) {
    final start = o.startUtc;
    if (start == null) continue;
    final local = tz.TZDateTime.from(start, zone);
    (out[DateTime(local.year, local.month, local.day)] ??= []).add(o);
  }
  return out;
}
