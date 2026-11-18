import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/shortcuts/single_keys.dart';
import 'package:dottoday/core/theme/dot_idiom.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/selection_actions.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/selection_commands.dart';
import 'package:dottoday/features/timeline/widgets/task_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step the keyboard pick [by] tasks along the day (↑ −1, ↓ +1).
final class StepTaskIntent extends Intent {
  const StepTaskIntent(this.by);

  final int by;
}

/// Move the picked tasks [minutes] later (earlier when negative).
final class NudgeTaskIntent extends Intent {
  const NudgeTaskIntent(this.minutes);

  final int minutes;
}

/// Open the one picked task.
final class OpenTaskIntent extends Intent {
  const OpenTaskIntent();
}

/// Drop the pick (Esc), wherever focus is on Today.
final class ClearPickIntent extends Intent {
  const ClearPickIntent();
}

/// Mark the one picked task done (or not done again).
final class DoneTaskIntent extends Intent {
  const DoneTaskIntent();
}

/// Move To… for the picked tasks (⇧⌘M, ED-095): the selection bar's Move.
final class MoveTaskIntent extends Intent {
  const MoveTaskIntent();
}

/// Focus on the one picked task (⇧⌘F, web f, ED-095).
final class FocusTaskIntent extends Intent {
  const FocusTaskIntent();
}

/// The task keys on Today (docs/02 F1.17): ↑↓ pick the previous or next
/// task of [day], ⌘/Ctrl+↑↓ move the picked tasks 5 min (Shift: 15),
/// Delete or ⌫ move them to Trash, ↩ opens and Space completes the one
/// picked, Esc drops the pick. The pick is the multi-select model (R-05),
/// so the selection bar shows and its commands apply. Keys that have nothing to act on stay with the
/// focused control (a row's ↩ still opens it).
class TaskKeys extends ConsumerWidget {
  const TaskKeys({
    required this.day,
    required this.today,
    required this.child,
    super.key,
  });

  final DateTime day;

  /// The local date today, for Move To…'s calendar.
  final DateTime today;
  final Widget child;

  static const _step = 5;
  static const _bigStep = 15;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = defaultTargetPlatform;
    const up = LogicalKeyboardKey.arrowUp;
    const down = LogicalKeyboardKey.arrowDown;
    final k = _Keys(context, ref, day);
    final singleKeys = SingleKeysOn.of(context);
    final web = webChrome(context);
    return Shortcuts(
      shortcuts: {
        // ⌘D marks the picked task done (ED-095); the web leaves ⌘D to the
        // browser's bookmark and uses Space.
        if (!web)
          AppShortcuts.activator(p, LogicalKeyboardKey.keyD):
              const DoneTaskIntent(),
        // Not on the web: the browser's own (ED-095 lists no web key).
        if (!web)
          AppShortcuts.activator(p, LogicalKeyboardKey.keyM, shift: true):
              const MoveTaskIntent(),
        if (!web)
          AppShortcuts.activator(p, LogicalKeyboardKey.keyF, shift: true):
              const FocusTaskIntent(),
        if (web)
          const SingleActivator(LogicalKeyboardKey.keyF):
              const FocusTaskIntent(),
        const SingleActivator(up): const StepTaskIntent(-1),
        const SingleActivator(down): const StepTaskIntent(1),
        AppShortcuts.activator(p, up): const NudgeTaskIntent(-_step),
        AppShortcuts.activator(p, down): const NudgeTaskIntent(_step),
        AppShortcuts.activator(p, up, shift: true): const NudgeTaskIntent(
          -_bigStep,
        ),
        AppShortcuts.activator(p, down, shift: true): const NudgeTaskIntent(
          _bigStep,
        ),
        const SingleActivator(LogicalKeyboardKey.delete):
            const TrashTaskIntent(),
        const SingleActivator(LogicalKeyboardKey.backspace):
            const TrashTaskIntent(),
        // Move to Trash ⌘⌫, as the Mac menus show it (ED-162).
        AppShortcuts.activator(p, LogicalKeyboardKey.backspace):
            const TrashTaskIntent(),
        const SingleActivator(LogicalKeyboardKey.enter): const OpenTaskIntent(),
        const SingleActivator(LogicalKeyboardKey.space): const DoneTaskIntent(),
        const SingleActivator(LogicalKeyboardKey.escape):
            const ClearPickIntent(),
      },
      child: Actions(
        actions: {
          StepTaskIntent: _KeyAction<StepTaskIntent>(
            () => k.tasks.isNotEmpty,
            (i) => k.step(i.by),
          ),
          NudgeTaskIntent: _KeyAction<NudgeTaskIntent>(
            () => k.picked.isNotEmpty,
            (i) => unawaited(k.nudge(i.minutes)),
          ),
          TrashTaskIntent: _KeyAction<TrashTaskIntent>(
            () => k.picked.isNotEmpty,
            (_) => unawaited(k.trash()),
          ),
          OpenTaskIntent: _KeyAction<OpenTaskIntent>(
            () => k.picked.length == 1,
            (_) => k.open(),
          ),
          DoneTaskIntent: _KeyAction<DoneTaskIntent>(
            () => k.picked.length == 1,
            (_) => unawaited(k.done()),
          ),
          MoveTaskIntent: _KeyAction<MoveTaskIntent>(
            () => k.picked.isNotEmpty,
            (_) => k.move(today),
          ),
          FocusTaskIntent: _KeyAction<FocusTaskIntent>(
            // The web's f is a single key: off with the setting (ED-095).
            () => k.picked.length == 1 && (!web || singleKeys),
            (_) => k.focus(),
          ),
          ClearPickIntent: _KeyAction<ClearPickIntent>(
            () => k.picked.isNotEmpty,
            (_) => ref.read(taskSelectionProvider.notifier).clear(),
          ),
        },
        child: child,
      ),
    );
  }
}

