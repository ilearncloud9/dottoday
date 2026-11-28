import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/haptics/app_haptics.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

part 'inbox_row_parts.dart';

/// An unscheduled task (E-R2-13, ED-295): its dot, the title, "30 min ·
/// added today", where it fits ("Fits today 11:00") and Place. Swipe
/// toward the start schedules, toward the end trashes; screen readers get
/// both as actions, and a long-press or right-click opens the same
/// choices, so nothing needs a swipe (R-12). The menu's Select starts
/// picking several ([selected] then shows a check instead of Place).
/// With [reorderIndex], holding the row lifts it to a new place in the
/// list, and a hold without moving opens the menu, which has Move up /
/// Move down for keyboards and screen readers (owner, M20.2 part 1).
class InboxRow extends StatelessWidget {
  const InboxRow({
    required this.title,
    required this.meta,
    required this.color,
    required this.icon,
    required this.placeLabel,
    required this.onPlace,
    required this.onSchedule,
    required this.onTrash,
    this.onOpen,
    this.fit,
    this.swipe = true,
    this.selected,
    this.onSelect,
    this.reorderIndex,
    this.onMoveUp,
    this.onMoveDown,
    this.oneThing = false,
    super.key,
  });

  /// Today's one thing (docs/15 §8): the dot's accent ring. The caller's
  /// [meta] says "Your one thing", so it never relies on colour.
  final bool oneThing;

  /// Null when not selecting; otherwise whether this row is picked (a tap
  /// — [onOpen] — then toggles it).
  final bool? selected;

  /// "Select": start picking several, with this row.
  final VoidCallback? onSelect;

  /// Its place in a reorderable list; null when holding doesn't reorder.
  final int? reorderIndex;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  final String title;

  /// "30 min · added today".
  final String meta;

  /// "Fits today 11:00", "Fits Wed 3:00"; null while the week loads.
  final String? fit;

  /// "Place" (where it fits) or "Schedule" (it fits nowhere this week).
  final String placeLabel;
  final VoidCallback onPlace;

  /// Swipe to schedule / trash. Off where a mouse drags rows onto the
  /// thread (Mac/web), so the two gestures never compete; Place, the
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
    final label = l10n.inboxRowLabel(title, meta);
    return Semantics(
      container: true,
      button: onOpen != null,
      selected: selected,
      label: switch (fit) {
        final f? => l10n.inboxRowFitLabel(label, f),
        null => label,
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
                AppHaptics.play(context, HapticTick.medium);
                direction == DismissDirection.endToStart
                    ? onSchedule()
                    : onTrash();
                return false;
              },
              background: _SwipeLabel(
                text: l10n.inboxTrash,
                glyph: DotGlyphs.trash,
                // Coral, the palette's warm colour, marks the destructive side.
                color: t.tasks[TaskColor.coral].tint,
                ink: t.tasks[TaskColor.coral].ink,
                alignment: AlignmentDirectional.centerStart,
              ),
              secondaryBackground: _SwipeLabel(
                text: l10n.inboxSchedule,
                glyph: DotGlyphs.calendar,
                glyphAfter: true,
                color: t.colors.tonal,
                ink: t.colors.accentText,
                alignment: AlignmentDirectional.centerEnd,
              ),
              child: _Card(row: this),
            )
          : _Card(row: this),
    );
  }

  /// Everything a swipe, the menu or a hold does, for screen readers.
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
    final picked = await showContextMenu<VoidCallback>(
      context,
      at: at,
      entries: [
        ContextMenuEntry(
          value: onSchedule,
          label: l10n.inboxSchedule,
          symbol: 'calendar', // l10n-ignore: SF Symbol name
        ),
        if (onMoveUp case final up?)
          ContextMenuEntry(
            value: up,
            label: l10n.subtaskMoveUp,
            symbol: 'arrow.up', // l10n-ignore: SF Symbol name
          ),
        if (onMoveDown case final down?)
          ContextMenuEntry(
            value: down,
            label: l10n.subtaskMoveDown,
            symbol: 'arrow.down', // l10n-ignore: SF Symbol name
          ),
        if (onSelect case final select? when selected == null)
          ContextMenuEntry(
            value: select,
            label: l10n.inboxSelect,
            symbol: 'checklist.unchecked', // l10n-ignore: SF Symbol name
          ),
        // "Move to Trash ⌘⌫" in every Mac context menu (ED-162, ED-336).
        ContextMenuEntry(
          value: onTrash,
          label: l10n.inboxTrash,
          symbol: 'trash', // l10n-ignore: SF Symbol name
          shortcut: const SingleActivator(
            LogicalKeyboardKey.backspace,
            meta: true,
          ),
        ),
      ],
    );
    picked?.call();
  }
}
