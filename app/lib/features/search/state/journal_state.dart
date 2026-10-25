import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/review/journal.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'journal_state.g.dart';

/// The thread journal's days (11 D3, docs/09 M12.3) with what drawing
/// them needs.
@immutable
final class JournalData {
  const JournalData({
    required this.today,
    required this.zone,
    required this.days,
    required this.use24h,
  });

  final DateTime today;
  final tz.Location zone;

  /// Past days with something planned, newest first.
  final List<JournalDay> days;
  final bool? use24h;
}

/// Past days over the last twelve months, live from the local tasks
/// (derived on read: no table, no migration; owner, 2026-10-25).
/// Dependencies are read synchronously (see `timelineData`).
@riverpod
Stream<JournalData> pastDays(Ref ref) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(occurrenceRepositoryProvider);
  final now = ref.watch(clockProvider).nowUtc();
  return Stream.fromFuture(profile).asyncExpand((p) {
    final zone = tz.getLocation(p.tzId);
    final local = tz.TZDateTime.from(now, zone);
    final today = DateTime(local.year, local.month, local.day);
    final first = journalStart(today);
    return repo
        .watchRange(
          p.id,
          tz.TZDateTime(zone, first.year, first.month).toUtc(),
          tz.TZDateTime(zone, today.year, today.month, today.day).toUtc(),
        )
        .map(
          (rows) => JournalData(
            today: today,
            zone: zone,
            days: journalDays(
              rows,
              zone: zone,
              settings: p.settings,
              today: today,
            ),
            use24h: p.settings.use24h,
          ),
        );
  });
}
