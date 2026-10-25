import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/features/timeline/editor/editor_fields.dart';
import 'package:dottoday/features/timeline/widgets/note_links.dart';
import 'package:flutter/material.dart';

/// NOTES: the notes as typed, markdown-lite (docs/02 F2.9) — the hint
/// under the field names what is understood; the task sheet shows them
/// rendered (`NoteText`). The LINKS found in them follow, tappable.
/// Owns its text controller (a leaf, CLAUDE.md §4).
class EditorNotes extends StatefulWidget {
  const EditorNotes({required this.notes, required this.onChanged, super.key});

  /// The draft's notes: the field starts from them, the LINKS follow them.
  final String? notes;

  /// The new notes, null when cleared.
  final ValueChanged<String?> onChanged;

  @override
  State<EditorNotes> createState() => _EditorNotesState();
}

class _EditorNotesState extends State<EditorNotes> {
  late final _notes = TextEditingController(text: widget.notes ?? '');

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorCaption(l10n.editorNotes),
        TextField(
          controller: _notes,
          minLines: 3,
          maxLines: 8,
          maxLength: maxNotesLength,
          // The PRD limit (F2.9) holds without a counter under every note.
          buildCounter: _noCounter,
          decoration: InputDecoration(
            hintText: l10n.editorNotesHint,
            helperText: l10n.editorNotesFormat,
            helperMaxLines: 2,
          ),
          onChanged: (v) => widget.onChanged(v.isEmpty ? null : v),
        ),
        NoteLinks(notes: widget.notes),
      ],
    );
  }

  static Widget? _noCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) => null;
}
