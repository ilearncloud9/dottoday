import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_providers.g.dart';

/// The current user's live inbox (docs/02 F3): open and completed items
/// with no start, in `sortOrder`. Shared by the Inbox tab and Today's
/// "Pull from inbox · 5". Dependencies are read synchronously (see
/// `timelineData`).
@riverpod
Stream<List<Occurrence>> inboxItems(Ref ref) {
  final profile = ref.watch(currentProfileProvider.future);
  final repo = ref.watch(occurrenceRepositoryProvider);
  return Stream.fromFuture(
    profile,
  ).asyncExpand((profile) => repo.watchInbox(profile.id));
}
