import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/breakdown_proposal.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/thinking/breakdown_tree.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:dottoday/features/task_editor/breakdown/breakdown_body.dart';
import 'package:dottoday/features/task_editor/breakdown/breakdown_parts.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// What is being broken down: a saved task, or Add step 1's draft.
final class BreakdownTarget {
  const BreakdownTarget({
    required this.title,
    required this.durationMin,
    required this.colorKey,
    required this.iconKey,
    this.task,
    this.onDraftAccepted,
  });

  /// A saved task (the task sheet): Accept writes its steps.
  factory BreakdownTarget.task(Occurrence o) => BreakdownTarget(
    title: o.title,
    durationMin: o.durationMin,
    colorKey: o.colorKey,
    iconKey: o.iconKey,
    task: o,
  );

  final String title;
  final int durationMin;
  final String colorKey;
  final String iconKey;
  final Occurrence? task;

  /// Add step 1: Accept hands the steps to the draft, saved with the task.
  final ValueChanged<List<ProposedStep>>? onDraftAccepted;
}

/// Break it down (11 B1, docs/09 M10.4): asks `ThinkingService` — the
/// user's usual breakdown first, then the on-device model, else an empty
/// 3-step template — and opens the steps as a mini thread in the
/// `ProposalSheet`. Nothing is written before Accept; Accept remembers
/// the steps as this title's usual breakdown.
Future<void> breakDown(BuildContext context, BreakdownTarget target) async {
  final c = ProviderScope.containerOf(context, listen: false);
  final l10n = context.l10n;
  final profile = await readProfile(c);
  final service = c.read(thinkingServiceProvider);
  final asked = await service.breakDown(
    BreakdownRequest(
      title: target.title,
      language: profile.locale,
      durationMin: target.durationMin,
    ),
  );
  final first = switch (asked) {
    Ok(:final value) => value,
    Err() => null,
  };
  if (first == null) return;
  final existing = target.task == null
      ? const <Never>[]
      : await c.read(subtaskRepositoryProvider).watchForOccurrences(
          profile.id,
          {target.task!.id},
        ).first;
  if (!context.mounted) return;
  const ids = UuidV7Generator();
  final join = l10n.breakdownJoin;
  var tree = BreakdownTree.of(first.steps, ids.newId);
  final nowUtc = c.read(clockProvider).nowUtc();

  Proposal build(BreakdownTree t) {
    final task = target.task;
    if (task == null) {
      return Proposal(
        userId: profile.id,
        before: _empty(nowUtc),
        edits: [
          if (t.complete)
            const ProposalEdit(
              id: breakdownEditId,
              change: ProposalChange.steps,
              removable: false,
            ),
        ],
      );
    }
    final p = breakdownProposal(
      task: task,
      existing: existing,
      tree: t,
      nowUtc: nowUtc,
      join: join,
    );
    return t.complete ? p : p.withEdits(const []);
  }

  Future<List<ProposedStep>?> split(StepNode step, int depth) async {
    final r = await service.breakDown(
      BreakdownRequest(
        title: step.title,
        language: profile.locale,
        durationMin: step.length,
        depth: depth,
      ),
    );
    return switch (r) {
      // A template of empty steps is no help one level down.
      Ok(:final value) when value.origin != ThinkingOrigin.rules => value.steps,
      _ => null,
    };
  }

  final color = TaskColor.fromKey(target.colorKey);
  final when = _when(context, target.task, profile.settings.use24h);
  c
      .read(activeProposalProvider.notifier)
      .open(
        ProposalRequest(
          proposal: build(tree),
          title: l10n.breakdownAction,
          originLabel: switch (first.origin) {
            ThinkingOrigin.onDevice => l10n.breakdownOnDevice,
            ThinkingOrigin.saved => l10n.breakdownUsual,
            _ => null,
          },
          acceptedMessage: l10n.breakdownAccepted(target.title),
          draftOnly: target.task == null,
          overSheet: target.task == null,
          lead: (context, p) => BreakdownLead(
            title: target.title,
            color: color,
            icon: TaskIcon.fromKey(target.iconKey),
            when: when,
            beforeMin: target.durationMin,
            afterMin: _grown(tree, target.durationMin),
          ),
          body: (context, p, update) => BreakdownBody(
            initial: tree,
            color: color,
            newId: ids.newId,
            split: split,
            onChanged: (t) {
              tree = t;
              update(build(t));
            },
          ),
          below: (context, p) => switch (tree.total) {
            final total? => BreakdownTotal(
              totalMin: total,
              beforeMin: target.durationMin,
              color: color,
            ),
            null => const SizedBox.shrink(),
          },
          onAccepted: (_) {
            final steps = [
              for (final l in tree.leaves(join))
                ProposedStep(title: l.title, durationMin: l.durationMin),
            ];
            // Remembered for next time (11 B1 "My usual breakdown").
            unawaited(
              c.read(thinkingMemoryProvider).saveBreakdown(target.title, steps),
            );
            target.onDraftAccepted?.call(steps);
          },
        ),
      );
}

/// The task's length once it follows the steps.
int _grown(BreakdownTree tree, int before) => tree.total ?? before;

/// "Today · 4:00 PM" for a timed task.
String? _when(BuildContext context, Occurrence? task, bool? use24hSetting) {
  final start = task?.startUtc;
  if (task == null || start == null) return null;
  final zone = tz.getLocation(task.tzId);
  final local = tz.TZDateTime.from(start, zone);
  final now = tz.TZDateTime.now(zone);
  final day = relativeDayName(
    context,
    DateTime(local.year, local.month, local.day),
    DateTime(now.year, now.month, now.day),
  );
  final time = timeOfUtc(
    context,
    zone,
    start,
    use24h: use24hFor(context, use24hSetting),
  );
  return context.l10n.proposalDayTime(day, time);
}

DaySnapshot _empty(DateTime nowUtc) => DaySnapshot(
  generatedAtUtc: nowUtc,
  wakeUtc: nowUtc,
  bedUtc: nowUtc,
  dots: const [],
  inboxCount: 0,
);
