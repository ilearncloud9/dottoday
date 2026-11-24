import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/schedule_edit.dart';
import 'package:dottoday/domain/time/schedules.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_body.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_text.dart';
import 'package:dottoday/features/settings/widgets/settings_change.dart';
import 'package:dottoday/shared/dot/night_dial.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/sheets/dot_alert.dart';
import 'package:dottoday/shared/sheets/sheet_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the sheet closed with: a schedule to save, or Remove.
typedef ScheduleOutcome = ({ScheduleDraft? save, bool remove});

/// The schedule sheet (E-Phones Edit Weekdays, Weekend, New schedule;
/// Android Edit Weekdays; ED-084, ED-448): opens [days]' schedule, or a
/// new one when null. Save writes it; Remove sends its days back to the
/// default day with Undo. Nothing is written before Save or Remove.
Future<void> showScheduleSheet(
  BuildContext context, {
  List<Weekday>? days,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  // The scaffold the toast shows in: a pane on an iPad (Settings beside
  // the sidebar), the whole window elsewhere.
  final paneWidth = Scaffold.maybeOf(context)?.context.size?.width;
  final l10n = context.l10n;
  final settings = (await container.read(
    currentProfileProvider.future,
  )).settings;
  if (!context.mounted) return;
  final before = {...?days};
  final outcome = await showAppSheet<ScheduleOutcome>(
    context: context,
    fullHeight: true,
    builder: (sheet) => ScheduleSheet(settings: settings, before: before),
  );
  if (outcome == null || !context.mounted) return;
  if (outcome.save case final draft?) {
    changeSettings(
      context,
      (s) => saveSchedule(s, before: before, draft: draft),
    );
    return;
  }
  if (!outcome.remove) return;
  changeSettings(context, (s) => removeSchedule(s, before));
  showUndoSnackbarOn(
    messenger,
    l10n,
    message: l10n.schRemoved(scheduleName(l10n, before)),
    paneWidth: paneWidth,
    onUndo: () => changeSettings(
      context,
      (s) => s.copyWith(
        dayBoundaries: settings.dayBoundaries,
        wakeUpAlarmDays: settings.wakeUpAlarmDays,
        windDownReminderDays: settings.windDownReminderDays,
      ),
    ),
  );
}

/// The sheet: Cancel · name · Save (Add for a new one) over the days,
/// the dial, the times, the checks and the options. A leaf: holds the
/// draft until Save.
class ScheduleSheet extends ConsumerStatefulWidget {
  const ScheduleSheet({
    required this.settings,
    required this.before,
    super.key,
  });

  /// The settings when it opened; the live ones feed Sound and snooze.
  final Settings settings;

  /// The schedule's days, or empty for a new one.
  final Set<Weekday> before;

  @override
  ConsumerState<ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends ConsumerState<ScheduleSheet> {
  late final Settings _s = widget.settings;
  late Set<Weekday> _days = {...widget.before};
  late TimeWindow _window = widget.before.isEmpty
      ? Settings.defaultDayBoundary
      : _s.boundaryFor(widget.before.first);
  late bool _ring =
      widget.before.isEmpty || widget.before.every(_s.wakeUpAlarmDays.contains);
  late bool _remind =
      widget.before.isEmpty ||
      widget.before.every(_s.windDownReminderDays.contains);
  DialEnd _selected = DialEnd.wake;
  DialEnd? _focused;

  bool get _isNew => widget.before.isEmpty;

  ScheduleDraft get _draft =>
      (days: _days, window: _window, ring: _ring, remind: _remind);

  int get _wake => windowMinutes(_window.start) % Duration.minutesPerDay;
  int get _windDown => windowMinutes(_window.end) % Duration.minutesPerDay;

  /// Each day in another schedule, with that schedule's name.
  late final Map<Weekday, String> _others = {
    for (final s in schedulesOf(_s))
      for (final d in s.days)
        if (!widget.before.contains(d)) d: scheduleName(context.l10n, s.days),
  };

  void _setTime(DialEnd end, int minute) => setState(() {
    _selected = end;
    _window = end == DialEnd.wake
        ? dayWindow(minute, _windDown)
        : dayWindow(_wake, minute);
  });

  /// A tap on a day: on and off for this schedule's own days; another
  /// schedule's day asks first (owner 2026-11-24: "This day already has a
  /// schedule · Would you like to change it?").
  Future<void> _tapDay(Weekday d) async {
    if (_days.contains(d) || !_others.containsKey(d)) {
      setState(
        () =>
            _days = _days.contains(d) ? ({..._days}..remove(d)) : {..._days, d},
      );
      return;
    }
    final l10n = context.l10n;
    final change = await showChoiceAlert<bool>(
      context,
      title: l10n.schTakenTitle,
      message: l10n.schTakenMessage,
      choices: [
        AlertChoice(
          label: MaterialLocalizations.of(context).cancelButtonLabel,
          value: false,
          cancel: true,
        ),
        AlertChoice(label: l10n.schChange, value: true, primary: true),
      ],
    );
    if (change ?? false) setState(() => _days = {..._days, d});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final live =
        ref.watch(currentProfileProvider).value?.settings ?? widget.settings;
    final action = _isNew ? l10n.schAdd : l10n.schSave;
    final ready = !blocksSave(scheduleChecks(_draft));
    void close(ScheduleOutcome o) => Navigator.of(context).pop(o);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: DotSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetNavBar(
            title: _isNew ? l10n.schNew : scheduleName(l10n, widget.before),
            actionLabel: action,
            filledOnAndroid: true,
            onCancel: () => Navigator.of(context).pop(),
            onAction: ready ? () => close((save: _draft, remove: false)) : null,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: DotSpace.xxl),
              child: ScheduleBody(
                settings: live,
                draft: _draft,
                others: _others,
                action: action,
                wake: _wake,
                windDown: _windDown,
                selected: _selected,
                focused: _focused,
                onDay: (d) => unawaited(_tapDay(d)),
                onTime: _setTime,
                onSelect: (e) => setState(() => _selected = e),
                onFocus: (e) => setState(() => _focused = e),
                onRing: (v) => setState(() => _ring = v),
                onRemind: (v) => setState(() => _remind = v),
                onRemove: _isNew
                    ? null
                    : () => close((save: null, remove: true)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
