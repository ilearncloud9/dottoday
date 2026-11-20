import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/now/now_body.dart';
import 'package:dottoday/features/timeline/now/now_rows.dart';
import 'package:dottoday/shared/dot/now_orb.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

// Now's quieter states (ED-329): Next up between tasks, an open day and
// the day's end. Split from now_body.dart (≤ 300 lines).

/// Next up between tasks (E-R2-26): the next task's ring, its times and
/// the free time until it.
class NowNextUpView extends StatelessWidget {
  const NowNextUpView({
    super.key,
    required this.task,
    required this.free,
    required this.time,
  });

  final Occurrence task;
  final Duration free;
  final NowTime time;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return MergeSemantics(
      child: InkWell(
        onTap: () => openTask(context, task.id),
        borderRadius: BorderRadius.circular(DotRadii.card),
        child: Column(
          spacing: DotSpace.xs,
          children: [
            NextUpRing(task: task),
            const SizedBox(height: DotSpace.s),
            Text(
              l10n.widgetNextUp.toUpperCase(),
              style: t.styles.caption.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: t.styles.emptyTitle,
            ),
            Text(nowRange(time, task), style: t.styles.rowMeta),
            Text(
              l10n.threadFree(formatDurationShort(l10n, free.inMinutes)),
              style: t.styles.rowMeta.copyWith(
                color: t.colors.accentInk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nothing planned (E-PhonesMinimal frame 4): the hours free and Add to
/// the day.
class NowOpenDayView extends StatelessWidget {
  const NowOpenDayView({
    super.key,
    required this.free,
    required this.windDown,
    required this.orbSize,
  });

  final Duration free;
  final String windDown;
  final double orbSize;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      spacing: DotSpace.m,
      children: [
        NowOrb(
          numeral: nowNumber(context, free.inHours),
          unit: l10n.nowHours,
          caption: l10n.nowOrbFree,
          size: orbSize,
        ),
        Column(
          children: [
            Text(l10n.nowOpenDay, style: t.styles.emptyTitle),
            Text(l10n.nowFreeUntil(windDown), style: t.styles.rowMeta),
          ],
        ),
        FilledButton.icon(
          onPressed: () => Actions.maybeInvoke(
            context,
            const AppCommandIntent(AppCommand.quickAdd),
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(DotTouch.android),
          ),
          icon: DotIcon(DotGlyphs.add, color: t.colors.onAccent),
          label: Text(l10n.nowAddToDay),
        ),
        Text(l10n.nowOneThing, style: t.styles.rowMeta),
      ],
    );
  }
}

/// Everything planned is behind now: "Nothing else today".
class NowQuietView extends StatelessWidget {
  const NowQuietView({super.key, required this.windDown});

  final String windDown;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DotSpace.xxl),
      child: Column(
        spacing: DotSpace.xs,
        children: [
          Text(l10n.widgetNothingNext, style: t.styles.emptyTitle),
          Text(l10n.nowFreeUntil(windDown), style: t.styles.rowMeta),
        ],
      ),
    );
  }
}
