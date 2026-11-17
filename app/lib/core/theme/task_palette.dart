import 'package:dottoday/core/theme/contrast.dart';
import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/tokens.dart';
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

  /// The current thread under a proposal (11 §0 B3: "ghost segments at
  /// 35 % alpha"; `B-ios-rebalance`).
  static const ghost = 0.35;

  /// The now-bead's outer ring, the now pill's border and the now line
  /// (Concept E §5.3).
  static const nowHalo = 0.4;
  static const nowPill = 0.3;
  static const nowLine = 0.28;

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
    required this.ring,
    required this.ink,
    required this.tint,
    required this.glyph,
    required this.check,
  });

  /// Dot outline, icon, live segment and the filled done dot (§2.1).
  final Color color;

  /// Concept E's ahead ring and the icon inside it (ED-155; in dark the
  /// fill itself, ED-175). Done fills, thread and knots keep [color].
  final Color ring;

  /// [color] as text on the theme's surfaces and on [tint] (≥ 4.5:1, §7.4).
  final Color ink;

  /// Opaque chip background: [color] at the tint alpha over `raised`;
  /// also the fill of every task dot (ADR-0015).
  final Color tint;

  /// [color] as a dot's icon on [tint]: the spec hue, deepened (light) or
  /// lifted (dark) only as far as 3:1 for graphics needs (§7.4, ADR-0015).
  final Color glyph;

  /// The tick on a filled done circle and the icon on a done dot (E rules
  /// §4.4): white in light, the ground's ink in dark, and ink on amber in
  /// both themes (CR-162, ED-196).
  final Color check;

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
      for (final c in TaskColor.values)
        _swatch(
          colors.isDark ? c.dark : c.color,
          colors.isDark ? c.dark : c.ring,
          colors,
          alpha,
          check: colors.isDark
              ? colors.ground
              : c == TaskColor.amber
              ? colors.ink
              : DotPrimitives.white,
        ),
    ]);
  }

  /// Indexed by [TaskColor.index].
  final List<TaskSwatch> _swatches;

  TaskSwatch operator [](TaskColor color) => _swatches[color.index];

  TaskPalette lerp(TaskPalette other, double t) => TaskPalette._([
    for (final c in TaskColor.values)
      TaskSwatch(
        color: Color.lerp(this[c].color, other[c].color, t)!,
        ring: Color.lerp(this[c].ring, other[c].ring, t)!,
        ink: Color.lerp(this[c].ink, other[c].ink, t)!,
        tint: Color.lerp(this[c].tint, other[c].tint, t)!,
        glyph: Color.lerp(this[c].glyph, other[c].glyph, t)!,
        check: Color.lerp(this[c].check, other[c].check, t)!,
      ),
  ]);
}

TaskSwatch _swatch(
  Color color,
  Color ring,
  DotColors colors,
  double tintAlpha, {
  required Color check,
}) {
  final tint = Color.alphaBlend(
    color.withValues(alpha: tintAlpha),
    colors.raised,
  );
  return TaskSwatch(
    color: color,
    ring: ring,
    check: check,
    ink: inkFor(
      color,
      backgrounds: [colors.surface, colors.raised, tint],
      toward: colors.text,
    ),
    tint: tint,
    glyph: inkFor(
      color,
      backgrounds: [tint],
      toward: colors.text,
      minRatio: glyphContrastTarget,
    ),
  );
}

/// What [TaskSwatch.glyph] aims for: WCAG's 3:1 for graphics plus the same
/// anti-aliasing margin as [inkContrastTarget].
const double glyphContrastTarget = 3.1;
