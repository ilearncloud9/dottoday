import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_selection.g.dart';

/// The Inbox items picked for the selection bar (docs/09 M3f.9c; the
/// Today one is per day, this one is the Inbox's). Empty = not selecting.
@riverpod
class InboxSelection extends _$InboxSelection {
  @override
  Set<String> build() => const {};

  /// Adds or removes [id]; the last one out ends selecting.
  void toggle(String id) {
    final ids = {...state};
    if (!ids.remove(id)) ids.add(id);
    state = Set.unmodifiable(ids);
  }

  void clear() => state = const {};
}
