import 'package:dottoday/core/theme/contrast.dart';
import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

part 'task_palette.gen.dart';

/// Alphas of a task colour on the thread (docs/10 §2.1).
abstract final class TaskAlpha {
  /// Segment of an upcoming task: the middle of the spec's 28–35 %.
  static const upcoming = 0.32;

  /// Segment of a done task.
  static const done = 0.45;

  /// Unfilled track of a live dot's ring.
  static const track = 0.25;

  /// Dashes and glyph of a skipped dot (`A-ios-future-month`).
  static const faded = 0.7;

  /// All-day chip and selected-icon backgrounds (`Main`, `A-ios-add-what`),
  /// the same strength as the accent tint.
  static const tintLight = 0.12;
  static const tintDark = 0.22;
}

/// One task colour resolved against one theme.
@immutable
final class TaskSwatch {
  const TaskSwatch({
    required this.color,
    required this.ink,
    required this.tint,
  });

  /// Dot outline, icon, live segment and the filled done dot (§2.1).
  final Color color;

  /// [color] as text on the theme's surfaces and on [tint] (≥ 4.5:1, §7.4).
  final Color ink;

  /// Opaque chip background: [color] at the tint alpha over `raised`.
  final Color tint;

  /// Segment of an upcoming task.
  Color get upcomingSegment => color.withValues(alpha: TaskAlpha.upcoming);

  /// Segment of a done task.
  Color get doneSegment => color.withValues(alpha: TaskAlpha.done);
}

/// The 9 task colours resolved for one [DotColors].
///
/// ```dart
/// final s = DotTheme.of(context).tasks[TaskColor.fromKey(task.colorKey)];
/// Text(task.title, style: TextStyle(color: s.ink));
/// ```
@immutable
final class TaskPalette {
  const TaskPalette._(this._swatches);

  /// Derives [TaskSwatch.ink] and [TaskSwatch.tint] for [colors].
  factory TaskPalette.resolve(DotColors colors) {
    final alpha = colors.isDark ? TaskAlpha.tintDark : TaskAlpha.tintLight;
    return TaskPalette._([
      for (final c in TaskColor.values) _swatch(c.color, colors, alpha),
    ]);
  }

  /// Indexed by [TaskColor.index].
  final List<TaskSwatch> _swatches;

  TaskSwatch operator [](TaskColor color) => _swatches[color.index];

  TaskPalette lerp(TaskPalette other, double t) => TaskPalette._([
    for (final c in TaskColor.values)
      TaskSwatch(
        color: c.color,
        ink: Color.lerp(this[c].ink, other[c].ink, t)!,
        tint: Color.lerp(this[c].tint, other[c].tint, t)!,
      ),
  ]);
}

TaskSwatch _swatch(Color color, DotColors colors, double tintAlpha) {
  final tint = Color.alphaBlend(
    color.withValues(alpha: tintAlpha),
    colors.raised,
  );
  return TaskSwatch(
    color: color,
    ink: inkFor(
      color,
      backgrounds: [colors.surface, colors.raised, tint],
      toward: colors.text,
    ),
    tint: tint,
  );
}
