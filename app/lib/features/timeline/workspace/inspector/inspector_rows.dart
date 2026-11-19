import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/schedule/planned_colors.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/timeline/editor/editor_series.dart';
import 'package:dottoday/features/timeline/state/task_text.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_write.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/pickers/alerts/alerts_editor.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Date, Time, Repeat and Alerts beside their 58 labels (E-FullA-v2).
/// Each change is written at once (ED-086); the day keeps the wall time,
/// the start keeps the length, the end sets the length.
class InspectorRows extends ConsumerWidget {
  const InspectorRows({required this.task, super.key});

  final TaskView task;

  Occurrence get _o => task.occurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final start = _o.startUtc;
    return Column(
      spacing: DotSpace.s + DotSpace.xxs,
      children: [
        if (start != null) ...[
          _Row(label: l10n.inspectorDate, child: _date(context, ref, start)),
          _Row(label: l10n.timeInputLabel, child: _time(context, ref, start)),
          _Row(
            label: l10n.sheetRepeat,
            child: _Field(
              text: repeatText(
                l10n,
                Localizations.localeOf(context).toLanguageTag(),
                task.series?.rrule,
              ),
              chevron: true,
              onTap: () =>
                  unawaited(pickRepeat(context, task: task, draft: _o)),
            ),
          ),
        ],
        _Row(label: l10n.sheetAlerts, top: true, child: _alerts(context, ref)),
      ],
    );
  }

  Widget _date(BuildContext context, WidgetRef ref, DateTime start) {
    final zone = tz.getLocation(_o.tzId);
    final local = tz.TZDateTime.from(start, zone);
    final day = DateTime(local.year, local.month, local.day);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return _Field(
      text: DateFormat.yMMMEd(locale).format(day),
      onTap: () => unawaited(_pickDay(context, ref, day, zone)),
    );
  }

  Future<void> _pickDay(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    tz.Location zone,
  ) async {
    final settings = ref.read(currentProfileProvider).value?.settings;
    final picked = await showMonthDayPicker(
      context,
      title: context.l10n.editorPickDay,
      today: ref.read(todayDateProvider).value ?? day,
      initial: day,
      firstDayOfWeek: settings?.firstDayOfWeek ?? 1,
      plannedFor: (m) =>
          plannedColors(ProviderScope.containerOf(context, listen: false), m),
    );
    if (picked == null || picked == day || !context.mounted) return;
    final time = ClockTime.ofUtc(zone, _o.startUtc!);
    await writeInspected(
      context,
      ref,
      _o.copyWith(startUtc: time.onDate(zone, picked)),
    );
  }

  Widget _time(BuildContext context, WidgetRef ref, DateTime start) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final zone = tz.getLocation(_o.tzId);
    final end = _o.endUtc!;
    final local = tz.TZDateTime.from(start, zone);
    final day = DateTime(local.year, local.month, local.day);
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    final sizes = InspectorSizes.of(context, ref);
    Widget box(ClockTime value, String label, ValueChanged<ClockTime> to) =>
        SizedBox(
          width: DotSize.inspectorTime,
          height: sizes.field,
          child: TimeInput(
            value: value,
            use24h: use24h,
            label: label,
            compact: true,
            onChanged: to,
          ),
        );
    return Wrap(
      spacing: DotSpace.xs,
      runSpacing: DotSpace.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        box(ClockTime.ofUtc(zone, start), l10n.editorStart, (v) {
          unawaited(
            writeInspected(
              context,
              ref,
              _o.copyWith(startUtc: v.onDate(zone, day)),
            ),
          );
        }),
        Text('–', style: t.styles.inspectorLabel), // l10n-ignore: a dash
        box(ClockTime.ofUtc(zone, end), l10n.inspectorEnd, (v) {
          final to = v.onDate(zone, day);
          final minutes = to.difference(start).inMinutes;
          if (minutes <= 0) return;
          unawaited(
            writeInspected(context, ref, _o.copyWith(durationMin: minutes)),
          );
        }),
        Text(
          formatDurationShort(l10n, _o.durationMin),
          style: t.styles.inspectorLabel,
        ),
      ],
    );
  }

  Widget _alerts(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    void open() => unawaited(
      pickAlerts(
        context,
        task: task,
        draft: _o,
        onOwn: (a) =>
            unawaited(writeInspected(context, ref, _o.copyWith(alerts: a))),
      ),
    );
    return Wrap(
      spacing: DotSpace.xs,
      runSpacing: DotSpace.xs,
      children: [
        for (final a in task.alerts)
          _AlertChip(text: _sentence(alertLabel(l10n, a)), onTap: open),
        _AlertChip(text: l10n.inspectorAddAlert, onTap: open, add: true),
      ],
    );
  }

  /// "at start" as a chip starts with a capital: "At start".
  static String _sentence(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// A label in the 58 column and its control.
class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child, this.top = false});

  final String label;
  final Widget child;

  /// The label sits at the top of a control that wraps (Alerts).
  final bool top;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      crossAxisAlignment: top
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      spacing: DotSpace.s,
      children: [
        SizedBox(
          width: DotSize.inspectorLabel,
          child: Padding(
            padding: EdgeInsets.only(top: top ? DotSpace.xs : 0),
            child: Text(label, style: t.styles.inspectorLabel),
          ),
        ),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: child,
          ),
        ),
      ],
    );
  }
}

/// A 26-tall field button: "Tue 3 Nov 2026", "Never ▾".
class _Field extends ConsumerWidget {
  const _Field({required this.text, required this.onTap, this.chevron = false});

  final String text;
  final VoidCallback onTap;
  final bool chevron;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DotRadii.field),
      side: BorderSide(color: c.hairlineStrong),
    );
    return Material(
      color: c.raised,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Container(
          constraints: BoxConstraints(
            minHeight: InspectorSizes.of(context, ref).field,
          ),
          padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.xs,
            children: [
              Flexible(child: Text(text, style: t.styles.inspectorValue)),
              if (chevron)
                DotIcon(
                  DotGlyphs.chevronDown,
                  color: c.ink2,
                  size: DotSize.inspectorChevron,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An alert as a teal chip, or the outlined "Add alert".
class _AlertChip extends ConsumerWidget {
  const _AlertChip({required this.text, required this.onTap, this.add = false});

  final String text;
  final VoidCallback onTap;
  final bool add;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final shape = StadiumBorder(
      side: add ? BorderSide(color: c.hairlineStrong) : BorderSide.none,
    );
    return Material(
      color: add ? Colors.transparent : c.accentTint,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Container(
          height: InspectorSizes.of(context, ref).chip,
          padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
          child: Center(
            widthFactor: 1,
            child: Text(
              text,
              style: t.styles.inspectorChip.copyWith(
                color: add ? c.ink2 : c.accentInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
