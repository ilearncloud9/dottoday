import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/duplicate_day.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/layout/timeline_day.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The timed tasks of [day] (local date), read once. For one-shot actions;
/// screens watch `timelineDataProvider` instead.
Future<List<Occurrence>> occurrencesOn(
  ProviderContainer ref,
  DateTime day,
) async {
  final profile = await ref.read(currentProfileProvider.future);
  final d = TimelineDay.of(day, tz.getLocation(profile.tzId));
  return ref
      .read(occurrenceRepositoryProvider)
      .watchRange(profile.id, d.startUtc, d.endUtc)
      .first;
}

/// Copies [source]'s one-off tasks onto [target] through the undoable
/// write path ("Copy a day…", `A-ios-future-month`). Returns how many were
/// copied with the undo token, or null when there was nothing to copy.
///
/// Takes the [ProviderContainer] rather than a widget's ref: the empty day
/// that offered "Copy a day…" stops being empty, and unmounts, as soon as
/// the copies land.
Future<Result<({int count, UndoToken token})?, AppFailure>> copyDay(
  ProviderContainer ref, {
  required List<Occurrence> source,
  required DateTime target,
}) async {
  final profile = await ref.read(currentProfileProvider.future);
  final copies = duplicateDay(
    source: source,
    targetDate: target,
    location: tz.getLocation(profile.tzId),
    nowUtc: ref.read(clockProvider).nowUtc(),
    ids: const UuidV7Generator(),
  );
  if (copies.isEmpty) return const Ok(null);
  final result = await ref
      .read(undoServiceProvider)
      .applyUndoable(WriteBatch(userId: profile.id, occurrences: copies));
  return switch (result) {
    Ok(:final value) => Ok((count: copies.length, token: value)),
    Err(:final failure) => Err(failure),
  };
}
