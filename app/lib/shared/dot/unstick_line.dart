import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Unstick (11 B3, docs/09 M10.7): under a task moved three times with no
/// steps, "What's the very first thing you'd physically do?" and a
/// one-line field; the answer becomes step 1. A quiet row — muted, never
/// a modal, never a warning colour (11 §D).
class UnstickLine extends StatefulWidget {
  const UnstickLine({required this.onAnswer, super.key});

  /// The typed first step (trimmed, not empty).
  final ValueChanged<String> onAnswer;

  @override
  State<UnstickLine> createState() => _UnstickLineState();
}

class _UnstickLineState extends State<UnstickLine> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final answer = _text.text.trim();
    if (answer.isEmpty) return;
    widget.onAnswer(answer);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.unstickPrompt,
          style: t.styles.rowMeta.copyWith(color: t.colors.muted),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _text,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                style: t.styles.body,
                decoration: InputDecoration(
                  hintText: l10n.unstickHint,
                  isDense: true,
                  counterText: '',
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            IconButton(
              tooltip: l10n.unstickSave,
              onPressed: _send,
              icon: DotIcon(
                DotGlyphs.arrowRight,
                color: t.colors.accentInk,
                size: DotSize.rowIcon,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
