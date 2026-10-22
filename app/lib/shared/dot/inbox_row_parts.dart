part of 'inbox_row.dart';

/// "+" (schedule), or the pick check while selecting; then the reorder
/// handle.
class _Trailing extends StatelessWidget {
  const _Trailing({required this.row});

  final InboxRow row;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final l10n = context.l10n;
    final picked = row.selected;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (picked != null)
          SizedBox.square(
            dimension: DotTouch.android,
            child: Center(child: _PickCheck(picked: picked)),
          )
        else
          IconButton.filledTonal(
            tooltip: l10n.inboxSchedule,
            onPressed: row.onSchedule,
            style: IconButton.styleFrom(
              backgroundColor: c.accentTint,
              minimumSize: const Size.square(DotTouch.android),
            ),
            icon: DotIcon(DotGlyphs.add, color: c.accentInk),
          ),
        if (row.reorderIndex case final index? when picked == null)
          ReorderableDragStartListener(
            index: index,
            child: Semantics(
              // Its own node: the row's label stays the row's.
              container: true,
              label: l10n.subtaskReorder(row.title),
              excludeSemantics: true,
              child: SizedBox.square(
                dimension: DotTouch.android,
                child: Center(
                  child: DotIcon(DotGlyphs.dragHandle, color: c.muted),
                ),
              ),
            ),
          ),
      ],
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

/// Length and title (title first on Mac/web); the row carries the label.
class _Texts extends StatelessWidget {
  const _Texts({required this.row});

  final InboxRow row;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final meta = Text(row.meta, style: t.styles.rowMeta);
    final title = Text(row.title, style: t.styles.rowTitle);
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: row.titleFirst ? [title, meta] : [meta, title],
      ),
    );
  }
}
