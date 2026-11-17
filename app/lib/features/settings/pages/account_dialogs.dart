import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Your name": the greeting's and the avatar's name (Settings › Account).
/// An empty name clears it.
Future<void> renameProfile(BuildContext context, String current) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final name = await showDialog<String>(
    context: context,
    builder: (_) => _TextDialog(
      title: l10n.accountNameTitle,
      initial: current,
      action: l10n.accountNameSave,
    ),
  );
  if (name == null || name.trim() == current) return;
  final trimmed = name.trim();
  final result = await updateProfile(
    container,
    (p) => p.copyWith(displayName: trimmed.isEmpty ? null : trimmed),
  );
  if (result case Err(:final failure)) {
    messenger.showSnackBar(
      SnackBar(content: Text(failureMessage(l10n, failure))),
    );
  }
}

/// A dialog with one field. Owns its controller for the dialog's life.
class _TextDialog extends StatefulWidget {
  const _TextDialog({
    required this.title,
    required this.action,
    this.initial = '',
  });

  final String title;
  final String action;
  final String initial;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

/// A leaf: only the field.
class _TextDialogState extends State<_TextDialog> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_text.text);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _text,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.editorCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.action)),
      ],
    );
  }
}
