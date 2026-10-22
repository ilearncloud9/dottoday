import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'editing_task.g.dart';

/// The task open in the Mac/web editor panel (docs/10 §4 "editing in a
/// right-hand TaskEditor panel, no sheets", M3e.5); null = closed. Held
/// in core so every screen can open a task without importing the editor.
@Riverpod(keepAlive: true)
class EditingTask extends _$EditingTask {
  @override
  String? build() => null;

  void open(String id) => state = id;

  void close() => state = null;
}

/// Opens task [id] where this width edits it: the panel at the expanded
/// width, else [otherwise] (the phone sheet or the task page).
///
/// ```dart
/// openTask(context, id, otherwise: () => showTaskSheet(context, id));
/// ```
void openTask(
  BuildContext context,
  String id, {
  required VoidCallback otherwise,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (WidthClass.of(width) != WidthClass.expanded) return otherwise();
  ProviderScope.containerOf(
    context,
  ).read(editingTaskProvider.notifier).open(id);
}
