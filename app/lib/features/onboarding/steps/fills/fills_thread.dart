import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_geometry.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_layout.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_row_dot.dart';
import 'package:dottoday/features/onboarding/steps/fills/fills_thread_paint.dart';
import 'package:dottoday/features/onboarding/steps/nudge/nudge_drop.dart';
import 'package:flutter/material.dart';

/// One row on the thread: Wake Up, a pick, or Wind Down.
typedef FillRow = ({
  FillRowKind kind,
  int minute,
  String title,
  String sub,
  Color color,
  DotGlyph? glyph,
  String? id,
});

/// What fills your days' thread (prototype `threadHTML`): Wake Up, the
/// picks ("Most days") and Wind Down at their times, the thread with its
/// part gone by, and NOW. [rows] are in time order. While [flying] is
/// set its row is hidden; [landing]'s dot pops in on [land] (or its row
/// fades in, with Reduce Motion). At large text the time column widens
/// and the rows spread with the words ([FillsGeometry]).
class FillsThread extends StatelessWidget {
  const FillsThread({
    required this.rows,
    required this.wake,
    required this.wind,
    required this.now,
    required this.nowLabel,
    required this.time,
    required this.dotKeys,
    required this.land,
    this.flying,
    this.landing,
    this.drop,
    super.key,
  });

  final List<FillRow> rows;
  final int wake;
  final int wind;
  final int now;
  final String nowLabel;
  final String Function(int minute) time;

  /// Each pick's dot, for the flight to land on.
  final Map<String, GlobalKey> dotKeys;
  final Animation<double> land;
  final String? flying;
  final String? landing;

  /// The nudge: the subject's row drops onto its time on this (0–1).
  final Animation<double>? drop;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return LayoutBuilder(
      builder: (context, box) {
        final g = FillsGeometry.of(
          context,
          times: [for (final r in rows) time(r.minute)],
        );
        final at = layoutFillThread(
          [for (final r in rows) (kind: r.kind, minute: r.minute)],
          wake: wake,
          wind: wind,
          now: now,
          height: box.maxHeight,
          scale: g.scale,
          room: g.large
              ? [
                  for (final r in rows)
                    g.room(
                      context,
                      (r.title, r.sub),
                      r.kind,
                      width: box.maxWidth,
                    ),
                ]
              : null,
        );
        final words = [
          for (final (i, r) in rows.indexed)
            g.words(
              context,
              (r.title, r.sub),
              r.kind,
              at.ys[i],
              compact: at.compact,
              width: box.maxWidth,
            ),
        ];
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: FillsThreadLine(
                  x: g.thread,
                  top: at.top,
                  bottom: at.bottom,
                  now: at.now,
                  line: OnbSky.of(
                    t.colors.isDark ? Brightness.dark : Brightness.light,
                  ).line,
                  past: t.colors.accent,
                  rtl: rtl,
                ),
              ),
            ),
            for (final (i, r) in rows.indexed)
              ..._row(
                t,
                g,
                r,
                at.ys[i],
                shrunk: at.compact,
                width: box.maxWidth,
              ),
            // NOW over the dots (`.nowm` z-index 2), under its pill.
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: FillsNowLine(
                    from: g.nowLine,
                    now: at.now,
                    color: t.tasks[TaskColor.coral].ring,
                    cuts: [
                      for (final w in words)
                        if (w.top <= at.now && at.now <= w.bottom) w,
                    ],
                    rtl: rtl,
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              end: 0,
              top: at.now,
              child: FractionalTranslation(
                translation: const Offset(0, -0.5),
                child: _NowPill(label: nowLabel),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _row(
    DotTheme t,
    FillsGeometry g,
    FillRow r,
    double y, {
    required bool shrunk,
    required double width,
  }) {
    // The subject is never shrunk (`kf<1&&it.k!=='task'`).
    final compact = shrunk && r.kind != FillRowKind.task;

    final (title, sub) = fillRowStyles(t, r.kind, compact: compact);
    final task = r.kind == FillRowKind.task;
    final pick = r.kind == FillRowKind.pick;
    final size = task
        ? OnbSize.taskDot
        : pick
        ? (compact ? OnbSize.pickDotSmall : OnbSize.pickDot)
        : (compact ? OnbSize.anchorDotSmall : OnbSize.anchorDot);
    final id = r.id;
    final drop = this.drop;
    Widget hide(Widget child) {
      if (task && drop != null) {
        return NudgeDrop(progress: drop, child: child);
      }
      if (id == null) return child;
      if (id == flying) return Opacity(opacity: 0, child: child);
      if (id == landing && t.motion.isReduced) {
        return FadeTransition(opacity: land, child: child);
      }
      return child;
    }

    return [
      PositionedDirectional(
        end: width - g.timeEnd,
        top: y - OnbSize.rowTimeTop * g.scale,
        child: hide(
          ExcludeSemantics(
            child: Text(time(r.minute), style: t.styles.onbRowTime),
          ),
        ),
      ),
      PositionedDirectional(
        start: g.thread - size / 2,
        top: y - size / 2,
        width: size,
        height: size,
        child: hide(
          FillsRowDot(
            key: id == null ? null : dotKeys[id],
            color: r.color,
            glyph: r.glyph,
            iconSize: pick && compact ? OnbSize.rowIconSmall : OnbSize.rowIcon,
            filled: task,
            pop: id != null && id == landing && !t.motion.isReduced
                ? land
                : null,
          ),
        ),
      ),
      PositionedDirectional(
        start: g.wordsStart,
        end: 0,
        top: y - g.wordsTop(r.kind, compact: compact),
        child: hide(
          Semantics(
            label:
                '${time(r.minute)}, ${r.title}${compact ? '' : ', ${r.sub}'}', // l10n-ignore: joins read-out parts
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // One line, cut with … as the prototype does; at large
                // text the words wrap instead (nothing cut at 200 %).
                Text(
                  r.title,
                  style: title,
                  maxLines: g.large ? null : 1,
                  overflow: g.large ? null : TextOverflow.ellipsis,
                ),
                if (!compact)
                  Text(
                    r.sub,
                    style: sub,
                    maxLines: g.large ? null : 1,
                    overflow: g.large ? null : TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

/// NOW on its coral pill (`.nowm span`): 22 high, or taller with the text.
class _NowPill extends StatelessWidget {
  const _NowPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ExcludeSemantics(
      child: Container(
        constraints: const BoxConstraints(minHeight: OnbSize.nowPill),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: OnbSize.nowPillPad),
        decoration: BoxDecoration(
          color: t.tasks[TaskColor.coral].ring,
          borderRadius: BorderRadius.circular(OnbSize.nowPill),
        ),
        child: Text(
          label,
          style: t.styles.onbNowPill.copyWith(color: OnbSky.nowInk),
        ),
      ),
    );
  }
}
