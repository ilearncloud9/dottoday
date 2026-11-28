import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/shell/native_alert.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// An alert in each platform's own style (owner, M19.4 part 4d): the
/// Mac's and iOS's Cupertino alert, Material's on Android and the web.
/// Use inside `showDialog`; [actions] are [DotDialogAction]s.
class DotAlert extends StatelessWidget {
  const DotAlert({required this.actions, this.title, this.content, super.key});

  final Widget? title;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    if (!appleApp(context)) {
      return AlertDialog(title: title, content: content, actions: actions);
    }
    final body = content;
    return CupertinoAlertDialog(
      title: title,
      // A text field inside still needs a Material for its ink.
      content: body == null
          ? null
          : Material(type: MaterialType.transparency, child: body),
      actions: actions,
    );
  }
}

/// One of a [DotAlert]'s buttons: Cupertino's action on the Mac and iOS
/// (bold when [primary], red when [destructive]); on Android and the web
/// a text button, filled when [primary].
class DotDialogAction extends StatelessWidget {
  const DotDialogAction({
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.destructive = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    if (appleApp(context)) {
      return CupertinoDialogAction(
        onPressed: onPressed,
        isDefaultAction: primary,
        isDestructiveAction: destructive,
        child: Text(label),
      );
    }
    final text = Text(label);
    return primary
        ? FilledButton(onPressed: onPressed, child: text)
        : TextButton(onPressed: onPressed, child: text);
  }
}

/// One button of [showChoiceAlert].
@immutable
final class AlertChoice<T> {
  const AlertChoice({
    required this.label,
    required this.value,
    this.primary = false,
    this.destructive = false,
    this.cancel = false,
  });

  final String label;
  final T value;

  /// Return picks it (bold on iOS, the Mac's default button).
  final bool primary;

  /// Red. Dottoday's confirms stay ink, never red (ED-336/ED-337 "Confirm
  /// buttons in ink, never red"), so none sets it today.
  final bool destructive;

  /// The Cancel button (Esc on the Mac).
  final bool cancel;
}

/// An alert with [choices], in each platform's own alert (owner, native
/// pass): UIAlertController on iPhone and iPad and NSAlert on the Mac
/// through the alert bridge; Material's on Android and the web, and the
/// Cupertino copy where the bridge is missing. The chosen value, or null
/// when dismissed.
Future<T?> showChoiceAlert<T>(
  BuildContext context, {
  required List<AlertChoice<T>> choices,
  String? title,
  String? message,
}) async {
  if (appleApp(context)) {
    final preferred = choices.indexWhere((c) => c.primary);
    final index = await NativeAlert.choose(
      title: title,
      message: message,
      buttons: [
        for (final c in choices)
          NativeAlertButton(
            c.label,
            c.cancel
                ? NativeAlertStyle.cancel
                : c.destructive
                ? NativeAlertStyle.destructive
                : NativeAlertStyle.plain,
          ),
      ],
      preferred: preferred < 0 ? null : preferred,
      tint: hexOf(DotTheme.of(context).colors.accentText),
    );
    if (index != null) return index < 0 ? null : choices[index].value;
  }
  if (!context.mounted) return null;
  return showDialog<T>(
    context: context,
    builder: (dialog) => DotAlert(
      title: title == null ? null : Text(title),
      content: message == null ? null : Text(message),
      actions: [
        for (final c in choices)
          DotDialogAction(
            label: c.label,
            primary: c.primary,
            destructive: c.destructive,
            onPressed: () => Navigator.of(dialog).pop(c.value),
          ),
      ],
    ),
  );
}

/// An alert with one text field set to [initial], [action] and [cancel]:
/// the system alert on the Mac and iOS, ours elsewhere. The text on
/// [action], or null.
Future<String?> showTextAlert(
  BuildContext context, {
  required String title,
  required String action,
  required String cancel,
  String initial = '',
}) async {
  if (appleApp(context)) {
    final answer = await NativeAlert.text(
      title: title,
      initial: initial,
      action: action,
      cancel: cancel,
      tint: hexOf(DotTheme.of(context).colors.accentText),
    );
    if (answer != null) return answer.ok ? answer.text : null;
  }
  if (!context.mounted) return null;
  return showDialog<String>(
    context: context,
    builder: (_) => _TextAlert(
      title: title,
      action: action,
      cancel: cancel,
      initial: initial,
    ),
  );
}

/// [showTextAlert]'s own dialog. A leaf: owns its field's controller.
class _TextAlert extends StatefulWidget {
  const _TextAlert({
    required this.title,
    required this.action,
    required this.cancel,
    required this.initial,
  });

  final String title;
  final String action;
  final String cancel;
  final String initial;

  @override
  State<_TextAlert> createState() => _TextAlertState();
}

class _TextAlertState extends State<_TextAlert> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_text.text);

  @override
  Widget build(BuildContext context) => DotAlert(
    title: Text(widget.title),
    content: TextField(
      contextMenuBuilder: systemTextMenu,
      controller: _text,
      autofocus: true,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      DotDialogAction(
        onPressed: () => Navigator.of(context).pop(),
        label: widget.cancel,
      ),
      DotDialogAction(onPressed: _submit, label: widget.action, primary: true),
    ],
  );
}
