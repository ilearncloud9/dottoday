import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/speech/dictation_text.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/features/timeline/editor/editor_fields.dart';
import 'package:dottoday/features/timeline/widgets/dictation_mic.dart';
import 'package:dottoday/features/timeline/widgets/note_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// NOTES: the notes as typed, markdown-lite (docs/02 F2.9) — the hint
/// under the field names what is understood; the task sheet shows them
/// rendered (`NoteText`). The LINKS found in them follow, tappable.
/// Where on-device speech exists, a mic in the field's bottom-end corner
/// dictates at the cursor like the keyboard's mic: no commands, no pause
/// lines (docs/09 M14.6, D6). Owns its text controller (a leaf, §4).
class EditorNotes extends ConsumerStatefulWidget {
  const EditorNotes({required this.notes, required this.onChanged, super.key});

  /// The draft's notes: the field starts from them, the LINKS follow them.
  final String? notes;

  /// The new notes, null when cleared.
  final ValueChanged<String?> onChanged;

  @override
  ConsumerState<EditorNotes> createState() => _EditorNotesState();
}

class _EditorNotesState extends ConsumerState<EditorNotes> {
  late final _notes = TextEditingController(text: widget.notes ?? '');
  final _focus = FocusNode();
  late String _reported = _notes.text;

  @override
  void initState() {
    super.initState();
    // Typed or dictated: both reach the draft.
    _notes.addListener(_report);
  }

  void _report() {
    final v = _notes.text;
    if (v == _reported) return;
    _reported = v;
    widget.onChanged(v.isEmpty ? null : v);
  }

  @override
  void dispose() {
    _notes.removeListener(_report);
    _notes.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mic = micAvailable(ref, context) ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorCaption(l10n.editorNotes),
        if (mic) _withMic(context) else _field(helper: l10n.editorNotesFormat),
        NoteLinks(notes: widget.notes),
      ],
    );
  }

  /// The field with the mic inside its bottom-end corner; the format help
  /// moves under the box so the mic sits on the box, not the help.
  Widget _withMic(BuildContext context) {
    final t = DotTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            _field(endPadding: DotTouch.android),
            PositionedDirectional(
              end: DotSpace.xxs,
              bottom: DotSpace.xxs,
              child: DictationMic(
                field: _notes,
                focus: _focus,
                mode: DictationMode.plain,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            DotSpace.m,
            DotSpace.xs,
            DotSpace.m,
            0,
          ),
          child: Text(
            context.l10n.editorNotesFormat,
            style: t.styles.rowMeta.copyWith(color: t.colors.muted),
          ),
        ),
        DictationNotice(field: _notes),
      ],
    );
  }

  Widget _field({String? helper, double? endPadding}) => TextField(
    controller: _notes,
    focusNode: _focus,
    minLines: 3,
    maxLines: 8,
    maxLength: maxNotesLength,
    // The PRD limit (F2.9) holds without a counter under every note.
    buildCounter: _noCounter,
    decoration: InputDecoration(
      hintText: context.l10n.editorNotesHint,
      helperText: helper,
      helperMaxLines: 2,
      contentPadding: endPadding == null
          ? null
          : EdgeInsetsDirectional.fromSTEB(
              DotSpace.m,
              DotSpace.m,
              endPadding,
              DotSpace.m,
            ),
    ),
  );

  static Widget? _noCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) => null;
}
