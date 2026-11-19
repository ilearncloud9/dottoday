import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/drag_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/pickers/when/when_picker.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Move (ED-099): the one When picker for [o], then the picked day and time
/// with Undo; it keeps its length, and a pinned task never gets here
/// (callers grey Move out). The sheets' Move tile and Move To… (⇧⌘M, the
/// web's m) for one task use it; [anchor] places the Mac and web popover.
Future<void> pickMoveTask(
  BuildContext context,
  WidgetRef ref,
  Occurrence o, {
  Rect? anchor,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final undo = ref.read(undoServiceProvider);
  final zone = tz.getLocation(o.tzId);
  final local = tz.TZDateTime.from(
    o.startUtc ?? ref.read(clockProvider).nowUtc(),
    zone,
  );
  final today =
      ref.read(todayDateProvider).value ??
      DateTime(local.year, local.month, local.day);
  final start = await showWhenPicker(
    context,
    task: o,
    mode: WhenMode.move,
    today: today,
    anchor: anchor,
  );
  if (start == null || start == o.startUtc || !context.mounted) return;
  final use24h = use24hFor(
    context,
    ref.read(currentProfileProvider).value?.settings.use24h,
  );
  final at = tz.TZDateTime.from(start, zone);
  final day = DateTime(at.year, at.month, at.day);
  final time = timeOfUtc(context, zone, start, use24h: use24h);
  final when = day == today
      ? time
      : l10n.inboxScheduleDay(
          DateFormat.MMMEd(l10n.localeName).format(day),
          time,
        );
  reportUndoable(
    messenger,
    l10n,
    undo,
    await moveTask(ref, o, start),
    message: (_) => l10n.snackMoved(o.title, when),
    tokenOf: (t) => t,
  );
}
