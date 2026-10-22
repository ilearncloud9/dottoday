import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/timeline/state/day_actions.dart';
import 'package:dottoday/features/timeline/state/day_text.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Today's ⋯ › Copy day as text (docs/09 M3f.6, R-11): [date]'s tasks on
/// the clipboard, ready to paste anywhere. Only on the user's say-so, and
/// only titles and times (no notes).
Future<void> copyDayAsText(BuildContext context, DateTime date) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final use24h = use24hFor(
    context,
    container.read(currentProfileProvider).value?.settings.use24h,
  );
  final material = MaterialLocalizations.of(context);
  final profile = await container.read(currentProfileProvider.future);
  final rows = await occurrencesOn(container, date);
  final zone = tz.getLocation(profile.tzId);
  await Clipboard.setData(
    ClipboardData(
      text: dayAsText(
        heading: DateFormat.MMMMEEEEd(locale).format(date),
        blocks: rows,
        time: (utc) {
          final t = ClockTime.ofUtc(zone, utc);
          return material.formatTimeOfDay(
            TimeOfDay(hour: t.hour, minute: t.minute),
            alwaysUse24HourFormat: use24h,
          );
        },
      ),
    ),
  );
  messenger.showSnackBar(SnackBar(content: Text(l10n.snackDayCopied)));
}
