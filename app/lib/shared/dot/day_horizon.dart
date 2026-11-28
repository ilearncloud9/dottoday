import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/horizon_dot.dart';
import 'package:dottoday/shared/dot/horizon_labels.dart';
import 'package:dottoday/shared/dot/horizon_painter.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

export 'package:dottoday/shared/dot/horizon_dot.dart';

/// Minimal's horizon (E rules §3 "Horizon", §5.3; ED-241): the thread
/// laid flat from Wake Up to Wind Down, 3 px. Behind now it is solid, in
/// each task's colour where a task ran; ahead it is dotted. Each task is
/// a 14 px dot cut out of the line by the ground; the caps are plain
/// discs; the teal now-bead sits at now. Labels under it: Wake Up, now
/// (bold, teal), the middle hour and Wind Down. A tap is [onTap] (Today,
/// on phones). A right-click on a dot is [onDotMenu] with that dot's
/// index (the Mac and web pane, E-Minimal frame 1).
///
/// Keyboard and screen readers (ED-248 A, E-DF3): with [onOpen] it is one
/// stop that holds one dot: ←/→ and Home/End move along the dots with
/// the 2 px focus ring (ED-178), Return or Space opens that dot's task.
/// For screen readers it is one adjustable element, [label] with the
/// dot's [dotLabels] as its value, swiped up or down, with an Open
/// action; its own activation stays [onTap] where there is one.
class DayHorizon extends StatefulWidget {
  const DayHorizon({
    required this.dots,
    required this.wakeUtc,
    required this.windDownUtc,
    required this.nowUtc,
    required this.labels,
    required this.label,
    this.dotLabels = const [],
    this.hint,
    this.onTap,
    this.onDotMenu,
    this.onOpen,
    super.key,
  }) : assert(dotLabels.length == 0 || dotLabels.length == dots.length);

  final List<HorizonDot> dots;
  final DateTime wakeUtc;
  final DateTime windDownUtc;
  final DateTime nowUtc;

  /// Wake Up, now, the middle hour and Wind Down, as shown: "7 AM",
  /// "10:42", "3 PM", "11 PM"; the middle one's time is [labels].mid.
  final HorizonLabels labels;
  final String label;

  /// Each dot as said: "Lunch, 12:30 – 1:15 PM".
  final List<String> dotLabels;
  final String? hint;
  final VoidCallback? onTap;
  final void Function(int index, Offset global)? onDotMenu;

  /// Opens the task of the dot at this index (Return, Space, Open).
  final void Function(int index)? onOpen;

  @override
  State<DayHorizon> createState() => _DayHorizonState();
}

/// A leaf: which dot the keyboard or a screen reader is on, and whether
/// the horizon has focus (for the ring).
class _DayHorizonState extends State<DayHorizon> {
  int? _picked;
  bool _focused = false;

  /// The dot under way, else the next one, else the last: where the
  /// person most likely wants to start.
  int get _at {
    final dots = widget.dots;
    if (_picked case final i? when i < dots.length) return i;
    final ahead = dots.indexWhere(
      (d) => d.state == DotState.live || d.state == DotState.upcoming,
    );
    return ahead >= 0 ? ahead : dots.length - 1;
  }

  void _go(int i) =>
      setState(() => _picked = i.clamp(0, widget.dots.length - 1));

  KeyEventResult _key(FocusNode _, KeyEvent e) {
    if (e is KeyUpEvent || widget.dots.isEmpty) return KeyEventResult.ignored;
    final k = e.logicalKey;
    final last = widget.dots.length - 1;
    if (k == LogicalKeyboardKey.arrowRight) {
      _go(_at + 1);
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      _go(_at - 1);
    } else if (k == LogicalKeyboardKey.home) {
      _go(0);
    } else if (k == LogicalKeyboardKey.end) {
      _go(last);
    } else if (k == LogicalKeyboardKey.enter ||
        k == LogicalKeyboardKey.numpadEnter ||
        k == LogicalKeyboardKey.space) {
      if (e is KeyDownEvent) widget.onOpen?.call(_at);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final open = w.onOpen;
    final said = w.dotLabels;
    final at = _at;
    final has = said.isNotEmpty && at >= 0;
    final semantics = Semantics(
      button: w.onTap != null,
      label: w.label,
      hint: w.hint,
      value: has ? said[at] : null,
      increasedValue: has && at < said.length - 1 ? said[at + 1] : null,
      decreasedValue: has && at > 0 ? said[at - 1] : null,
      onIncrease: has && at < said.length - 1 ? () => _go(at + 1) : null,
      onDecrease: has && at > 0 ? () => _go(at - 1) : null,
      customSemanticsActions: {
        if (has && open != null)
          CustomSemanticsAction(label: context.l10n.nowDotOpen): () => open(at),
      },
      excludeSemantics: true,
      onTap: w.onTap ?? (has && open != null ? () => open(at) : null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: w.onTap,
        child: _line(context, ring: _focused && has ? at : null),
      ),
    );
    if (open == null) return semantics;
    return Focus(
      onKeyEvent: _key,
      onFocusChange: (f) => setState(() => _focused = f),
      includeSemantics: false,
      child: semantics,
    );
  }

  Widget _line(BuildContext context, {int? ring}) {
    final t = DotTheme.of(context);
    final w = widget;
    return SizedBox(
      height: DotSize.horizonHeight,
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth;
          final at = HorizonScale(w.wakeUtc, w.windDownUtc, width);
          // The dot under a right-click, within its own width.
          int? hit(double x) {
            int? best;
            var gap = DotSize.horizonDot.toDouble();
            for (final (i, d) in w.dots.indexed) {
              final g = (at.x(d.startUtc) - x).abs();
              if (g <= gap) (best, gap) = (i, g);
            }
            return best;
          }

          final style = t.styles.threadMeta.copyWith(color: t.colors.secondary);
          final menu = w.onDotMenu;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onSecondaryTapUp: menu == null
                ? null
                : (e) {
                    if (hit(e.localPosition.dx) case final i?) {
                      menu(i, e.globalPosition);
                    }
                  },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: HorizonPainter(
                      dots: w.dots,
                      at: at,
                      nowUtc: w.nowUtc,
                      colors: t.colors,
                      tasks: t.tasks,
                      ring: ring,
                    ),
                  ),
                ),
                ...horizonLabels(
                  t,
                  w.labels,
                  nowX: at.x(w.nowUtc),
                  midX: at.x(w.labels.midUtc),
                  width: width,
                  style: style,
                  scaler: MediaQuery.textScalerOf(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
