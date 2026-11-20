import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The minimal task screen's header (ED-089, ED-216): the 44 dot with its
/// progress, the title (Manrope 800 21/26, read-only) and under it "Now,
/// 18 min left" in teal while it runs, else its times; [onClose] draws
/// the round ✕ (the phones' sheet; the Day column has its own row).
class TaskMHead extends ConsumerWidget {
  const TaskMHead({required this.task, this.onClose, super.key});

  final TaskView task;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final o = task.occurrence;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final state = dotStateOf(o, now);
    final live = state == DotState.live;
    final start = o.startUtc;
    final left = live ? (o.endUtc!.difference(now).inSeconds / 60).ceil() : 0;
    final zone = tz.getLocation(o.tzId);
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final meta = start == null
        ? l10n.sheetInbox
        : live
        ? l10n.liveNowLeft(left)
        : l10n.threadTimeRange(time(start), time(o.endUtc!));
    return Row(
      spacing: DotSpace.m,
      children: [
        TaskDot(
          color: TaskColor.fromKey(o.colorKey),
          icon: TaskIcon.fromKey(o.iconKey),
          state: state,
          progress: live
              ? now.difference(start!).inSeconds /
                    o.endUtc!.difference(start).inSeconds
              : 0,
          size: DotTouch.min,
          label: taskDotLabel(
            l10n,
            title: o.title,
            state: state,
            minutesLeft: live ? left : null,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(o.title, style: t.styles.minimalSheetTitle),
              ),
              Text(
                meta,
                style: t.styles.rowMeta.copyWith(
                  color: live ? t.colors.accentInk : t.colors.muted,
                  fontWeight: live ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        ),
        if (onClose case final close?)
          IconButton.filledTonal(
            tooltip: l10n.editorClose,
            onPressed: close,
            style: IconButton.styleFrom(backgroundColor: t.colors.sunk),
            icon: DotIcon(DotGlyphs.close, color: t.colors.text),
          ),
      ],
    );
  }
}
