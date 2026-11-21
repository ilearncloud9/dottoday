import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/week_plan.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:dottoday/features/inbox/widgets/inbox_fit.dart';
import 'package:dottoday/features/inbox/widgets/inbox_list.dart';
import 'package:dottoday/features/inbox/widgets/one_thing_meta.dart';
import 'package:dottoday/shared/dot/inbox_row.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/widgets.dart';
import 'package:timezone/timezone.dart' as tz;

/// What every Inbox row is drawn from, at every width (E-R2-13).
final class InboxRowContext {
  const InboxRowContext({
    required this.commands,
    required this.fits,
    required this.zone,
    required this.weekKnown,
    this.oneThingId,
  });

  final InboxCommands commands;
  final InboxFitText fits;
  final tz.Location zone;

  /// Whether the week's free time has loaded; until then no fit shows.
  final bool weekKnown;

  /// Today's one thing (docs/15 §8), ringed when it is in the Inbox.
  final String? oneThingId;

  /// Puts [o] where it first fits, or opens Schedule when nothing fits
  /// this week.
  void place(Occurrence o, WeekFit? fit) => unawaited(
    fit == null ? commands.schedule(o) : commands.place(o, fits.choice(fit)),
  );

  /// The row for [o]: "30 min · added today", "Fits today 11:00" and
  /// Place (Schedule when nothing fits). [onOpen] opens the task; while
  /// picking, a tap picks instead. [holdToReorder] lets a hold reorder.
  InboxRow row(
    BuildContext context,
    Occurrence o,
    WeekFit? fit,
    InboxRowState s, {
    required VoidCallback onOpen,
    bool swipe = true,
    bool holdToReorder = true,
  }) {
    final l10n = context.l10n;
    final oneThing = o.id == oneThingId;
    final created = tz.TZDateTime.from(o.createdAt, zone);
    final nowhere = weekKnown && fit == null;
    return InboxRow(
      title: o.title,
      meta: inboxMetaWithOneThing(
        l10n,
        fits.added(formatDurationShort(l10n, o.durationMin), created),
        oneThing: oneThing,
      ),
      oneThing: oneThing,
      fit: weekKnown ? fits.fit(fit) : null,
      placeLabel: nowhere ? l10n.inboxSchedule : l10n.inboxPlace,
      onPlace: () => place(o, fit),
      swipe: swipe,
      color: TaskColor.fromKey(o.colorKey),
      icon: TaskIcon.fromKey(o.iconKey),
      onSchedule: () => unawaited(commands.schedule(o)),
      onTrash: () => unawaited(commands.trash(o)),
      onOpen: s.selected == null ? onOpen : s.toggle,
      selected: s.selected,
      onSelect: s.toggle,
      reorderIndex: holdToReorder ? s.reorderIndex : null,
      onMoveUp: s.moveUp,
      onMoveDown: s.moveDown,
    );
  }
}
