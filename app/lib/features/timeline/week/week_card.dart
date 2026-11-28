import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/week/grid_block_lines.dart';
import 'package:dottoday/features/timeline/week/grid_scale.dart';
import 'package:dottoday/features/timeline/week/week_pieces.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
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
    this.over = false,
    this.picked = false,
    this.selected = false,
    this.overlaps = const [],
    this.onOpen,
    this.onCue,
    this.onMove,
    this.onDone,
    this.focusNode,
    super.key,
  });

  final ThreadTask task;
  final double height;

  /// Sharing its column with an overlapping task.
  final bool narrow;

  /// The copy under the pointer while it is dragged: the soft lift.
  final bool lifted;

  /// Stacked over an earlier overlap at touch sizes (E-R2-2): raised.
  final bool over;

  /// In the Workspace inspector: the 2 px ink edge (E-FullA-v2).
  final bool picked;

  /// Picked in multi-select (E-R2-6): the accent edge and the check.
  final bool selected;

  /// The tasks whose times cross this one's: "overlaps Run" (ED-248 B).
  final List<String> overlaps;
  final VoidCallback? onOpen;

  /// The cue tapped: Smallest step's Start or Unstick's question.
  final VoidCallback? onCue;

  /// Moves the task by [steps] snap steps and [days] days: Alt+arrows on
  /// a focused block, and the screen reader's move actions.
  final void Function({int steps, int days})? onMove;

  /// The done circle at the block's end, at touch sizes (E-R2-5, ED-276):
  /// done, or reopened when it is done, with Undo. Null: no circle.
  final VoidCallback? onDone;

  /// The block's focus, from [GridFocusTarget] so the arrow keys reach it.
  final FocusNode? focusNode;

  @override
  State<WeekCard> createState() => _WeekCardState();
}

/// A leaf: the pointer's hover and the keyboard's focus.
class _WeekCardState extends State<WeekCard> {
  bool _hover = false;
  bool _focused = false;

  ThreadTask get _task => widget.task;
  GridScale get _scale => GridScale.of(context);
  bool get _pill => _task.minutes < _scale.pillUnder;

  /// Tall enough for the cue under the title and time (an hour).
  double get _cueRoom => _scale.hour - DotSpace.s;

  /// The done circle: tasks only (not calendar events), tall enough for
  /// its touch target, not on the dragged copy, and not in a narrow
  /// overlap lane, where it would leave the title no room (done there by
  /// the docked editor).
  VoidCallback? get _circle =>
      _task.imported ||
          widget.lifted ||
          widget.narrow ||
          widget.height < DotTouch.android
      ? null
      : widget.onDone;

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
      _pill ? _scale.pillRadius(widget.height) : DotRadii.block,
    );
    final hover = _hover && _eligible;
    // High contrast never leans on the fill or the shadow (ED-116).
    final edge = widget.selected
        ? c.accentFill
        : widget.picked
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
              width: widget.selected
                  ? DotSize.gridPickEdge
                  : widget.picked
                  ? DotSpace.xxs
                  : DotSpace.hairline,
            ),
    );
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _tapTarget(l10n, shape)),
              if (_circle case final done?)
                DoneCircle(
                  color: _task.color,
                  done: _task.state == DotState.done,
                  live: _task.state == DotState.live,
                  title: _task.title,
                  onTap: done,
                ),
            ],
          ),
        ),
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
    if (widget.lifted || widget.over) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: widget.lifted
              ? DotElevation.blockLift(c)
              : DotElevation.blockOver(c),
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
      child: _focused
          ? gridFocusRing(c, radius, card)
          : widget.selected
          ? Stack(children: [card, const GridPickBadge()])
          : card,
    );
  }

  /// The block's own target: opens on a click or Return, tints on hover,
  /// rings on keyboard focus, and Alt+arrows move it.
  Widget _tapTarget(AppLocalizations l10n, ShapeBorder shape) {
    final move = widget.onMove;
    final tap = InkWell(
      onTap: widget.onOpen,
      focusNode: widget.focusNode,
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
      selected: widget.picked || widget.selected,
      label: switch (widget.overlaps) {
        [] => taskRowLabel(l10n, _task),
        [final first, ...final rest] => l10n.rowOverlaps(
          taskRowLabel(l10n, _task),
          first,
          rest.length,
        ),
      },
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
}

/// The cue a grid block carries for [task], if any: "Just Gather
/// documents · 10 min?" or "What's the very first thing you'd physically
/// do?".
String? weekCardCue(AppLocalizations l10n, ThreadTask task) =>
    task.smallestStep ?? (task.unstick ? l10n.unstickPrompt : null);
