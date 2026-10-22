import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/shared/feedback/paste_confirm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The Inbox quick-add field (`A-ios-inbox`): one line per task, natural
/// language ("Call Mum tomorrow 3pm 20m", R-06); a pasted list becomes
/// several tasks (R-07) after an inline "Add N tasks?" — the same as Add's
/// title (03 §3.3, aligned in M3c.5). Enter adds (or confirms the list);
/// Shift+Enter starts a new line.
class InboxAddField extends StatefulWidget {
  const InboxAddField({required this.onSubmit, super.key});

  /// Gets the text; resolves to whether it was added (then the field
  /// clears).
  final Future<bool> Function(String text) onSubmit;

  @override
  State<InboxAddField> createState() => _InboxAddFieldState();
}

class _InboxAddFieldState extends State<InboxAddField> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    if (await widget.onSubmit(text) && mounted) _text.clear();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _field(context),
      ValueListenableBuilder(
        valueListenable: _text,
        builder: (context, value, _) {
          final lines = QuickAddParser.lines(value.text);
          if (lines.length < 2) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: DotSpace.s),
            child: PasteConfirm(
              count: lines.length,
              onAdd: () => unawaited(_submit()),
              onKeepOne: () =>
                  _text.text = QuickAddParser.joinLines(value.text),
            ),
          );
        },
      ),
    ],
  );

  Widget _field(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): () =>
            unawaited(_submit()),
      },
      child: Semantics(
        label: l10n.inboxAddLabel,
        child: TextField(
          controller: _text,
          minLines: 1,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => unawaited(_submit()),
          style: t.styles.body,
          decoration: InputDecoration(
            hintText: l10n.inboxAddHint,
            // Centred: the decoration's 48 dp minimum would stretch it.
            prefixIcon: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: DotIcon(
                DotGlyphs.add,
                color: t.colors.text,
                size: DotSize.rowIcon,
              ),
            ),
            filled: true,
            fillColor: t.colors.raised,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DotRadii.card),
              borderSide: BorderSide(color: t.colors.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DotRadii.card),
              borderSide: BorderSide(color: t.colors.hairline),
            ),
          ),
        ),
      ),
    );
  }
}
