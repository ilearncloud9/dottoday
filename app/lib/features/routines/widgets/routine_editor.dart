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
import 'package:dottoday/shared/controls/dot_segmented.dart';
import 'package:dottoday/shared/sheets/sheet_nav_bar.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';

/// Edits a routine (derived screen, 11 C2): its name, when it sits on a
/// day (Wake Up, a time, ending at Wind Down) and its steps. Gaps between
/// steps are kept as they were; a new step follows the last one. A leaf:
/// the draft is its only state, handed to [onSave] when valid.
class RoutineEditor extends StatefulWidget {
  const RoutineEditor({
    required this.title,
    required this.initial,
    required this.onSave,
    required this.onCancel,
    this.onDelete,
    this.use24h,
    this.ids = const UuidV7Generator(),
    super.key,
  });

  /// "Edit routine" or "New routine".
  final String title;
  final Routine initial;
  final ValueChanged<Routine> onSave;
  final VoidCallback onCancel;

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
    // E-R2-22: Cancel · Edit routine · Save stays in view; the form
    // scrolls under it.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetNavBar(
          title: widget.title,
          actionLabel: context.l10n.routineSave,
          onCancel: widget.onCancel,
          onAction: _valid ? () => widget.onSave(_draft) : null,
        ),
        const SizedBox(height: DotSpace.s),
        Flexible(child: SingleChildScrollView(child: _form(context))),
      ],
    );
  }

  Widget _form(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: DotSpace.s),
      child: Text(
        text,
        style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        label(l10n.routineName),
        TextField(
          contextMenuBuilder: systemTextMenu,
          controller: _name,
          decoration: InputDecoration(
            hintText: l10n.routineName,
            counterText: '',
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLength: maxTitleLength,
          onChanged: (_) => setState(() {}),
        ),
        label(l10n.routineAnchorLabel),
        _anchorChoice(context),
        if (_anchor == RoutineAnchor.time)
          TimeInput(
            value: ClockTime.fromMinutes(_minute),
            use24h: widget.use24h,
            onChanged: (v) => _edit(() => _minute = v.minutesOfDay),
          ),
        label(l10n.routineStepsLabel),
        _StepsCard(
          children: [
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
          ],
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
              icon: DotIcon(DotGlyphs.add, color: t.colors.accentText),
              label: Text(l10n.routineAddStep),
            ),
          ),
        if (!_valid)
          Text(
            l10n.routineInvalid,
            style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
          ),
        if (widget.onDelete case final delete?)
          TextButton(
            onPressed: delete,
            style: TextButton.styleFrom(foregroundColor: t.colors.ink),
            child: Text(l10n.routineDelete),
          ),
      ],
    );
  }

  Widget _anchorChoice(BuildContext context) {
    final l10n = context.l10n;
    return DotSegmented<RoutineAnchor>(
      segments: [
        (RoutineAnchor.wake, l10n.routineAnchorWake),
        (RoutineAnchor.time, l10n.routineAnchorTime),
        (RoutineAnchor.bed, l10n.routineAnchorBed),
      ],
      selected: _anchor,
      onChanged: (a) => _edit(() => _anchor = a),
    );
  }
}

/// The steps on one card, a hairline between them (E-R2-22).
class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(DotRadii.sheetCard),
        border: Border.all(color: c.hairline, width: DotSpace.hairline),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: DotSpace.xs),
        child: Column(
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0)
                Divider(
                  height: DotSpace.hairline,
                  thickness: DotSpace.hairline,
                  indent: DotTouch.min,
                  color: c.hairline,
                ),
              child,
            ],
          ],
        ),
      ),
    );
  }
}