/// An action that is off (so the key passes on) when [enabled] says so,
/// or while a text field has focus (M8.6b: ⌫ and Space are typing there).
final class _KeyAction<T extends Intent> extends Action<T> {
  _KeyAction(this.enabled, this.run);

  final bool Function() enabled;
  final void Function(T intent) run;

  @override
  bool isEnabled(T intent) => focusedTextField() == null && enabled();

  @override
  Object? invoke(T intent) {
    run(intent);
    return null;
  }
}

/// What the keys do, read fresh at each press.
final class _Keys {
  _Keys(this.context, this.ref, this.day);

  final BuildContext context;
  final WidgetRef ref;
  final DateTime day;

  TimelineData? get _data => ref.read(timelineDataProvider(day)).value;

  /// The day's tasks in thread order (start time).
  List<Occurrence> get tasks => [
    for (final o in _data?.blocks ?? const <Occurrence>[])
      if (o.startUtc != null) o,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));

  /// The picked tasks of this day, in thread order.
  List<Occurrence> get picked {
    final p = ref.read(taskSelectionProvider);
    if (p.day != day) return const [];
    return [
      for (final o in tasks)
        if (p.ids.contains(o.id)) o,
    ];
  }

  void step(int by) {
    final all = tasks;
    final now = picked;
    // Nothing picked: ↓ starts at the top, ↑ at the bottom.
    var at = by > 0 ? 0 : all.length - 1;
    if (now.isNotEmpty) {
      final edge = by > 0 ? now.last : now.first;
      at = (all.indexWhere((o) => o.id == edge.id) + by).clamp(
        0,
        all.length - 1,
      );
    }
    ref.read(taskSelectionProvider.notifier).only(day, all[at].id);
  }

  Future<void> nudge(int minutes) async {
    final rows = picked;
    final write = nudgeAll(ProviderScope.containerOf(context), rows, minutes);
    if (write == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(undoServiceProvider);
    final one = rows.length == 1 ? rows.single : null;
    final at = one == null ? null : _time(one, minutes);
    reportUndoable(
      messenger,
      l10n,
      undo,
      await write,
      message: (_) => one == null || one.pinned
          ? l10n.snackShifted(rows.where((o) => !o.pinned).length)
          : l10n.snackMoved(one.title, at!),
      tokenOf: (t) => t,
    );
  }

  /// [o]'s new start after [minutes], as the thread writes it.
  String _time(Occurrence o, int minutes) {
    final data = _data!;
    return timeOfUtc(
      context,
      data.day.location,
      o.startUtc!.add(Duration(minutes: minutes)),
      use24h: use24hFor(context, data.settings.use24h),
    );
  }

  Future<void> trash() async {
    final rows = picked;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(undoServiceProvider);
    final container = ProviderScope.containerOf(context);
    container.read(taskSelectionProvider.notifier).clear();
    reportUndoable(
      messenger,
      l10n,
      undo,
      await trashAll(container, rows),
      message: (_) => rows.length == 1
          ? l10n.snackTrashed(rows.single.title)
          : l10n.snackManyDeleted(rows.length),
      tokenOf: (t) => t,
    );
  }

  /// The selection bar's Move To…, on the picked tasks.
  void move(DateTime today) => SelectionCommands(
    context: context,
    container: ProviderScope.containerOf(context),
    rows: picked,
    today: today,
    day: day,
  ).move?.call();

  void focus() {
    final id = picked.single.id;
    ref.read(taskSelectionProvider.notifier).clear();
    openFocus(context, id);
  }

  void open() {
    final id = picked.single.id;
    ref.read(taskSelectionProvider.notifier).clear();
    openTask(context, id, otherwise: () => showTaskSheet(context, id));
  }

  Future<void> done() async {
    final o = picked.single;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(undoServiceProvider);
    final wasDone = o.status == OccurrenceStatus.done;
    reportUndoable(
      messenger,
      l10n,
      undo,
      await toggleDone(ref, o),
      message: (_) =>
          wasDone ? l10n.snackNotDone(o.title) : l10n.snackDone(o.title),
      tokenOf: (t) => t,
    );
  }
}
