import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routine_providers.g.dart';

/// The user's routines in their order (11 C2, docs/09 M11.4), live. Read
/// by the Routines page and Add › Suggestions.
@riverpod
Stream<List<Routine>> routines(Ref ref) {
  final repo = ref.watch(routineRepositoryProvider);
  return Stream.fromFuture(
    ref.watch(currentProfileProvider.future),
  ).asyncExpand((p) => repo.watchActive(p.id));
}
