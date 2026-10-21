import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// An unscheduled task (docs/10 §3 `InboxRow`, `A-ios-inbox`): outlined
/// dot, length, title and a round "+" that schedules it. Swipe toward the
/// start schedules, toward the end trashes; screen readers get both as
/// actions, and a long-press or right-click opens the same choices, so
/// nothing needs a swipe (R-12).
class InboxRow extends StatelessWidget {
  const InboxRow({
    required this.title,
    required this.meta,
    required this.color,
    required this.icon,
    required this.onSchedule,
    required this.onTrash,
    this.onOpen,
    super.key,
  });

  final String title;

  /// "60 min".
  final String meta;
  final TaskColor color;
  final TaskIcon icon;
  final VoidCallback onSchedule;
  final VoidCallback onTrash;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = DotTheme.of(context);
    return Semantics(
      container: true,
      button: onOpen != null,
      label: l10n.inboxRowLabel(title, meta),
      onTap: onOpen,
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.inboxSchedule): onSchedule,
        CustomSemanticsAction(label: l10n.inboxTrash): onTrash,
      },
      child: Dismissible(
        key: ValueKey(title.hashCode ^ meta.hashCode ^ identityHashCode(this)),
        // The row leaves when the write lands, not on the swipe itself.
        confirmDismiss: (direction) async {
          unawaited(HapticFeedback.mediumImpact());
          direction == DismissDirection.endToStart ? onSchedule() : onTrash();
          return false;
        },
        background: _SwipeLabel(
          text: l10n.inboxTrash,
          // Coral, the palette's warm colour, marks the destructive side.
          color: t.tasks[TaskColor.coral].tint,
          alignment: AlignmentDirectional.centerStart,
        ),
        secondaryBackground: _SwipeLabel(
          text: l10n.inboxSchedule,
          color: t.colors.accentTint,
          alignment: AlignmentDirectional.centerEnd,
        ),
        child: _Card(row: this),
      ),
    );
  }

  Future<void> _menu(BuildContext context, Offset at) async {
    final l10n = context.l10n;
    final picked = await showMenu<VoidCallback>(
      context: context,
      position: RelativeRect.fromLTRB(at.dx, at.dy, at.dx, at.dy),
      items: [
        PopupMenuItem(value: onSchedule, child: Text(l10n.inboxSchedule)),
        PopupMenuItem(value: onTrash, child: Text(l10n.inboxTrash)),
      ],
    );
    picked?.call();
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.row});

  final InboxRow row;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return GestureDetector(
      // Screen readers use the row's custom actions instead.
      excludeFromSemantics: true,
      onLongPressStart: (d) => unawaited(row._menu(context, d.globalPosition)),
      onSecondaryTapUp: (d) => unawaited(row._menu(context, d.globalPosition)),
      child: Material(
        color: c.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.card),
          side: BorderSide(color: c.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: row.onOpen,
          // The row's container node carries the tap and its label.
          excludeFromSemantics: true,
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.l),
            child: Row(
              spacing: DotSpace.l,
              children: [
                ExcludeSemantics(
                  child: TaskDot(
                    color: row.color,
                    icon: row.icon,
                    state: DotState.upcoming,
                    label: row.title,
                  ),
                ),
                Expanded(
                  // The row's container carries the label.
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.meta, style: t.styles.rowMeta),
                        Text(row.title, style: t.styles.rowTitle),
                      ],
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: context.l10n.inboxSchedule,
                  onPressed: row.onSchedule,
                  style: IconButton.styleFrom(
                    backgroundColor: c.accentTint,
                    minimumSize: const Size.square(DotTouch.android),
                  ),
                  icon: DotIcon(DotGlyphs.add, color: c.accentInk),
                ),
              ],
            ),
          ),
        ),
      ),
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
