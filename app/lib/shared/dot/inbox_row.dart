import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

part 'inbox_row_parts.dart';

/// An unscheduled task (docs/10 §3 `InboxRow`, `A-ios-inbox`): outlined
/// dot, length, title and a round "+" that schedules it. Swipe toward the
/// start schedules, toward the end trashes; screen readers get both as
/// actions, and a long-press or right-click opens the same choices, so
/// nothing needs a swipe (R-12). The menu's Select starts picking several
/// ([selected] then shows a check instead of "+"); [reorderIndex] adds a
/// drag handle, with Move up / Move down for keyboards and screen readers
/// (docs/09 M3f.9c).
class InboxRow extends StatelessWidget {
  const InboxRow({
    required this.title,
    required this.meta,
    required this.color,
    required this.icon,
    required this.onSchedule,
    required this.onTrash,
    this.onOpen,
    this.fit,
    this.titleFirst = false,
    this.swipe = true,
    this.selected,
    this.onSelect,
    this.reorderIndex,
    this.onMoveUp,
    this.onMoveDown,
    super.key,
  });

  /// Null when not selecting; otherwise whether this row is picked (a tap
  /// — [onOpen] — then toggles it).
  final bool? selected;

  /// "Select": start picking several, with this row.
  final VoidCallback? onSelect;

  /// Its place in a reorderable list; null hides the handle.
  final int? reorderIndex;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  final String title;

  /// "60 min" (or "60 min · added Monday" on Mac/web).
  final String meta;

  /// "Fits today 11:30" before the "+" (`A-mac-inbox`); null hides it.
  final String? fit;

  /// Title above the meta (`A-mac-inbox`'s page); the phone rows and the
  /// sidebar put the length first.
  final bool titleFirst;

  /// Swipe to schedule / trash. Off where a mouse drags rows onto the
  /// thread (Mac/web), so the two gestures never compete; the "+", the
  /// right-click menu and the screen-reader actions remain.
  final bool swipe;
  final TaskColor color;
  final TaskIcon icon;
  final VoidCallback onSchedule;
  final VoidCallback onTrash;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = DotTheme.of(context);
    final selecting = selected != null;
    return Semantics(
      container: true,
      button: onOpen != null,
      selected: selected,
      label: switch (fit) {
        final f? => l10n.inboxRowFitLabel(l10n.inboxRowLabel(title, meta), f),
        null => l10n.inboxRowLabel(title, meta),
      },
      onTap: onOpen,
      customSemanticsActions: _actions(l10n),
      child: swipe && !selecting
          ? Dismissible(
              key: ValueKey(
                title.hashCode ^ meta.hashCode ^ identityHashCode(this),
              ),
              // The row leaves when the write lands, not on the swipe itself.
              confirmDismiss: (direction) async {
                unawaited(HapticFeedback.mediumImpact());
                direction == DismissDirection.endToStart
                    ? onSchedule()
                    : onTrash();
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
            )
          : _Card(row: this),
    );
  }

  /// Everything a swipe, the menu or the handle does, for screen readers.
  Map<CustomSemanticsAction, VoidCallback> _actions(AppLocalizations l10n) => {
    CustomSemanticsAction(label: l10n.inboxSchedule): onSchedule,
    CustomSemanticsAction(label: l10n.inboxTrash): onTrash,
    if (selected == null)
      CustomSemanticsAction(label: l10n.inboxSelect): ?onSelect,
    CustomSemanticsAction(label: l10n.subtaskMoveUp): ?onMoveUp,
    CustomSemanticsAction(label: l10n.subtaskMoveDown): ?onMoveDown,
  };

  Future<void> _menu(BuildContext context, Offset at) async {
    final l10n = context.l10n;
    final picked = await showMenu<VoidCallback>(
      context: context,
      position: RelativeRect.fromLTRB(at.dx, at.dy, at.dx, at.dy),
      items: [
        PopupMenuItem(value: onSchedule, child: Text(l10n.inboxSchedule)),
        PopupMenuItem(value: onTrash, child: Text(l10n.inboxTrash)),
        if (onSelect case final select? when selected == null)
          PopupMenuItem(value: select, child: Text(l10n.inboxSelect)),
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
          side: BorderSide(
            color: row.selected == true ? c.accent : c.hairline,
            width: row.selected == true ? DotSize.smallDotOutline : 1,
          ),
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
                Expanded(child: _Texts(row: row)),
                if (row.fit case final fit?)
                  ExcludeSemantics(
                    child: Text(
                      fit,
                      style: t.styles.body.copyWith(color: c.muted),
                    ),
                  ),
                _Trailing(row: row),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
