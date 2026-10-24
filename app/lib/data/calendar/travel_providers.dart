import 'package:dottoday/data/daos/calendar_links_dao.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'travel_providers.g.dart';

/// Where the imported event linked by [linkId] happens (docs/09 M7.5,
/// R-17), as its calendar gave it at the last import; null without a
/// place or once the link is gone. Read on this device only.
@riverpod
Stream<String?> calendarEventLocation(Ref ref, String linkId) async* {
  final profile = await ref.watch(currentProfileProvider.future);
  yield* CalendarLinksDao(ref.watch(appDatabaseProvider))
      .linkWithAccount(profile.id, linkId)
      .watchSingleOrNull()
      .map((row) => row?.$1.location)
      .distinct();
}
