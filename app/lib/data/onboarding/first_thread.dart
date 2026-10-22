import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'first_thread.g.dart';

/// Tomorrow as onboarding left it (O6, docs/09 M4.6).
typedef FirstThread = ({
  DateTime date,
  DayShape shape,
  tz.Location zone,
  bool? use24h,
  List<Occurrence> rows,
});

/// Tomorrow's tasks with its Wake Up and Bedtime, live.
@riverpod
Stream<FirstThread> firstThread(Ref ref) async* {
  final profile = await ref.watch(currentProfileProvider.future);
  final zone = tz.getLocation(profile.tzId);
  final local = tz.TZDateTime.from(ref.read(clockProvider).nowUtc(), zone);
  final date = DateTime(local.year, local.month, local.day + 1);
  final shape = DayShape.on(
    zone,
    date,
    profile.settings.boundaryFor(Weekday.values[date.weekday - 1]),
  );
  const midnight = ClockTime(0, 0);
  yield* ref
      .watch(occurrenceRepositoryProvider)
      .watchRange(
        profile.id,
        midnight.onDate(zone, date),
        midnight.onDate(zone, DateTime(date.year, date.month, date.day + 1)),
      )
      .map(
        (rows) => (
          date: date,
          shape: shape,
          zone: zone,
          use24h: profile.settings.use24h,
          rows: rows,
        ),
      );
}
