import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';

/// The series template one day's [subtasks] make: titles in their order
/// (docs/09 M3f.3, R-09). Deleted ones are left out.
List<SubtaskTemplateItem> templateOf(List<Subtask> subtasks, IdGenerator ids) {
  final live = subtasks.where((s) => s.deletedAt == null).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return [
    for (final (i, s) in live.indexed)
      SubtaskTemplateItem(id: ids.newId(), title: s.title, sortOrder: i + 1),
  ];
}

/// "Use this list every time": the subtask rows that give each later
/// planned day in [days] the [template] (R-09). A day where something is
/// already ticked keeps its own list — completion is per day and never
/// overwritten; the rest have their list soft-deleted and rebuilt fresh
/// (unticked) from the template.
///
/// ```dart
/// applyTemplate(template: t, days: {tomorrow: [old]}, nowUtc: now, ids: ids)
///     .length; // 1 deleted + t.length new
/// ```
List<Subtask> applyTemplate({
  required List<SubtaskTemplateItem> template,
  required Map<Occurrence, List<Subtask>> days,
  required DateTime nowUtc,
  required IdGenerator ids,
}) => [
  for (final MapEntry(key: o, value: subtasks) in days.entries)
    if (!subtasks.any((s) => s.done && s.deletedAt == null)) ...[
      for (final s in subtasks)
        if (s.deletedAt == null)
          s.copyWith(deletedAt: nowUtc, updatedAt: nowUtc),
      for (final item in template)
        Subtask(
          id: ids.newId(),
          userId: o.userId,
          occurrenceId: o.id,
          title: item.title,
          sortOrder: item.sortOrder,
          createdAt: nowUtc,
          updatedAt: nowUtc,
        ),
    ],
];
