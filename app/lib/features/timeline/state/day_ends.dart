import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'day_ends.g.dart';

/// Day [date]'s two ends as Today draws them (docs/15 W4, W6): its shape
/// with the *effective* Wind Down (a sleep target pulls it earlier before
/// an early tomorrow) and the next Wake Up, where the night ends.
typedef DayEnds = ({DayShape shape, DateTime nextWakeUtc, bool derived});

@riverpod
Future<DayEnds> dayEnds(Ref ref, DateTime date) async {
  final data = await ref.watch(timelineDataProvider(date).future);
  final next = DateTime(date.year, date.month, date.day + 1);
  final tomorrow = await ref.watch(timelineDataProvider(next).future);
  final location = data.day.location;
  final configured = DayShape.on(
    location,
    date,
    data.settings.boundaryFor(data.day.weekday),
  );
  final shape = effectiveDayShape(
    location,
    date,
    data.settings,
    nowUtc: ref.watch(clockProvider).nowUtc(),
    tomorrowHasThread: tomorrow.blocks.isNotEmpty,
  );
  return (
    shape: shape,
    nextWakeUtc: nextWakeUtc(location, date, data.settings),
    derived: shape.bedUtc != configured.bedUtc,
  );
}
