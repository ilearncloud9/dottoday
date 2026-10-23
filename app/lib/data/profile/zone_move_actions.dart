import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:dottoday/domain/time/zone_move.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'zone_move_actions.g.dart';

/// The zone the device moved to, when it isn't the one the person plans
/// in (docs/07 travelling, docs/09 M5.9): what the banner offers. Null
/// when they match, while either is loading, or for a zone the tz
/// database doesn't know.
@riverpod
String? zoneMoveOffer(Ref ref) {
  final device = ref.watch(currentDeviceZoneProvider).value;
  final profile = ref.watch(currentProfileProvider).value;
  if (device == null || profile == null || device == profile.tzId) {
    return null;
  }
  try {
    tz.getLocation(device);
    return device;
  } on tz.LocationNotFoundException {
    return null;
  }
}

/// Moves the person to [newZone] by [choice] as one undoable batch.
///
/// Upcoming one-off tasks are read up to [_horizon] ahead; repeats carry
/// their rows themselves.
Future<Result<UndoToken, AppFailure>> moveToZone(
  ProviderContainer ref, {
  required String newZone,
  required ZoneMoveChoice choice,
  IdGenerator ids = const UuidV7Generator(),
}) async {
  final profile = await ref.read(currentProfileProvider.future);
  final now = ref.read(clockProvider).nowUtc();
  final occurrences = ref.read(occurrenceRepositoryProvider);
  final series = choice == ZoneMoveChoice.shift
      ? const <Never>[]
      : await ref.read(seriesRepositoryProvider).watchActive(profile.id).first;
  final batch = planZoneMove(
    profile: profile,
    newZone: newZone,
    choice: choice,
    upcoming: choice == ZoneMoveChoice.shift
        ? const []
        : await occurrences
              .watchRange(profile.id, now, now.add(_horizon))
              .first,
    series: [
      for (final s in series)
        (series: s, rows: await occurrences.findBySeries(profile.id, s.id)),
    ],
    editor: SeriesEditor(clock: ref.read(clockProvider), ids: ids),
    nowUtc: now,
  );
  return ref.read(undoServiceProvider).applyUndoable(batch);
}

/// How far ahead one-off tasks move with "keep times": past any plan a
/// person makes by hand.
const _horizon = Duration(days: 3 * 365);
