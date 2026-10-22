import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Inbox's Schedule flow for task [id] from elsewhere (Search's
/// "+ Schedule"; the app root maps `ScheduleTaskIntent` here). Does
/// nothing if the task isn't the current user's or is no longer in the
/// Inbox (06 §9: ids resolve under the current user only).
Future<void> scheduleFromAnywhere(BuildContext context, String id) async {
  final container = ProviderScope.containerOf(context);
  final profile = await readProfile(container);
  final item = await container
      .read(occurrenceRepositoryProvider)
      .findById(profile.id, id);
  if (item == null || !item.isInbox || item.deletedAt != null) return;
  final today = await container.read(inboxTodayProvider.future);
  if (!context.mounted) return;
  final zone = tz.getLocation(profile.tzId);
  final use24h = use24hFor(context, profile.settings.use24h);
  String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
  final l10n = context.l10n;
  await InboxCommands(
    context,
    today: today,
    timeText: time,
    rangeText: (s) => l10n.threadTimeRange(time(s.startUtc), time(s.endUtc)),
  ).schedule(item);
}
