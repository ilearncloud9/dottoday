import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_selection.g.dart';

/// The tasks picked in multi-select, all on one [day] (docs/03 §3.2,
/// R-05). Empty = not selecting.
typedef Picked = ({DateTime? day, Set<String> ids});

/// Multi-select on the Today screen. Picking on another day starts over
/// there: the bar acts on one day at a time.
@riverpod
class TaskSelection extends _$TaskSelection {
  @override
  Picked build() => (day: null, ids: const {});

  /// Adds or removes [id] on [day]; the last one out ends selecting.
  void toggle(DateTime day, String id) {
    final ids = state.day == day ? {...state.ids} : <String>{};
    if (!ids.remove(id)) ids.add(id);
    state = (day: ids.isEmpty ? null : day, ids: Set.unmodifiable(ids));
  }

  /// Just [id] on [day]: the keyboard's ↑↓ (docs/02 F1.17) moves one
  /// pick along the day instead of adding to it.
  void only(DateTime day, String id) =>
      state = (day: day, ids: Set.unmodifiable({id}));

  void clear() => state = (day: null, ids: const {});
}
