import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_selection.g.dart';

/// The tasks picked in multi-select, each with its day (docs/03 §3.2,
/// R-05). Empty = not selecting. The thread keeps to one day; the hour
/// grid may pick across its days (E-R2-6, owner M20.5 part 4).
final class Picked {
  const Picked(this.days);

  static const none = Picked({});

  /// Each picked task's id and the day it was picked on.
  final Map<String, DateTime> days;

  Set<String> get ids => days.keys.toSet();

  bool get isEmpty => days.isEmpty;

  /// The one day every pick is on; null when none, or when they span days.
  DateTime? get day {
    final all = days.values.toSet();
    return all.length == 1 ? all.single : null;
  }

  /// Whether the picks are on more than one day.
  bool get spansDays => days.values.toSet().length > 1;

  /// The ids picked on [date].
  Set<String> on(DateTime date) => {
    for (final e in days.entries)
      if (e.value == date) e.key,
  };

  @override
  bool operator ==(Object other) =>
      other is Picked && mapEquals(days, other.days);

  @override
  int get hashCode => Object.hashAllUnordered([
    for (final e in days.entries) Object.hash(e.key, e.value),
  ]);
}

/// Multi-select on Today and the hour grid.
@riverpod
class TaskSelection extends _$TaskSelection {
  @override
  Picked build() {
    // Switching Full ↔ Minimal ends selecting and applies nothing; a batch
    // already confirmed keeps its Undo (ED-100).
    ref.listen(
      layoutPolicyProvider.select((p) => p.isMinimal),
      (_, _) => state = Picked.none,
    );
    return Picked.none;
  }

  /// Adds or removes [id] on [day]; the last one out ends selecting.
  /// The thread's: picking on another day starts over there.
  void toggle(DateTime day, String id) {
    final keep = state.day == day ? state.days : const <String, DateTime>{};
    _toggle(keep, day, id);
  }

  /// Adds or removes [id] on [day], keeping picks on other days: the hour
  /// grid's, where one selection may span its days (E-R2-6).
  void toggleAcross(DateTime day, String id) => _toggle(state.days, day, id);

  void _toggle(Map<String, DateTime> keep, DateTime day, String id) {
    final days = {...keep};
    if (days.remove(id) == null) days[id] = day;
    state = Picked(Map.unmodifiable(days));
  }

  /// Just [id] on [day]: the keyboard's ↑↓ (docs/02 F1.17) moves one
  /// pick along the day instead of adding to it.
  void only(DateTime day, String id) => state = Picked({id: day});

  void clear() => state = Picked.none;
}
