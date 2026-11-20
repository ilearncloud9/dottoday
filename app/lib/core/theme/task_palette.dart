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

  /// Minimal's orb (E rules §5.3, ED-106): its centre is the task's colour
  /// at 8 % (indigo's `#F1F0FB`), its shadow at 16 %.
  static const orbCentre = 0.08;
  static const orbShadow = 0.16;

  /// Dashes and glyph of a skipped dot (`A-ios-future-month`).
  static const faded = 0.7;

  /// The current thread under a proposal (11 §0 B3: "ghost segments at
  /// 35 % alpha"; `B-ios-rebalance`).
  static const ghost = 0.35;

  /// A proposed dot's dashed ring (E-Phones-2 proposal: the ring colour
  /// at `88` hex).
  static const proposed = 0.53;

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

/// The task colours resolved for one [DotColors]: the named ones up
/// front, a custom one (ED-220) when first drawn.
///
/// ```dart
/// final s = DotTheme.of(context).tasks[TaskColor.fromKey(task.colorKey)];
/// Text(task.title, style: TextStyle(color: s.ink));
/// ```
@immutable
final class TaskPalette {
  const TaskPalette._(this._swatches, this._custom);

  /// Derives [TaskSwatch.ink] and [TaskSwatch.tint] for [colors].
  factory TaskPalette.resolve(DotColors colors) {
    final alpha = colors.isDark ? TaskAlpha.tintDark : TaskAlpha.tintLight;
    TaskSwatch of(TaskColor c) => _swatch(
      colors.isDark ? c.dark : c.color,
      colors.isDark ? c.dark : c.ring,
      colors,
      alpha,
      check: colors.isDark
          ? colors.ground
          : c == TaskColor.amber || (c.isCustom && _pale(c.color))
          ? colors.ink
          : DotPrimitives.white,
    );
    final custom = <TaskColor, TaskSwatch>{};
    return TaskPalette._(
      [for (final c in TaskColor.values) of(c)],
      (c) => custom.length < _customCache
          ? custom.putIfAbsent(c, () => of(c))
          : custom[c] ?? of(c),
    );
  }

  /// Indexed by [TaskColor.index].
  final List<TaskSwatch> _swatches;

  /// A custom colour's swatch, resolved when first drawn.
  final TaskSwatch Function(TaskColor) _custom;

  TaskSwatch operator [](TaskColor color) =>
      color.isCustom ? _custom(color) : _swatches[color.index];

  /// Named colours blend; a custom one takes the nearer theme's.
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
  ], t < 0.5 ? _custom : other._custom);
}

/// How many custom swatches a palette keeps; a day rarely shows more.
const _customCache = 64;

/// Whether white on a custom [color] is under 3:1, so a done dot's tick
/// uses ink, as on amber (CR-162); the named colours keep the boards'.
bool _pale(Color color) =>
    contrastRatio(color, DotPrimitives.white) < glyphContrastTarget;

final _hexKey = RegExp(r'^#[0-9A-Fa-f]{6}$');
final _customs = <String, TaskColor>{};

/// [TaskColor.custom]: [color] made opaque, its key `#RRGGBB`.
TaskColor customTaskColor(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  final key = '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  return _customs[key] ?? _derive(key, Color(0xFF000000 | rgb));
}

/// A `#RRGGBB` [key] as a custom colour; null for anything else.
TaskColor? customTaskColorOf(String? key) {
  if (key == null || !_hexKey.hasMatch(key)) return null;
  return customTaskColor(
    Color(0xFF000000 | int.parse(key.substring(1), radix: 16)),
  );
}

/// The derived shades (ED-161, ED-175): the light ring is [color] deepened
/// to 3:1 on the light ground and cards; the dark fill, also its ring, is
/// [color] lifted to 3.5:1 on every dark surface.
TaskColor _derive(String key, Color color) {
  const l = DotPalette.light;
  const d = DotPalette.dark;
  final c = TaskColor._(
    key,
    color,
    ring: inkFor(
      color,
      backgrounds: [l.ground, l.card],
      toward: l.ink,
      minRatio: 3,
    ),
    dark: inkFor(
      color,
      backgrounds: [d.ground, d.card, d.chip],
      toward: d.ink,
      minRatio: 3.5,
    ),
  );
  if (_customs.length >= _customCache) _customs.clear();
  return _customs[key] = c;
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
