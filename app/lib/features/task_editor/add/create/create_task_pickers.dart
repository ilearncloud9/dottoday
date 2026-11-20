import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/quick_add/add_draft.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/duration_presets.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/shared/duration/duration_sheet.dart';
import 'package:dottoday/shared/pickers/alerts/alerts_editor.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:dottoday/shared/pickers/look/look_sheet.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_editor.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:dottoday/shared/time_input/time_input_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What Create task's rows and pills open (ED-140): each picks one value
/// into the draft and writes nothing (the task is written on Create).
final class CreateTaskPickers {
  const CreateTaskPickers(this.context, this.ref, this.request);

  final BuildContext context;
  final WidgetRef ref;
  final AddRequest request;

  AddFlow get _flow => ref.read(addFlowProvider(request).notifier);
  AddDraft? get _draft => ref.read(addFlowProvider(request)).value?.draft;
  Settings? get _settings => ref.read(currentProfileProvider).value?.settings;

  /// Colour and icon, pointing at the dot at [anchor] where it is a
  /// popover.
  Future<void> look({Rect? anchor}) async {
    final d = _draft;
    if (d == null) return;
    // Live: the header behind recolours as you pick (ED-161).
    await showTaskLook(
      context,
      colour: TaskColor.fromKey(d.color),
      icon: TaskIcon.fromKey(d.icon),
      title: d.title,
      anchor: anchor,
      onChanged: (l) =>
          _flow.edit((x) => x.withColor(l.color.key).withIcon(l.icon.key)),
    );
  }

  Future<void> day() async {
    final d = _draft;
    if (d == null) return;
    final picked = await showMonthDayPicker(
      context,
      initial: d.day,
      today: d.today,
      firstDayOfWeek: _settings?.firstDayOfWeek ?? 1,
    );
    if (picked != null) _flow.edit((x) => x.withDay(picked));
  }

  /// The start; [startMinute] is the time shown (the first free slot when
  /// none was typed).
  Future<void> time(int startMinute) async {
    final picked = await showTimeInputSheet(
      context,
      title: context.l10n.addTimeCaption,
      initial: ClockTime.fromMinutes(startMinute),
      use24h: _settings?.use24h,
    );
    if (picked != null) {
      _flow.edit((x) => x.withStartMinute(picked.minutesOfDay));
    }
  }

  Future<void> length() async {
    final d = _draft;
    if (d == null) return;
    final container = ProviderScope.containerOf(context);
    final picked = await showDurationSheet(
      context,
      initial: d.length,
      color: TaskColor.fromKey(d.color),
      icon: TaskIcon.fromKey(d.icon),
      presets: _settings?.durationPresets ?? defaultDurationPresets,
      onPresets: (p) => unawaited(
        updateSettings(container, (s) => s.copyWith(durationPresets: p)),
      ),
    );
    if (picked != null) _flow.edit((x) => x.withDuration(picked));
  }

  Future<void> alerts() async {
    final d = _draft;
    if (d == null) return;
    final picked = await showAlertsEditor(
      context,
      initial: d.details.alerts ?? _settings?.defaultAlerts ?? const [],
    );
    if (picked == null) return;
    _flow.edit((x) => x.withDetails(x.details.copyWith(alerts: () => picked)));
  }

  Future<void> repeat() async {
    final d = _draft;
    if (d == null) return;
    final typed = d.rrule;
    final picked = await showRepeatEditor(
      context,
      initial:
          d.details.repeat?.rule ??
          (typed == null ? null : RepeatRule.parse(typed)),
      start: d.day,
      today: d.today,
      firstDayOfWeek: _settings?.firstDayOfWeek ?? 1,
    );
    if (picked == null) return;
    _flow.edit(
      (x) =>
          x.withDetails(x.details.copyWith(repeat: () => (rule: picked.rule))),
    );
  }

  Future<void> energy() async {
    final d = _draft;
    if (d == null) return;
    final l10n = context.l10n;
    // By index, -1 for none: a dismissed sheet (null) changes nothing.
    final picked = await showChoiceSheet<int>(
      context,
      title: l10n.editorEnergy,
      selected: d.details.energy?.index ?? -1,
      options: [
        (value: -1, label: l10n.sheetNoAlerts, detail: null),
        for (final e in Energy.values)
          (value: e.index, label: energyName(l10n, e), detail: null),
      ],
    );
    if (picked == null) return;
    final energy = picked < 0 ? null : Energy.values[picked];
    _flow.edit((x) => x.withDetails(x.details.copyWith(energy: () => energy)));
  }
}

/// "Low", "Medium", "High".
String energyName(AppLocalizations l10n, Energy e) => switch (e) {
  Energy.low => l10n.energyLow,
  Energy.medium => l10n.energyMedium,
  Energy.high => l10n.energyHigh,
};
