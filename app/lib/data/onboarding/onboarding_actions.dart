import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/onboarding/day_fills.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// "What fills your days?" (M20.11 part 3, ED-485, ED-488): [fills] as
/// tasks that repeat every day from today, in one write (one Undo), on
/// "That's my day". [gone] were saved before (Back, then That's my day
/// again) and are unpicked now: they are taken off. Null when there is
/// nothing to write.
Future<Result<UndoToken, AppFailure>?> plantFills(
  ProviderContainer ref,
  List<DayFill> fills, {
  List<DayFill> gone = const [],
}) async {
  if (fills.isEmpty && gone.isEmpty) return null;
  final profile = await readProfile(ref);
  final zone = tz.getLocation(profile.tzId);
  final now = ref.read(clockProvider).nowUtc();
  final local = tz.TZDateTime.from(now, zone);
  final day = commonWindow(profile.settings);
  List<Series> rows(Iterable<DayFill> f) => fillsSeries(
    f,
    userId: profile.id,
    tzId: profile.tzId,
    day: DateTime(local.year, local.month, local.day),
    wake: windowMinutes(day.start),
    wind: windowMinutes(day.end),
    nowUtc: now,
    alerts: profile.settings.defaultAlerts,
  );
  return ref
      .read(undoServiceProvider)
      .applyUndoable(
        WriteBatch(
          userId: profile.id,
          series: [
            ...rows(fills),
            for (final s in rows(gone))
              s.copyWith(deletedAt: now, updatedAt: now),
          ],
        ),
      );
}
