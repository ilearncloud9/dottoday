import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/schedule/month_data.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The colours of what is planned on each day of [month] (up to three a
/// day, skipped ones left out), live: the change-day picker's dots
/// (docs/10 §5.3 "Change day picker", docs/09 M3f.4). Read straight from
/// the repository so a sheet can listen without a provider's lifetime.
Stream<Map<DateTime, List<TaskColor>>> plannedColors(
  ProviderContainer ref,
  DateTime month,
) async* {
  final profile = await ref.read(currentProfileProvider.future);
  final zone = tz.getLocation(profile.tzId);
  const midnight = ClockTime(0, 0);
  yield* ref
      .read(occurrenceRepositoryProvider)
      .watchRange(
        profile.id,
        midnight.onDate(zone, DateTime(month.year, month.month)),
        midnight.onDate(zone, DateTime(month.year, month.month + 1)),
      )
      .map(
        (rows) => {
          for (final MapEntry(key: day, value: list) in bucketByLocalDay(
            rows,
            zone,
          ).entries)
            day: [
              for (final o in list.take(3))
                if (o.status != OccurrenceStatus.skipped)
                  TaskColor.fromKey(o.colorKey),
            ],
        },
      );
}
