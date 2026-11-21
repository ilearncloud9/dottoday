import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_models.dart';
import 'package:flutter/widgets.dart';

/// The day thread's sizes for its width. Phones (compact, owner
/// 2026-11-21, ED-419): 52 dots (50 done) and caps, rows as long as their
/// task (main's) and the now card holding a 52 dot; the column, gap, knot
/// and wider windows keep Concept E's (§5.1–5.4).
@immutable
final class ThreadScale {
  const ThreadScale._({
    required this.dot,
    required this.doneDot,
    required this.cap,
    required this.liveDot,
    required this.byLength,
  });

  /// Concept E's thread: fixed rows by state and the now card.
  static const wide = ThreadScale._(
    dot: DotSize.threadDot,
    doneDot: DotSize.threadDoneDot,
    cap: DotSize.threadCap,
    liveDot: DotSize.liveDot,
    byLength: false,
  );

  /// The phones' thread: larger dots, rows by length (ADR-0015).
  static const phone = ThreadScale._(
    dot: DotSize.phoneThreadDot,
    doneDot: DotSize.phoneThreadDoneDot,
    cap: DotSize.phoneThreadDot,
    liveDot: DotSize.phoneThreadDot,
    byLength: true,
  );

  final double dot;
  final double doneDot;
  final double cap;

  /// The live task's dot on the now card.
  final double liveDot;

  /// Whether rows grow with their task's length (main) rather than keep
  /// a height by state. The live task is the now card either way.
  final bool byLength;

  /// Least height of [task]'s row; the now card sets its own.
  ///
  /// ```dart
  /// ThreadScale.phone.rowHeight(task); // 30 min: 88; 90 min: 144
  /// ThreadScale.wide.rowHeight(task);  // done 48, else 54
  /// ```
  double rowHeight(ThreadTask task) {
    if (task.state == DotState.live) return DotSize.nowCard;
    if (byLength) {
      return (task.minutes * DotSize.threadPerMinute).clamp(
        DotSize.threadRowMin,
        DotSize.threadRowMax,
      );
    }
    return task.state == DotState.done
        ? DotSize.threadRowDone
        : DotSize.threadRowAhead;
  }

  /// The scale a [ThreadScope] above gives, else [wide].
  static ThreadScale of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThreadScope>()?.scale ?? wide;

  /// The scale for a thread drawn here: [phone] at compact width.
  static ThreadScale forWidth(BuildContext context) =>
      AppLayout.classOf(context) == WidthClass.compact ? phone : wide;
}

/// Gives the rows under it their [ThreadScale].
class ThreadScope extends InheritedWidget {
  const ThreadScope({required this.scale, required super.child, super.key});

  final ThreadScale scale;

  @override
  bool updateShouldNotify(ThreadScope old) => old.scale != scale;
}
