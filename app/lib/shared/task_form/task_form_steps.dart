import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Steps and Notes in one card (option D, ED-137; Create task, ED-140):
/// "Steps" over the steps and an "Add a step" field, then "Notes" over
/// the notes field. Return on a step with text adds it and keeps the
/// field for the next; Return on an empty one hides the keyboard, so no
/// blank step is ever made (handoff G3-7).
class TaskFormSteps extends StatefulWidget {
  const TaskFormSteps({
    required this.stepsCaption,
    required this.addStepHint,
    required this.notesCaption,
    required this.notesHint,
    required this.steps,
    required this.onAddStep,
    required this.notes,
    required this.onNotes,
    this.onRemoveStep,
    this.removeLabel,
    super.key,
  });

  final String stepsCaption;
  final String addStepHint;
  final String notesCaption;
  final String notesHint;
  final List<String> steps;
  final ValueChanged<String> onAddStep;

  /// Takes a step out again, by index; null keeps them.
  final ValueChanged<int>? onRemoveStep;

  /// "Remove “{step}”" for a screen reader and the tooltip.
  final String Function(String step)? removeLabel;
  final String notes;
  final ValueChanged<String> onNotes;

  @override
  State<TaskFormSteps> createState() => _TaskFormStepsState();
}

class _TaskFormStepsState extends State<TaskFormSteps> {
  // Leaf view state (CLAUDE.md §4): the two fields' text.
  final _step = TextEditingController();
  final _stepFocus = FocusNode();
  late final _notes = TextEditingController(text: widget.notes);

  @override
  void dispose() {
    _step.dispose();
    _stepFocus.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _add(String text) {
    final step = text.trim();
    if (step.isEmpty) return _stepFocus.unfocus();
    widget.onAddStep(step);
    _step.clear();
    _stepFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    Widget caption(String text) => Padding(
      padding: const EdgeInsets.only(bottom: DotSpace.xs),
      child: Semantics(
        header: true,
        child: Text(text, style: t.styles.caption),
      ),
    );
    return Material(
      color: t.colors.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        side: BorderSide(color: t.colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            caption(widget.stepsCaption),
            for (final (i, s) in widget.steps.indexed) _stepRow(t, i, s),
            _addRow(t),
            Divider(height: DotSpace.l, color: t.colors.outline),
            caption(widget.notesCaption),
            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: t.styles.body,
              onChanged: widget.onNotes,
              decoration: InputDecoration.collapsed(
                hintText: widget.notesHint,
                hintStyle: t.styles.body.copyWith(color: t.colors.placeholder),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(DotTheme t) => Container(
    width: DotSize.stepBox,
    height: DotSize.stepBox,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(DotRadii.field),
      border: Border.all(color: t.colors.controlOutline, width: 2),
    ),
  );

  Widget _stepRow(DotTheme t, int i, String step) {
    final remove = widget.onRemoveStep;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: DotTouch.android),
      child: Row(
        spacing: DotSpace.m,
        children: [
          ExcludeSemantics(child: _box(t)),
          Expanded(child: Text(step, style: t.styles.body)),
          if (remove != null)
            IconButton(
              tooltip: widget.removeLabel?.call(step),
              onPressed: () => remove(i),
              icon: DotIcon(
                DotGlyphs.close,
                color: t.colors.muted,
                size: DotSize.sidebarGlyph,
              ),
            ),
        ],
      ),
    );
  }

  Widget _addRow(DotTheme t) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: DotTouch.android),
    child: Row(
      spacing: DotSpace.m,
      children: [
        ExcludeSemantics(child: _box(t)),
        Expanded(
          child: TextField(
            controller: _step,
            focusNode: _stepFocus,
            textInputAction: TextInputAction.unspecified,
            textCapitalization: TextCapitalization.sentences,
            style: t.styles.body,
            onSubmitted: _add,
            // The field itself is the 44 pt target, not just its line.
            decoration: InputDecoration(
              hintText: widget.addStepHint,
              hintStyle: t.styles.body.copyWith(color: t.colors.placeholder),
              border: InputBorder.none,
              isDense: true,
              // 22 of text and 2 × 13 around it: 48, centred on the box.
              contentPadding: const EdgeInsets.symmetric(
                vertical: (DotTouch.android - DotSize.stepBox) / 2,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
