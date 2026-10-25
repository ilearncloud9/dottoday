import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/domain/proposals/brain_dump_proposal.dart';
import 'package:dottoday/domain/thinking/rules_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';
import 'package:dottoday/features/timeline/review/week_review_state.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Brain-dump to thread (11 B4, docs/09 M12.5): [text] — one task per
/// line (R-07) — goes to `ThinkingService.planFromText` (the on-device
/// model, else Quick Add's parser) and comes back as a proposal on [date]
/// ([dayName] words it). The dump is kept in the local history first, so
/// a Discard never loses it. Nothing is written before Accept. False when
/// there was nothing to plan. [beforeOpen] runs just before the proposal
/// opens (the dump's sheet closes then, so it never closes the proposal).
Future<bool> planBrainDump(
  ProviderContainer container,
  AppLocalizations l10n, {
  required String text,
  required DateTime date,
  required String dayName,
  VoidCallback? beforeOpen,
  IdGenerator ids = const UuidV7Generator(),
}) async {
  final profile = await readProfile(container);
  final now = container.read(clockProvider).nowUtc();
  final memory = container.read(thinkingMemoryProvider);
  await memory.rememberDump(BrainDump(text: text, atUtc: now));
  final request = TextPlanRequest(
    text: text,
    language: profile.locale,
    nowUtc: now,
    tzId: profile.tzId,
  );
  final asked = await container
      .read(thinkingServiceProvider)
      .planFromText(request);
  final plan = switch (asked) {
    Ok(:final value) => value,
    Err() => null,
  };
  if (plan == null || plan.dots.isEmpty) return false;
  // Times only where the person wrote one (groundTimes).
  final dots = plan.origin == ThinkingOrigin.rules
      ? plan.dots
      : groundTimes(
          plan.dots,
          (await RulesThinkingBackend(memory).planFromText(request))?.dots ??
              const [],
        );
  final data = await readTimelineDay(container, date);
  final shape = shapeOf(data);
  final proposal = brainDumpProposal(
    userId: profile.id,
    dots: dots,
    day: DumpDay(
      date: date,
      blocks: data.blocks,
      wakeUtc: shape.wakeUtc,
      bedUtc: shape.bedUtc,
    ),
    zone: tz.getLocation(profile.tzId),
    nowUtc: now,
    defaultDurationMin: profile.settings.defaultDurationMin,
    alerts: profile.settings.defaultAlerts,
    newId: ids.newId,
  );
  beforeOpen?.call();
  container
      .read(activeProposalProvider.notifier)
      .open(
        ProposalRequest(
          proposal: proposal,
          title: l10n.dumpTitle,
          subtitle: l10n.dumpSubtitle(dots.length, dayName),
          originLabel: plan.origin == ThinkingOrigin.onDevice
              ? l10n.breakdownOnDevice
              : null,
          acceptLabel: l10n.routineDropAccept,
          acceptedMessage: l10n.dumpAccepted,
        ),
      );
  return true;
}
