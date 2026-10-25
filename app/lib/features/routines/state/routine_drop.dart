import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/proposals/routine_proposal.dart';
import 'package:dottoday/domain/routines/routine_rules.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Opens the proposal for dropping [routine] on [date] (11 C2, docs/09
/// M11.4): one task per step from the routine's anchor that day, shown
/// over the day as it is. Nothing is written until Accept (CLAUDE.md §11).
/// [dayName] ("Today") and [time] (an instant as clock text in a zone)
/// word the subtitle.
Future<void> openRoutineDrop(
  ProviderContainer container,
  AppLocalizations l10n,
  Routine routine, {
  required DateTime date,
  required String dayName,
  required String Function(tz.Location zone, DateTime utc) time,
  IdGenerator ids = const UuidV7Generator(),
}) async {
  final profile = await container.read(currentProfileProvider.future);
  final room = await _room(container, date);
  final zone = tz.getLocation(profile.tzId);
  final shape = DayShape(wakeUtc: room.startUtc, bedUtc: room.endUtc);
  final start = routineStartUtc(routine, shape: shape, zone: zone, date: date);
  final now = container.read(clockProvider).nowUtc();
  final tasks = routineTasks(
    routine.copyWith(userId: profile.id),
    startUtc: start,
    tzId: zone.name,
    nowUtc: now,
    newId: ids.newId,
  );
  container
      .read(activeProposalProvider.notifier)
      .open(
        ProposalRequest(
          proposal: routineProposal(
            userId: profile.id,
            day: room.blocks,
            tasks: tasks,
            wakeUtc: shape.wakeUtc,
            bedUtc: shape.bedUtc,
            nowUtc: now,
          ),
          title: l10n.routineDropTitle,
          subtitle: l10n.routineDropSubtitle(
            routine.title,
            dayName,
            time(zone, start),
          ),
          acceptLabel: l10n.routineDropAccept,
          acceptedMessage: l10n.routineDropAccepted,
        ),
      );
}

/// [date]'s day, held while it loads (nothing else may be watching it).
Future<DayRoom> _room(ProviderContainer container, DateTime date) async {
  final hold = container.listen(dayRoomProvider(date), (_, _) {});
  try {
    return await container.read(dayRoomProvider(date).future);
  } finally {
    hold.close();
  }
}
