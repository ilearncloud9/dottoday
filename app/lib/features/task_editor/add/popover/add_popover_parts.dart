import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The popover's title box (E-R2-36): the dot, which opens Colour and
/// icon (owner, M19.3 part 3b), beside the title field, outlined in the
/// accent while it has the keys.
class PopoverTitleBox extends StatelessWidget {
  const PopoverTitleBox({
    required this.color,
    required this.icon,
    required this.title,
    required this.onLook,
    required this.field,
    super.key,
  });

  final TaskColor color;
  final TaskIcon icon;
  final String title;

  /// The dot was tapped; it is at this rectangle (the popover's anchor).
  final ValueChanged<Rect?> onLook;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.card,
        borderRadius: BorderRadius.circular(DotRadii.popoverCard),
        border: Border.all(
          color: t.colors.focus,
          width: DotSize.popoverFieldStroke,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          DotSpace.s,
          DotSpace.s,
          DotSpace.m,
          DotSpace.s,
        ),
        child: Row(
          spacing: DotSpace.s,
          children: [
            Tooltip(
              message: l10n.colourIconTitle,
              child: Builder(
                builder: (dot) => Semantics(
                  button: true,
                  label: l10n.colourIconTitle,
                  excludeSemantics: true,
                  onTap: () => onLook(globalRectOf(dot)),
                  child: InkResponse(
                    onTap: () => onLook(globalRectOf(dot)),
                    radius: DotTouch.min / 2,
                    child: SizedBox.square(
                      dimension: DotTouch.min,
                      child: Center(
                        child: TaskDot(
                          color: color,
                          icon: icon,
                          state: DotState.upcoming,
                          label: title,
                          size: DotSize.popoverRing,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: field),
          ],
        ),
      ),
    );
  }
}

/// A quiet card: the summary line over its free / overlap caption.
class PopoverCard extends StatelessWidget {
  const PopoverCard({required this.title, required this.caption, super.key});

  final String title;
  final Widget caption;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.sunk,
        borderRadius: BorderRadius.circular(DotRadii.popoverCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.xs,
          children: [
            Text(
              title,
              style: t.styles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            caption,
          ],
        ),
      ),
    );
  }
}

/// "Duration" and its pills ("15 min" … "2 h") and ⋯ for any length: 26
/// tall for a pointer, 44 for touch.
class PopoverLengths extends ConsumerWidget {
  const PopoverLengths({
    required this.value,
    required this.presets,
    required this.onPick,
    required this.onMore,
    super.key,
  });

  final int value;
  final List<int> presets;
  final ValueChanged<int> onPick;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final height = watchTouchContent(context, ref)
        ? DotTouch.min
        : DotSize.popoverPill;
    // "Duration" leads the pills and wraps with them (more presets than
    // the board's five, or large text).
    return Wrap(
      spacing: DotSpace.xs + DotSpace.xxs,
      runSpacing: DotSpace.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: DotSpace.xs),
          child: Text(
            l10n.addDurationCaption,
            style: t.styles.viewTab.copyWith(color: t.colors.secondary),
          ),
        ),
        for (final m in presets)
          _Pill(
            label: formatDurationShort(l10n, m),
            selected: m == value,
            height: height,
            onTap: () => onPick(m),
          ),
        IconButton(
          tooltip: l10n.addMoreDuration,
          onPressed: onMore,
          constraints: BoxConstraints.tight(Size.square(height)),
          padding: EdgeInsets.zero,
          icon: DotIcon(
            DotGlyphs.more,
            color: t.colors.accentText,
            size: DotSize.sidebarGlyph,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.height,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final shape = StadiumBorder(
      side: selected ? BorderSide.none : BorderSide(color: t.colors.hairline),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? t.colors.accentFill : t.colors.card,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height, minWidth: height),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DotSpace.s + DotSpace.xxs,
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: t.styles.viewTab.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected ? t.colors.onAccent : t.colors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Add to Inbox instead and Add ↵ (Return adds, as the key cap says):
/// 30 tall for a pointer, as the Workspace's controls; touch keeps 44.
class PopoverFooter extends ConsumerWidget {
  const PopoverFooter({required this.onInbox, required this.onAdd, super.key});

  final VoidCallback? onInbox;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final pointer = !watchTouchContent(context, ref);
    final small = Size(0, pointer ? DotSize.workspaceControl : DotTouch.min);
    final label = t.styles.rowMeta.copyWith(fontWeight: FontWeight.w700);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: DotSpace.s,
      children: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: small, textStyle: label),
          onPressed: onInbox,
          child: Text(l10n.addToInbox),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: small, textStyle: label),
          onPressed: onAdd,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.s,
            children: [
              Text(l10n.addAdd),
              ExcludeSemantics(
                child: Text(
                  '↵', // l10n-ignore: the Return key cap
                  style: label.copyWith(color: t.colors.onAccent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
