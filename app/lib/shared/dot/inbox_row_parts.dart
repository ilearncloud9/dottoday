part of 'inbox_row.dart';

/// Mac and web at the expanded width: the pointer's smaller row.
bool _dense(BuildContext context) =>
    !touchApp(context) && AppLayout.classOf(context) == WidthClass.expanded;

/// The card. A touch hold released without moving opens the menu, so the
/// menu and a lift (the list's reorder with [InboxRow.reorderIndex], or
/// the wide Inbox's drag onto the day) share the long press; a mouse
/// lifts on a hold and opens the menu on a right-click.
class _Card extends StatefulWidget {
  const _Card({required this.row});

  final InboxRow row;

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  /// Fires once the hold is long enough to lift (the list's own delay).
  Timer? _hold;
  bool _ripe = false;
  Offset? _down;
  double _moved = 0;

  void _onDown(PointerDownEvent e) {
    if (e.buttons != kPrimaryButton || e.kind == PointerDeviceKind.mouse) {
      return;
    }
    _down = e.position;
    _moved = 0;
    _ripe = false;
    _hold?.cancel();
    _hold = Timer(kLongPressTimeout, () => _ripe = true);
  }

  void _onMove(PointerMoveEvent e) {
    if (_down case final d?) {
      final moved = (e.position - d).distance;
      if (moved > _moved) _moved = moved;
    }
  }

  void _onUp(PointerUpEvent e) {
    final down = _down;
    _down = null;
    _hold?.cancel();
    if (!mounted || down == null || !_ripe || _moved > kTouchSlop) return;
    unawaited(widget.row._menu(context, down));
  }

  void _onCancel(PointerCancelEvent e) {
    _down = null;
    _hold?.cancel();
  }

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final index = row.reorderIndex;
    final lifts = index != null && row.selected == null;
    final card = GestureDetector(
      // Screen readers use the row's custom actions instead.
      excludeFromSemantics: true,
      // Without the list's lift, this claims the hold from the tap (a
      // drag onto the day still claims it first); the Listener opens the
      // menu on release.
      onLongPress: lifts ? null : () {},
      onSecondaryTapUp: (d) => unawaited(row._menu(context, d.globalPosition)),
      child: _Face(row: row),
    );
    return Listener(
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onCancel,
      child: lifts
          ? ReorderableDelayedDragStartListener(index: index, child: card)
          : card,
    );
  }
}

/// Dot, texts and Place (or the pick check).
class _Face extends StatelessWidget {
  const _Face({required this.row});

  final InboxRow row;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final dense = _dense(context);
    final picked = row.selected == true;
    return Material(
      color: c.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.card),
        side: BorderSide(
          color: picked ? c.accent : c.threadAhead,
          width: picked ? DotSize.smallDotOutline : DotSpace.hairline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: row.onOpen,
        // The row's container node carries the tap and its label.
        excludeFromSemantics: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: dense ? DotTouch.android : DotSize.inboxRowMin,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              DotSpace.m,
              DotSpace.s,
              DotSpace.s,
              DotSpace.s,
            ),
            child: Row(
              spacing: DotSpace.m,
              children: [
                ExcludeSemantics(
                  child: TaskDot(
                    color: row.color,
                    icon: row.icon,
                    state: DotState.upcoming,
                    label: row.title,
                    oneThing: row.oneThing,
                    size: dense ? DotSize.macRowDot : DotSize.rowDot,
                  ),
                ),
                Expanded(
                  child: _Texts(row: row, dense: dense),
                ),
                _Trailing(row: row, dense: dense),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Place, or the pick check while selecting.
class _Trailing extends StatelessWidget {
  const _Trailing({required this.row, required this.dense});

  final InboxRow row;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    if (row.selected case final picked?) {
      return SizedBox.square(
        dimension: DotTouch.android,
        child: Center(child: _PickCheck(picked: picked)),
      );
    }
    return FilledButton.tonal(
      onPressed: row.onPlace,
      style: FilledButton.styleFrom(
        backgroundColor: c.accentTint,
        foregroundColor: c.accentInk,
        textStyle: t.styles.button,
        padding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
        minimumSize: Size(
          0,
          dense ? DotTouch.pointer + DotSpace.s : DotTouch.android,
        ),
        tapTargetSize: dense
            ? MaterialTapTargetSize.shrinkWrap
            : MaterialTapTargetSize.padded,
      ),
      child: Text(row.placeLabel),
    );
  }
}

/// A filled accent check when picked, an outline when not.
class _PickCheck extends StatelessWidget {
  const _PickCheck({required this.picked});

  final bool picked;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Container(
      width: DotSize.rowIcon + DotSpace.xs,
      height: DotSize.rowIcon + DotSpace.xs,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: picked ? c.accent : null,
        border: Border.all(
          color: picked ? c.accent : c.outline,
          width: DotSize.smallDotOutline,
        ),
      ),
      child: picked
          ? DotIcon(DotGlyphs.check, color: c.onAccent, size: DotSize.rowIcon)
          : null,
    );
  }
}

class _SwipeLabel extends StatelessWidget {
  const _SwipeLabel({
    required this.text,
    required this.color,
    required this.alignment,
  });

  final String text;
  final Color color;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DotRadii.card),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DotSpace.xl),
          child: Text(text, style: t.styles.button),
        ),
      ),
    );
  }
}

/// Title, "30 min · added today" and where it fits; the row carries the
/// label.
class _Texts extends StatelessWidget {
  const _Texts({required this.row, required this.dense});

  final InboxRow row;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final meta = t.styles.rowMeta;
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.title,
            style: dense ? t.styles.cardTitle : t.styles.rowTitle,
          ),
          Text(row.meta, style: meta),
          if (row.fit case final fit?)
            Text(
              fit,
              style: meta.copyWith(
                color: t.colors.accentInk,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
