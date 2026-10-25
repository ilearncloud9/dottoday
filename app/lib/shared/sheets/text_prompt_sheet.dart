import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// Asks for one line of text in an app sheet ("Save as routine" › Name):
/// the trimmed text on [action], null when dismissed. [action] is off
/// while the field is blank.
Future<String?> showTextPrompt(
  BuildContext context, {
  required String title,
  required String label,
  required String action,
  String initial = '',
}) => showAppSheet<String>(
  context: context,
  title: title,
  builder: (_) => _Prompt(label: label, action: action, initial: initial),
);

class _Prompt extends StatefulWidget {
  const _Prompt({
    required this.label,
    required this.action,
    required this.initial,
  });

  final String label;
  final String action;
  final String initial;

  @override
  State<_Prompt> createState() => _PromptState();
}

class _PromptState extends State<_Prompt> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _done() {
    final value = _text.text.trim();
    if (value.isNotEmpty) Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        TextField(
          controller: _text,
          autofocus: true,
          maxLength: maxTitleLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: widget.label),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _done(),
        ),
        FilledButton(
          onPressed: _text.text.trim().isEmpty ? null : _done,
          child: Text(widget.action),
        ),
      ],
    );
  }
}
