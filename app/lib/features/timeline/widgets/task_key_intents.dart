import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:flutter/widgets.dart';

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

/// An action that is off (so the key passes on) when [enabled] says so,
/// or while a text field has focus (M8.6b: ⌫ and Space are typing there).
final class TaskKeyAction<T extends Intent> extends Action<T> {
  TaskKeyAction(this.enabled, this.run);

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
