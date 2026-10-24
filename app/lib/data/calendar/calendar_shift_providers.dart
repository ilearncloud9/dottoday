import 'package:dottoday/data/daos/calendar_links_dao.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_shift_providers.g.dart';

/// Imported events a shift never carries, even with "Move calendar events
/// too" on (docs/03 §3.2, docs/09 M7.6): their calendar won't take the
/// change back (read-only calendar, repeating or all-day event), so moving
/// them in bulk would leave Dottoday disagreeing with the real meeting.
///
/// Read synchronously and returns the stream (see `timelineData`).
@Riverpod(keepAlive: true)
Stream<Set<String>> readOnlyCalendarIds(Ref ref) {
  final profile = ref.watch(currentProfileProvider.future);
  final dao = CalendarLinksDao(ref.watch(appDatabaseProvider));
  return Stream.fromFuture(profile).asyncExpand(
    (p) => dao.readOnlyImportIds(p.id).watch().map((ids) => ids.toSet()),
  );
}
