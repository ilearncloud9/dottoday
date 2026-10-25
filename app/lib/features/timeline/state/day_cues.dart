import 'package:dottoday/core/l10n/generated/app_localizations.dart';
import 'package:dottoday/data/notifications/notification_content.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/scheduling/start_nudge.dart';
import 'package:dottoday/domain/scheduling/unstick.dart';

/// The quiet cues a day's tasks carry: Smallest step's "Just Gather
/// documents · 10 min?" (M10.6) and Unstick's first-step question (M10.7),
/// by occurrence id. One place, so Today, the spread and Week agree.
typedef DayCues = ({Map<String, String> smallestSteps, Set<String> unstick});

/// The cues of [blocks] at [now], from each task's first step to do
/// ([firstSteps]) and its step count ([subtasks]; null while loading).
DayCues dayCues(
  AppLocalizations l10n, {
  required List<Occurrence> blocks,
  required Map<String, Subtask> firstSteps,
  required Map<String, ({int done, int total})>? subtasks,
  required DateTime now,
}) => (
  smallestSteps: {
    for (final o in blocks)
      if (firstSteps[o.id] case final step?)
        if (smallestStepAt(o, [step], now) != null)
          o.id: smallestStepText(l10n, step),
  },
  unstick: {
    for (final o in blocks)
      // Only once the steps are known: never a flash on a task that has some.
      if (subtasks != null &&
          (subtasks[o.id]?.total ?? 0) == 0 &&
          showsUnstick(o, const []))
        o.id,
  },
);
