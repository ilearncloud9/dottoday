import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/week/grid_block_lines.dart';
import 'package:dottoday/features/timeline/week/week_pieces.dart';
import 'package:dottoday/shared/dot/task_row.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// A task on the hour grid (E-FullA-v2 Week, M19.2 part 2): a card as tall
/// as its time with its ring on the column's thread, the title and the
/// time. A task under half an hour is a one-line pill; a block narrowed by
/// an overlap keeps a small ring and its title. Done titles go quiet; a
/// calendar event is sunk with a dashed edge.
///
/// Hover and drag (ED-116, G3-5 option C): flat at rest; a pointer hover
/// tints it with a hairline edge; the dragged copy lifts ([lifted]); the
/// keyboard's focus gets the teal ring and Alt+arrows move it ([onMove]);
/// high contrast keeps a visible edge. Calendar events take none of it.
///
/// A task Smallest step or Unstick asks about (M10.6, M10.7) shows that
/// cue as the card's last line, its own tap target ([onCue]); a card too
/// short for it keeps the cue as a screen-reader action.
class WeekCard extends StatefulWidget {
  const WeekCard({
    required this.task,
    required this.height,
    this.narrow = false,
    this.lifted = false,
    this.picked = false,
    this.onOpen,
    this.onCue,
    this.onMove,
    super.key,
  });

  final ThreadTask task;
  final double height;

  /// Sharing its column with an overlapping task.
  final bool narrow;

  /// The copy under the pointer while it is dragged: the soft lift.
  final bool lifted;

  /// In the Workspace inspector: the 2 px ink edge (E-FullA-v2).
  final bool picked;
  final VoidCallback? onOpen;

  /// The cue tapped: Smallest step's Start or Unstick's question.
  final VoidCallback? onCue;

  /// Moves the task by [steps] snap steps and [days] days: Alt+arrows on
  /// a focused block, and the screen reader's move actions.
  final void Function({int steps, int days})? onMove;

  @override
  State<WeekCard> createState() => _WeekCardState();
}

/// A leaf: the pointer's hover and the keyboard's focus.
class _WeekCardState extends State<WeekCard> {
  bool _hover = false;
  bool _focused = false;

  /// Tall enough for the cue under the title and time (an hour).
  static const double _cueRoom = DotSize.gridHour - DotSpace.s;

  ThreadTask get _task => widget.task;
  bool get _pill => _task.minutes < WeekScale.pillUnder;

  /// Blocks that drag (ED-116); calendar events stay as they are.
  bool get _eligible => _task.movable && !_task.imported;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final l10n = context.l10n;
    final cue = widget.onCue == null ? null : weekCardCue(l10n, _task);
    final cueLine =
        cue != null && !_pill && !widget.narrow && widget.height >= _cueRoom;
    final radius = BorderRadius.circular(
      _pill ? DotSize.gridPill / 2 : DotRadii.block,
    );
    final hover = _hover && _eligible;
    // High contrast never leans on the fill or the shadow (ED-116).
    final edge = widget.picked
        ? c.text
        : MediaQuery.highContrastOf(context)
        ? c.secondary
        : hover || widget.lifted
        ? c.blockEdge
        : null;
    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: edge == null
          ? BorderSide.none
          : BorderSide(
              color: edge,
              width: widget.picked ? DotSpace.xxs : DotSpace.hairline,
            ),
    );
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _tapTarget(l10n, shape)),
        if (cueLine) GridCueLine(text: cue, onTap: widget.onCue!),
      ],
    );
    Widget card = Material(
      color: _task.imported || hover ? c.sunk : c.card,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: _task.imported
          ? CustomPaint(
              foregroundPainter: DashedPillPainter(
                color: c.hairlineStrong,
                radius: _pill ? null : DotRadii.block,
              ),
              child: body,
            )
          : body,
    );
    if (widget.lifted) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: DotElevation.blockLift(c),
        ),
        child: card,
      );
    }
    return Semantics(
      container: true,
      customSemanticsActions: {
        if (cue != null && !cueLine)
          CustomSemanticsAction(label: cue): widget.onCue!,
        ..._moveActions(l10n),
      },
      child: _focused ? _ring(c, radius, card) : card,
    );
  }

  /// The block's own target: opens on a click or Return, tints on hover,
  /// rings on keyboard focus, and Alt+arrows move it.
  Widget _tapTarget(AppLocalizations l10n, ShapeBorder shape) {
    final move = widget.onMove;
    final tap = InkWell(
      onTap: widget.onOpen,
      customBorder: shape,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onHover: (on) => setState(() => _hover = on),
      onFocusChange: (on) => setState(
        () => _focused =
            on &&
            FocusManager.instance.highlightMode ==
                FocusHighlightMode.traditional,
      ),
      child: GridBlockLines(task: _task, pill: _pill, narrow: widget.narrow),
    );
    return Semantics(
      button: widget.onOpen != null,
      selected: widget.picked,
      label: taskRowLabel(l10n, _task),
      excludeSemantics: true,
      child: move == null || !_eligible
          ? tap
          : CallbackShortcuts(
              bindings: {
                const SingleActivator(
                  LogicalKeyboardKey.arrowUp,
                  alt: true,
                ): () =>
                    move(steps: -1),
                const SingleActivator(
                  LogicalKeyboardKey.arrowDown,
                  alt: true,
                ): () =>
                    move(steps: 1),
                const SingleActivator(
                  LogicalKeyboardKey.arrowLeft,
                  alt: true,
                ): () =>
                    move(days: -1),
                const SingleActivator(
                  LogicalKeyboardKey.arrowRight,
                  alt: true,
                ): () =>
                    move(days: 1),
              },
              child: tap,
            ),
    );
  }

  Map<CustomSemanticsAction, VoidCallback> _moveActions(AppLocalizations l10n) {
    final move = widget.onMove;
    if (move == null || !_eligible) return const {};
    return {
      CustomSemanticsAction(label: l10n.gridMoveEarlier): () => move(steps: -1),
      CustomSemanticsAction(label: l10n.gridMoveLater): () => move(steps: 1),
      CustomSemanticsAction(label: l10n.gridMoveDayBefore): () =>
          move(days: -1),
      CustomSemanticsAction(label: l10n.gridMoveDayAfter): () => move(days: 1),
    };
  }

  /// The focus ring (ED-211): 2 px in the focus colour after a 2 px gap
  /// in the grid's colour, outside the block.
  Widget _ring(DotColors c, BorderRadius radius, Widget card) {
    const w = DotSize.smallDotOutline;
    BoxDecoration ring(Color color, double out) => BoxDecoration(
      borderRadius: radius.add(BorderRadius.circular(out)),
      border: Border.all(color: color, width: w),
    );
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        card,
        Positioned.fill(
          left: -w * 2,
          top: -w * 2,
          right: -w * 2,
          bottom: -w * 2,
          child: IgnorePointer(
            child: DecoratedBox(decoration: ring(c.focus, w * 2)),
          ),
        ),
        Positioned.fill(
          left: -w,
          top: -w,
          right: -w,
          bottom: -w,
          child: IgnorePointer(
            child: DecoratedBox(decoration: ring(c.canvas, w)),
          ),
        ),
      ],
    );
  }
}

/// The cue a grid block carries for [task], if any: "Just Gather
/// documents · 10 min?" or "What's the very first thing you'd physically
/// do?".
String? weekCardCue(AppLocalizations l10n, ThreadTask task) =>
    task.smallestStep ?? (task.unstick ? l10n.unstickPrompt : null);
