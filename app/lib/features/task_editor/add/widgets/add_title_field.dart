import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/shared/feedback/paste_confirm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Longest title text accepted; the parser rejects more (06 §7).
const _maxInput = 10000;

/// The Add title field (`A-ios-add-what`): natural language fills the time
/// and length as you type (R-06); recognised pieces show as chips that one
/// tap removes (docs/02 F2). Enter adds at once, Shift+Enter adds and
/// starts another; a pasted list asks "Add N tasks?" (03 §3.3, M3c.5).
///
/// A leaf: it owns only the controller and mirrors [text] when the flow
/// changes it (a picked suggestion).
class AddTitleField extends StatefulWidget {
  const AddTitleField({
    required this.text,
    required this.typed,
    required this.onChanged,
    required this.onSubmit,
    required this.onAnother,
    required this.onAddMany,
    super.key,
  });

  final String text;

  /// The current parse of [text], for the token chips.
  final QuickAddDraft typed;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  /// Shift+Enter: add, keep the sheet, start the next task.
  final VoidCallback onAnother;

  /// A pasted list confirmed: add every line.
  final VoidCallback onAddMany;

  @override
  State<AddTitleField> createState() => _AddTitleFieldState();
}

class _AddTitleFieldState extends State<AddTitleField> {
  late final _controller = TextEditingController(text: widget.text);

  @override
  void didUpdateWidget(AddTitleField old) {
    super.didUpdateWidget(old);
    if (widget.text != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _remove(QuickAddToken token) =>
      widget.onChanged(textWithout(widget.typed, token));

  @override
  Widget build(BuildContext context) {
    final lines = QuickAddParser.lines(widget.text);
    final many = lines.length > 1;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): many
            ? widget.onAddMany
            : widget.onSubmit,
        const SingleActivator(LogicalKeyboardKey.enter, shift: true): many
            ? widget.onAddMany
            : widget.onAnother,
      },
      child: _field(context, lines),
    );
  }

  Widget _field(BuildContext context, List<String> lines) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final tokens = widget.typed.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          style: t.styles.topBarTitle,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          // Not one line: a pasted list keeps its line breaks (R-07).
          minLines: 1,
          maxLines: null,
          inputFormatters: [LengthLimitingTextInputFormatter(_maxInput)],
          decoration: InputDecoration(
            labelText: l10n.addTitleLabel,
            hintText: l10n.editorTitleHint,
          ),
          onChanged: widget.onChanged,
          onSubmitted: (_) =>
              lines.length > 1 ? widget.onAddMany() : widget.onSubmit(),
        ),
        if (lines.length > 1)
          PasteConfirm(
            count: lines.length,
            onAdd: widget.onAddMany,
            onKeepOne: () =>
                widget.onChanged(QuickAddParser.joinLines(widget.text)),
          )
        else if (tokens.isEmpty)
          Text(l10n.addTypeTimeHint, style: t.styles.rowMeta)
        else
          Wrap(
            spacing: DotSpace.s,
            runSpacing: DotSpace.xs,
            children: [
              for (final token in tokens)
                if (token.end <= widget.typed.text.length)
                  _TokenChip(
                    text: widget.typed.text.substring(token.start, token.end),
                    onRemove: () => _remove(token),
                  ),
            ],
          ),
      ],
    );
  }
}

class _TokenChip extends StatelessWidget {
  const _TokenChip({required this.text, required this.onRemove});

  final String text;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return InputChip(
      label: Text(text, style: t.styles.rowMeta),
      backgroundColor: t.colors.accentTint,
      side: BorderSide.none,
      shape: dotChipShape(context),
      deleteIcon: DotIcon(
        DotGlyphs.close,
        color: t.colors.accentInk,
        size: DotSize.rowIcon - DotSpace.xs,
      ),
      deleteButtonTooltipMessage: context.l10n.addRemoveToken(text),
      onDeleted: onRemove,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
