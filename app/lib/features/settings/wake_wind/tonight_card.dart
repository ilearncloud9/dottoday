import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/schedules.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Tonight (E-Phones Wake Up and Wind Down, ED-084): today's Wind Down,
/// tomorrow's Wake Up, the night between and whether the alarm rings,
/// between the moon and the sun on a short thread.
class TonightCard extends ConsumerWidget {
  const TonightCard({required this.profile, super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final s = profile.settings;
    final now = tz.TZDateTime.from(
      ref.watch(clockProvider).nowUtc(),
      tz.getLocation(profile.tzId),
    );
    final today = Weekday.values[now.weekday - 1];
    final tomorrow = Weekday.values[now.weekday % 7];
    final locale = Localizations.localeOf(context).toLanguageTag();
    final night = formatDurationShort(l10n, nightAfter(s, today));
    final windDown = windowMinutes(s.boundaryFor(today).end);
    final wake = windowMinutes(s.boundaryFor(tomorrow).start);
    final bold = t.styles.rowTitle;
    return Container(
      padding: const EdgeInsets.all(DotSpace.l),
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: t.colors.outline),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.m,
          children: [
            Column(
              children: [
                const _End(glyph: DotGlyphs.moon, colour: TaskColor.violet),
                Expanded(
                  child: VerticalDivider(
                    width: DotSize.smallDotOutline,
                    thickness: DotSize.smallDotOutline,
                    color: t.tasks[TaskColor.violet].color,
                  ),
                ),
                _End(glyph: DotGlyphs.sun, colour: TaskColor.amber),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.wwdTonight(DateFormat.EEEE(locale).format(now)),
                    style: t.styles.rowMeta.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.wwdWindDownAt(
                      windDownText(context, windDown, s.use24h),
                    ),
                    style: bold,
                  ),
                  Text(
                    l10n.wwdWakeUpAt(clockText(context, wake, s.use24h)),
                    style: bold,
                  ),
                  Text(
                    s.wakeUpAlarm
                        ? l10n.wwdNightAlarmOn(night)
                        : l10n.wwdNightAlarmOff(night),
                    style: t.styles.rowMeta,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The moon or the sun in its tinted circle.
class _End extends StatelessWidget {
  const _End({required this.glyph, required this.colour});

  final DotGlyph glyph;
  final TaskColor colour;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).tasks[colour];
    return Container(
      width: DotSize.rowDot,
      height: DotSize.rowDot,
      decoration: BoxDecoration(color: c.tint, shape: BoxShape.circle),
      child: Center(
        child: DotIcon(glyph, color: c.ink, size: DotSize.rowIcon),
      ),
    );
  }
}
