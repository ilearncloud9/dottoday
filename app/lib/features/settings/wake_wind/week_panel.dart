import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/devices/device_providers.dart';
import 'package:dottoday/domain/devices/alarm_device.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/schedule_edit.dart';
import 'package:dottoday/domain/time/schedules.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_sheet.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_text.dart';
import 'package:dottoday/features/settings/wake_wind/week_table.dart';
import 'package:dottoday/features/settings/widgets/alarm_device_row.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/dot/night_dial.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wake Up and Wind Down's week on a Mac/web form (E-FullA-v2, ED-084;
/// ED-452): the night dial for the selected schedule with its sleep-target
/// line and help, Alarm sounds on, the week table, Add a schedule… and the
/// table's rule. In a 704 pane the dial sits above; from a 920 pane beside
/// the table, as the board draws it.
class WeekPanel extends ConsumerStatefulWidget {
  const WeekPanel({required this.profile, super.key});

  final Profile profile;

  @override
  ConsumerState<WeekPanel> createState() => _WeekPanelState();
}

/// A leaf: the selected schedule, the dragged times before they are
/// written, and which handle is selected.
class _WeekPanelState extends ConsumerState<WeekPanel> {
  List<Weekday>? _days;
  ({int wake, int windDown})? _drag;
  DialEnd _end = DialEnd.wake;
  Timer? _write;

  /// Bound while the page is up, so a drag still settling as it closes
  /// is written, not dropped.
  late void Function(Settings Function(Settings)) _save;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _save = settingsWriter(context);
  }

  @override
  void dispose() {
    _flush();
    super.dispose();
  }

  Settings get _settings => widget.profile.settings;

  DaySchedule _selected() {
    final all = schedulesOf(_settings, firstDay: _settings.firstDayOfWeek);
    final days = _days;
    return all.firstWhere(
      (s) => days != null && s.days.toSet().containsAll(days),
      orElse: () => all.first,
    );
  }

  void _onDial(DialEnd end, int minute, DaySchedule s) {
    final wake = _drag?.wake ?? windowMinutes(s.window.start);
    final windDown =
        _drag?.windDown ?? windowMinutes(s.window.end) % Duration.minutesPerDay;
    setState(() {
      _end = end;
      _drag = end == DialEnd.wake
          ? (wake: minute, windDown: windDown)
          : (wake: wake, windDown: minute);
    });
    _write?.cancel();
    _write = Timer(DotTouch.dragSettle, _flush);
  }

  /// Writes the dragged times to every day of the selected schedule.
  void _flush() {
    _write?.cancel();
    final drag = _drag;
    if (drag == null) return;
    final days = _selected().days;
    // Stored as the editors store it: 24:30 for 12:30 AM (Q8).
    final window = dayWindow(drag.wake, drag.windDown);
    _save(
      (s) => s.copyWith(
        dayBoundaries: {...s.dayBoundaries, for (final d in days) d: window},
      ),
    );
    _drag = null;
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _selected();
    return LayoutBuilder(
      builder: (context, box) {
        final dial = _DialSide(
          settings: _settings,
          schedule: schedule,
          wake: _drag?.wake ?? windowMinutes(schedule.window.start),
          windDown:
              _drag?.windDown ??
              windowMinutes(schedule.window.end) % Duration.minutesPerDay,
          selected: _end,
          onChanged: (end, m) => _onDial(end, m, schedule),
          onSelect: (end) => setState(() => _end = end),
        );
        final week = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.m,
          children: [
            _AlarmLine(profile: widget.profile),
            WeekTable(
              settings: _settings,
              selected: schedule.days,
              alarmHeader: _alarmHeader(context),
              onSelect: (days) => setState(() {
                _flush();
                _days = days;
              }),
            ),
            const _AddAndRule(),
          ],
        );
        if (box.maxWidth >= DotSize.wwdSideBySide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DotSpace.l,
            children: [
              SizedBox(width: DotSize.wwdDial, child: dial),
              Expanded(child: week),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.m,
          children: [dial, week],
        );
      },
    );
  }

  /// "Alarm (iPhone)": the column names the device that rings.
  String _alarmHeader(BuildContext context) {
    final l10n = context.l10n;
    final device = ref
        .watch(devicesProvider(widget.profile.id))
        .value
        ?.where((d) => d.canRing && d.id == _settings.alarmDeviceId)
        .firstOrNull;
    return device == null
        ? l10n.settingsWakeUpAlarm
        : l10n.wwdColAlarm(deviceKind(l10n, device));
  }
}

