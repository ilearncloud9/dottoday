import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/schedule_edit.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_checks.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_days.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_options.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_text.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_times.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/shared/dot/night_dial.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// The schedule sheet's form, top to bottom as E-Phones draws it: Days;
/// Wind Down and Wake Up (the dial and the sleep target line, in a card
/// on iPhone); the two time fields and the hint; the checks; then the
/// alarm, the reminder and Remove.
class ScheduleBody extends StatelessWidget {
  const ScheduleBody({
    required this.settings,
    required this.draft,
    required this.others,
    required this.action,
    required this.wake,
    required this.windDown,
    required this.selected,
    required this.focused,
    required this.onDay,
    required this.onTime,
    required this.onSelect,
    required this.onFocus,
    required this.onRing,
    required this.onRemind,
    required this.onRemove,
    super.key,
  });

  final Settings settings;
  final ScheduleDraft draft;
  final Map<Weekday, String> others;
  final String action;
  final int wake;
  final int windDown;
  final DialEnd selected;
  final DialEnd? focused;
  final ValueChanged<Weekday> onDay;
  final void Function(DialEnd end, int minute) onTime;
  final ValueChanged<DialEnd> onSelect;
  final ValueChanged<DialEnd?> onFocus;
  final ValueChanged<bool> onRing;
  final ValueChanged<bool> onRemind;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final ios = DotIdiom.of(context) == DotIdiom.cupertino;
    final firstDay = settings.firstDayOfWeek;
    final focusedEnd = focused;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        _Caption(l10n.schDaysCaption),
        ScheduleDays(
          days: draft.days,
          others: others,
          firstDay: firstDay,
          onTap: onDay,
        ),
        _Caption(l10n.schTimes),
        _dialCard(context, ios),
        ScheduleTimes(
          windDown: windDown,
          wake: wake,
          selected: selected,
          use24h: settings.use24h,
          onSelect: onSelect,
          onChanged: onTime,
        ),
        if (ios || focusedEnd != null)
          Text(
            [
              if (ios) l10n.schDragHint,
              if (focusedEnd != null)
                l10n.schFocusHint(_endName(l10n, focusedEnd)),
            ].join('\n'), // l10n-ignore: line break
            style: t.styles.rowMeta.copyWith(color: t.colors.muted),
          ),
        ScheduleCheckNotes(
          draft: draft,
          action: action,
          use24h: settings.use24h,
          firstDay: firstDay,
        ),
        const SizedBox(height: DotSpace.s),
        ScheduleOptions(
          settings: settings,
          days: weekOrder(draft.days, firstDay),
          wake: wake,
          ring: draft.ring,
          remind: draft.remind,
          onRing: onRing,
          onRemind: onRemind,
          onRemove: onRemove,
        ),
      ],
    );
  }

  String _endName(AppLocalizations l10n, DialEnd end) =>
      end == DialEnd.windDown ? l10n.settingsWindDown : l10n.settingsWakeUp;

  Widget _dialCard(BuildContext context, bool ios) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final night = nightMinutes(draft.window);
    final target = _targetLine(l10n, night);
    final dial = Column(
      spacing: DotSpace.s,
      children: [
        NightDial(
          windDown: windDown,
          wake: wake,
          selected: selected,
          onChanged: onTime,
          onSelect: onSelect,
          onKeyboardFocus: onFocus,
          labels: dialLabels(context, settings.use24h),
          length: formatDurationShort(l10n, night),
          lengthCaption: l10n.schOfNight,
          handleLabel: (e) => _endName(l10n, e),
          handleValue: (m) =>
              clockText(context, m % Duration.minutesPerDay, settings.use24h),
        ),
        if (target != null)
          Text(target, style: t.styles.body, textAlign: TextAlign.center),
      ],
    );
    if (!ios) return dial;
    return Container(
      padding: const EdgeInsets.all(DotSpace.l),
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: t.colors.outline),
      ),
      child: dial,
    );
  }

  /// "30 min under your 8 h sleep target", "Matches …"; none without a
  /// target.
  String? _targetLine(AppLocalizations l10n, int night) {
    final target = settings.sleepTargetMin;
    if (target == null) return null;
    final goal = formatDurationShort(l10n, target);
    final gap = night - target;
    if (gap == 0) return l10n.schMatchesTarget(goal);
    final by = formatDurationShort(l10n, gap.abs());
    return gap < 0
        ? l10n.schUnderTarget(by, goal)
        : l10n.schOverTarget(by, goal);
  }
}

/// A section caption: grey on iPhone, the accent on Android (E-Phones).
class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final ios = DotIdiom.of(context) == DotIdiom.cupertino;
    return Semantics(
      header: true,
      child: Text(
        text,
        style: ios
            ? t.styles.caption
            : t.styles.rowMeta.copyWith(
                color: t.colors.accentInk,
                fontWeight: FontWeight.w700,
              ),
      ),
    );
  }
}
