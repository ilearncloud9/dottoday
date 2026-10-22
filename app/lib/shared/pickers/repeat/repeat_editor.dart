import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_end.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_parts.dart';
import 'package:dottoday/shared/pickers/repeat/repeat_text.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// What the Repeat editor returned: a rule, or null for "Never".
typedef RepeatResult = ({RepeatRule? rule});

/// The Repeat editor (docs/10 §5.3, docs/09 M3f.1, R-01): never, every
/// day, every weekday, every week on chosen days, every month by date or
/// by weekday, every year, or every N days / weeks / months; ending never,
/// after N times or on a date. The summary reads back the rule as it
/// stands. [start] is the instance's local date. Null = dismissed.
Future<RepeatResult?> showRepeatEditor(
  BuildContext context, {
  required RepeatRule? initial,
  required DateTime start,
  required DateTime today,
  int firstDayOfWeek = 1,
}) => showAppSheet<RepeatResult>(
  context: context,
  title: context.l10n.repeatTitle,
  builder: (_) => _RepeatEditor(
    initial: initial,
    start: start,
    today: today,
    firstDayOfWeek: firstDayOfWeek,
  ),
);

class _RepeatEditor extends StatefulWidget {
  const _RepeatEditor({
    required this.initial,
    required this.start,
    required this.today,
    required this.firstDayOfWeek,
  });

  final RepeatRule? initial;
  final DateTime start;
  final DateTime today;
  final int firstDayOfWeek;

  @override
  State<_RepeatEditor> createState() => _RepeatEditorState();
}

/// A leaf: the rule being built.
class _RepeatEditorState extends State<_RepeatEditor> {
  late RepeatChoice _choice = RepeatChoice.of(widget.initial);
  late RepeatRule _rule =
      widget.initial ??
      RepeatRule(frequency: RepeatFrequency.weekly, days: {_startDay});

  Weekday get _startDay => Weekday.values[widget.start.weekday - 1];

  /// The rule the current choice means; null for Never.
  RepeatRule? get _result => switch (_choice) {
    RepeatChoice.never => null,
    RepeatChoice.daily => _rule.copyWith(
      frequency: RepeatFrequency.daily,
      interval: 1,
    ),
    RepeatChoice.weekdays => RepeatRule.weekdays(end: _rule.end),
    RepeatChoice.weekly => _rule.copyWith(
      frequency: RepeatFrequency.weekly,
      interval: 1,
      days: _rule.days.isEmpty ? {_startDay} : _rule.days,
    ),
    RepeatChoice.monthly => _rule.copyWith(
      frequency: RepeatFrequency.monthly,
      interval: 1,
    ),
    RepeatChoice.yearly => _rule.copyWith(
      frequency: RepeatFrequency.yearly,
      interval: 1,
    ),
    RepeatChoice.custom => _rule,
  };

  void _pick(RepeatChoice c) => setState(() {
    _choice = c;
    if (c == RepeatChoice.custom && _rule.frequency == RepeatFrequency.yearly) {
      _rule = _rule.copyWith(frequency: RepeatFrequency.weekly);
    }
  });

  void _edit(RepeatRule Function(RepeatRule) f) =>
      setState(() => _rule = f(_rule));

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final result = _result;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            result == null
                ? l10n.sheetNever
                : repeatRuleText(l10n, locale, result, widget.start),
            style: t.styles.body.copyWith(color: t.colors.accentInk),
          ),
        ),
        RepeatChoices(
          choice: _choice,
          rule: _rule,
          start: widget.start,
          onPick: _pick,
          onRule: _edit,
        ),
        if (_choice != RepeatChoice.never)
          RepeatEndRow(
            end: _rule.end,
            start: widget.start,
            today: widget.today,
            firstDayOfWeek: widget.firstDayOfWeek,
            onEnd: (e) => _edit((r) => r.copyWith(end: e)),
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((rule: result)),
          child: Text(l10n.repeatDone),
        ),
      ],
    );
  }
}
