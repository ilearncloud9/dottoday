import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/features/timeline/layout/block_facts.dart';

/// Screen-reader label of a block, in the order of docs/03 §4:
/// "Gym, 07:00 to 07:45, 2 of 3 subtasks done, recurring, pinned".
/// Every visual badge has its words here, so colour and icons are never
/// the only signal (R-12).
String blockLabel(
  AppLocalizations l10n, {
  required String title,
  required String start,
  required String end,
  required BlockFacts facts,
}) {
  return [
    l10n.blockSemantics(title, start, end),
    if (facts.hasSubtasks)
      l10n.blockSubtasks(facts.subtasksDone, facts.subtasksTotal),
    if (facts.done) l10n.blockDone,
    if (facts.overdue) l10n.blockNotDoneYet,
    if (facts.recurring) l10n.blockRecurring,
    if (facts.pinned) l10n.blockPinned,
    if (facts.calendar) l10n.blockFromCalendar,
    if (facts.alertCount > 0) l10n.blockAlerts(facts.alertCount),
    if (facts.startsBefore) l10n.blockStartsBefore,
    if (facts.endsAfter) l10n.blockEndsAfter,
  ].join(l10n.semanticsSeparator);
}
