import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/layout/time_scale.dart';
import 'package:dottoday/features/timeline/layout/timeline_day.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pixel offset of now on [scale], or null when now is outside [day].
double? nowY(WidgetRef ref, TimelineDay day, TimeScale scale) {
  final now = ref.watch(minuteTickProvider).value;
  if (now == null) return null;
  final m = day.minuteOf(now);
  if (m < 0 || m > day.minutes) return null;
  return scale.yOf(m);
}

/// The past part of the day, tinted `surfaceSunken` behind the blocks so
/// the timeline "fills as the day passes" (docs/03 §3.1).
class PastTint extends ConsumerWidget {
  const PastTint({required this.day, required this.scale, super.key});

  final TimelineDay day;
  final TimeScale scale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(minuteTickProvider).value;
    final y = now == null
        ? 0.0
        : now.isAfter(day.endUtc)
        ? scale.height
        : nowY(ref, day, scale) ?? 0.0;
    return AnimatedPositioned(
      duration: DotTheme.of(context).motion.base,
      curve: DotTheme.of(context).motion.curve,
      top: 0,
      left: 0,
      right: 0,
      height: y,
      child: ExcludeSemantics(
        child: ColoredBox(color: DotTheme.of(context).colors.outline),
      ),
    );
  }
}

/// Accent now-line with a leading dot; moves once a minute and is still
/// under reduced motion (zero-length animation).
class NowLine extends ConsumerWidget {
  const NowLine({
    required this.day,
    required this.scale,
    required this.left,
    required this.use24h,
    super.key,
  });

  final TimelineDay day;
  final TimeScale scale;

  /// Start offset of the line (the gutter width).
  final double left;
  final bool use24h;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final y = nowY(ref, day, scale);
    if (y == null) return const Positioned(child: SizedBox.shrink());
    final t = DotTheme.of(context);
    final now = ref.watch(minuteTickProvider).value!;
    final label = context.l10n.timelineNow(
      timeOfUtc(context, day.location, now, use24h: use24h),
    );
    return AnimatedPositionedDirectional(
      duration: t.motion.base,
      curve: t.motion.curve,
      top: y - AppTimeline.nowDot / 2,
      start: left - AppTimeline.nowDot / 2,
      end: 0,
      height: AppTimeline.nowDot,
      child: Semantics(
        label: label,
        child: IgnorePointer(child: _NowMark(color: t.colors.accent)),
      ),
    );
  }
}

class _NowMark extends StatelessWidget {
  const _NowMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox.square(dimension: AppTimeline.nowDot),
        ),
        Expanded(
          child: Container(height: AppTimeline.nowLineWidth, color: color),
        ),
      ],
    );
  }
}
