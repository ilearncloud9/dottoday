import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/domain/validation/routine_validator.dart';
import 'package:dottoday/features/routines/widgets/routine_step_row.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';

/// Edits a routine (derived screen, 11 C2): its name, when it sits on a
/// day (Wake Up, a time, ending at Bedtime) and its steps. Gaps between
/// steps are kept as they were; a new step follows the last one. A leaf:
/// the draft is its only state, handed to [onSave] when valid.
class RoutineEditor extends StatefulWidget {
  const RoutineEditor({
    required this.initial,
    required this.onSave,
    this.onDelete,
    this.use24h,
    this.ids = const UuidV7Generator(),
    super.key,
  });

  final Routine initial;
  final ValueChanged<Routine> onSave;

  /// Shown for a saved routine; null for a new one.
  final VoidCallback? onDelete;
  final bool? use24h;
  final IdGenerator ids;

  @override
  State<RoutineEditor> createState() => _RoutineEditorState();
}

class _RoutineEditorState extends State<RoutineEditor> {
  late final _name = TextEditingController(text: widget.initial.title);
  late RoutineAnchor _anchor = widget.initial.anchor;
  late int _minute = widget.initial.anchorMinute ?? 9 * 60;
  late List<RoutineStepDraft> _steps = RoutineStepDraft.fromItems(
    widget.initial.items,
  );

  @override
  void dispose() {
    _name.dispose();
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  Routine get _draft => widget.initial.copyWith(
    title: _name.text,
    anchor: _anchor,
    anchorMinute: _anchor == RoutineAnchor.time ? _minute : null,
    items: RoutineStepDraft.toItems(_steps, language: context.l10n.localeName),
  );

  bool get _valid => validateRoutine(_draft) is Ok;

  void _edit(VoidCallback change) => setState(change);

  void _move(int from, int to) => _edit(() {
    final s = _steps.removeAt(from);
    _steps.insert(to, s);
  });

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        TextField(
          controller: _name,
          decoration: InputDecoration(labelText: l10n.routineName),
          textCapitalization: TextCapitalization.sentences,
          maxLength: maxTitleLength,
          onChanged: (_) => setState(() {}),
        ),
        Text(l10n.routineAnchorLabel.toUpperCase(), style: t.styles.caption),
        _anchorChoice(context),
        if (_anchor == RoutineAnchor.time)
          TimeInput(
            value: ClockTime.fromMinutes(_minute),
            use24h: widget.use24h,
            onChanged: (v) => _edit(() => _minute = v.minutesOfDay),
          ),
        Text(l10n.routineStepsLabel.toUpperCase(), style: t.styles.caption),
        for (final (i, s) in _steps.indexed)
          RoutineStepRow(
            key: ObjectKey(s),
            step: s,
            first: i == 0,
            onChanged: () => setState(() {}),
            onUp: i == 0 ? null : () => _move(i, i - 1),
            onDown: i == _steps.length - 1 ? null : () => _move(i, i + 1),
            onRemove: _steps.length == 1
                ? null
                : () => _edit(() => _steps.removeAt(i).dispose()),
          ),
        if (_steps.length < maxRoutineItems)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _edit(
                () => _steps = [
                  ..._steps,
                  RoutineStepDraft.blank(widget.ids.newId(), _steps.length),
                ],
              ),
              icon: DotIcon(DotGlyphs.add, color: t.colors.accentInk),
              label: Text(l10n.routineAddStep),
            ),
          ),
        if (!_valid)
          Text(
            l10n.routineInvalid,
            style: t.styles.rowMeta.copyWith(color: t.colors.muted),
          ),
        FilledButton(
          onPressed: _valid ? () => widget.onSave(_draft) : null,
          child: Text(l10n.routineSave),
        ),
        if (widget.onDelete case final delete?)
          TextButton(onPressed: delete, child: Text(l10n.routineDelete)),
      ],
    );
  }

  Widget _anchorChoice(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<RoutineAnchor>(
      segments: [
        ButtonSegment(
          value: RoutineAnchor.wake,
          label: Text(l10n.routineAnchorWake),
        ),
        ButtonSegment(
          value: RoutineAnchor.time,
          label: Text(l10n.routineAnchorTime),
        ),
        ButtonSegment(
          value: RoutineAnchor.bed,
          label: Text(l10n.routineAnchorBed),
        ),
      ],
      selected: {_anchor},
      showSelectedIcon: false,
      onSelectionChanged: (s) => _edit(() => _anchor = s.first),
    );
  }
}
