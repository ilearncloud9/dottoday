import 'package:flutter/widgets.dart';

/// Room kept at the day's foot for what floats over it there (Day ▾ on a
/// phone in portrait), so the reality insight sits above it (E-R2-23 §4)
/// while the thread itself scrolls as before.
class DayFootInset extends InheritedWidget {
  const DayFootInset({required this.extra, required super.child, super.key});

  /// Logical pixels above the system's and the shell's insets.
  final double extra;

  /// [extra] where a [DayFootInset] is above [context]; else 0.
  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DayFootInset>()?.extra ?? 0;

  @override
  bool updateShouldNotify(DayFootInset old) => old.extra != extra;
}