/// The dial with the sleep-target line and help: beside it in a narrow
/// pane, under it in the wide one.
class _DialSide extends StatelessWidget {
  const _DialSide({
    required this.settings,
    required this.schedule,
    required this.wake,
    required this.windDown,
    required this.selected,
    required this.onChanged,
    required this.onSelect,
  });

  final Settings settings;
  final DaySchedule schedule;
  final int wake;
  final int windDown;
  final DialEnd selected;
  final void Function(DialEnd end, int minute) onChanged;
  final ValueChanged<DialEnd> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final night = nightMinutes(dayWindow(wake, windDown));
    String endName(DialEnd e) =>
        e == DialEnd.windDown ? l10n.settingsWindDown : l10n.settingsWakeUp;
    final dial = SizedBox(
      width: DotSize.wwdDial,
      child: NightDial(
        windDown: windDown,
        wake: wake,
        selected: selected,
        onChanged: onChanged,
        onSelect: onSelect,
        labels: dialLabels(context, settings.use24h),
        length: formatDurationShort(l10n, night),
        lengthCaption: l10n.schOfNight,
        handleLabel: endName,
        handleValue: (m) =>
            clockText(context, m % Duration.minutesPerDay, settings.use24h),
      ),
    );
    final words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.xs,
      children: [
        if (sleepTargetLine(l10n, settings, night) case final line?)
          Text(
            line,
            style: t.styles.inspectorValue.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        FormHelp(l10n.wwdDialHelp(scheduleName(l10n, schedule.days))),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth < DotSize.wwdDial + DotSize.formControlMin) {
          return Column(spacing: DotSpace.s, children: [dial, words]);
        }
        return Row(
          spacing: DotSpace.l,
          children: [
            dial,
            Expanded(child: words),
          ],
        );
      },
    );
  }
}

/// "Alarm sounds on: iPhone · Ready · confirmed 9:00 AM", that the Mac or
/// the browser never rings, and Change… (E-FullA-v2).
class _AlarmLine extends ConsumerWidget {
  const _AlarmLine({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final self = ref.watch(selfDeviceIdProvider(profile.id)).value;
    final chosen = ref
        .watch(devicesProvider(profile.id))
        .value
        ?.where((d) => d.canRing && d.id == profile.settings.alarmDeviceId)
        .firstOrNull;
    final now = ref.watch(clockProvider).nowUtc();
    final state = alarmDeviceState(chosen, nowUtc: now);
    return Container(
      padding: const EdgeInsets.all(DotSpace.m),
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.monthCard),
        border: Border.all(color: t.colors.outline),
      ),
      child: Row(
        spacing: DotSpace.m,
        children: [
          SettingsIcon(
            glyph: TaskIcon.flipphone.glyph!,
            tint: t.tasks[TaskColor.amber].ink,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.xxs,
              children: [
                Text(
                  chosen == null
                      ? l10n.wwdNoAlarmDevice
                      : l10n.wwdAlarmSoundsOnDevice(
                          deviceLabel(l10n, chosen, self: self),
                        ),
                  style: t.styles.inspectorValue.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  alarmDeviceStateText(context, profile, state, chosen),
                  style: t.styles.inspectorLabel.copyWith(
                    color: state == AlarmDeviceState.ready
                        ? t.colors.success
                        : t.colors.muted,
                  ),
                ),
                FormHelp(
                  webChrome(context)
                      ? l10n.wwdWebNeverRingsLine
                      : l10n.wwdMacNeverRingsLine,
                ),
              ],
            ),
          ),
          FormButton(
            label: l10n.settingsFormOpen(l10n.schChange),
            onPressed: () => unawaited(
              context.push(AppRoutes.settingsPage(SettingsPage.alarmDevice)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Add a schedule… and the table's rule.
class _AddAndRule extends StatelessWidget {
  const _AddAndRule();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: DotSpace.m,
      runSpacing: DotSpace.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FormButton(
          label: l10n.settingsFormOpen(l10n.wwdAddSchedule),
          onPressed: () => unawaited(showScheduleSheet(context)),
        ),
        FormHelp(l10n.wwdTableFoot),
      ],
    );
  }
}
