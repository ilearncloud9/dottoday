import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/wake_up/mission_flags.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/wake_up/mission.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Wind Down review's "Tomorrow matters: make sure I'm up." (docs/15
/// §8 rule 5): flags tomorrow morning for a mission. Off by default, one
/// morning only (it clears itself once that day comes), hidden while
/// missions are off. When the chosen mission can't run tomorrow it says
/// Breathe will be used instead (owner, 2026-11-01).
class TomorrowMattersToggle extends ConsumerWidget {
  const TomorrowMattersToggle({required this.day, super.key});

  /// The day under review; the flag is for the morning after it.
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(currentProfileProvider).value?.settings;
    if (settings == null || settings.missionMode == MissionMode.off) {
      return const SizedBox.shrink();
    }
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final tomorrow = DateTime(day.year, day.month, day.day + 1);
    final key = formatRouteDate(tomorrow);
    final on = settings.missionFlagDate == key;
    final dots = ref
        .watch(timelineDataProvider(tomorrow))
        .value
        ?.blocks
        .where((o) => o.status != OccurrenceStatus.skipped)
        .length;
    final gentler =
        on &&
        dots != null &&
        flaggedMissionKind(settings, dots: dots, can: (_) => true) !=
            settings.missionKind;
    void set(bool value) => _report(
      context,
      setTomorrowMatters(
        ProviderScope.containerOf(context, listen: false),
        dateKey: key,
        on: value,
      ),
    );
    // Its own Material: the review sits in Today's decorated prompt card,
    // which would hide the tile's ink.
    return Material(
      type: MaterialType.transparency,
      child: MergeSemantics(
        child: ListTile(
          onTap: () => set(!on),
          contentPadding: EdgeInsets.zero,
          minTileHeight: DotTouch.android,
          title: Text(l10n.tomorrowMatters, style: t.styles.body),
          subtitle: gentler
              ? Text(l10n.tomorrowMattersBreathe, style: t.styles.rowMeta)
              : null,
          trailing: DotSwitch(value: on, onChanged: set),
        ),
      ),
    );
  }
}

/// The task sheet's "Make sure I'm up for this" (docs/15 §8 rule 5): when
/// this dot is the first of its day, that morning asks for the mission.
/// It flags this occurrence only (a repeat's others are untouched) and is
/// shown for a dot still ahead while missions are on. Draws its own
/// divider above, as a row of the sheet's card.
class MakeSureUpRow extends ConsumerWidget {
  const MakeSureUpRow({required this.occurrence, super.key});

  final Occurrence occurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final start = occurrence.startUtc;
    final now = ref.watch(clockProvider).nowUtc();
    if (profile == null ||
        profile.settings.missionMode == MissionMode.off ||
        start == null ||
        !start.isAfter(now)) {
      return const SizedBox.shrink();
    }
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final on = profile.settings.missionFlagIds.contains(occurrence.id);
    void set(bool value) => _report(
      context,
      setMissionFlag(
        ProviderScope.containerOf(context, listen: false),
        userId: profile.id,
        occurrenceId: occurrence.id,
        on: value,
      ),
    );
    return Column(
      children: [
        Divider(height: DotSpace.hairline, color: t.colors.outline),
        MergeSemantics(
          child: ListTile(
            onTap: () => set(!on),
            minTileHeight: DotTouch.android + DotSpace.s,
            leading: DotIcon(DotGlyphs.bell, color: t.colors.muted),
            title: Text(l10n.makeSureUpTitle, style: t.styles.body),
            subtitle: Text(l10n.makeSureUpDetail, style: t.styles.rowMeta),
            trailing: DotSwitch(value: on, onChanged: set),
          ),
        ),
      ],
    );
  }
}

/// Shows a failed write's message; a flag that didn't save must say so.
void _report(BuildContext context, Future<Result<void, AppFailure>> write) {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  unawaited(
    write.then((result) {
      if (result case Err(:final failure)) {
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
      }
    }),
  );
}
