import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Clears what was learned and returns how to put it back (Undo).
typedef LearnedReset = Future<Future<void> Function()> Function();

/// How a learned value was worked out (docs/13 §6): "based on your last 6
/// times · median", and, for values learned per title, the reset.
@immutable
final class LearnedExplanation {
  const LearnedExplanation({
    required this.why,
    this.reset,
    this.resetDone,
    this.resetConfirm,
  });

  /// A value learned per title: "based on your last 6 times · median",
  /// with [reset] and its Undo message and inline question for [title].
  LearnedExplanation.perTitle(
    AppLocalizations l10n, {
    required int samples,
    required String title,
    this.reset,
  }) : why = l10n.learnBasedOn(samples),
       resetDone = l10n.learnResetDone(title),
       resetConfirm = l10n.learnResetConfirm(title);

  /// The one inline line shown on tap.
  final String why;

  /// "Reset for this task on this device"; null when the value is not per
  /// title (the energy window).
  final LearnedReset? reset;

  /// The Undo snackbar's message after [reset] ("Learning for Deep work
  /// reset on this device").
  final String? resetDone;

  /// Inside a sheet or popover a snackbar would sit under it, out of
  /// reach, so the reset asks once inline instead ("Forget what Deep work
  /// taught, on this device?").
  final String? resetConfirm;
}

/// A learned value that explains itself (docs/13 §6): [text] ("usually
/// 2 h 20") as one 48 px target; a tap, Enter or Space opens one more line
/// with [explanation] and, when it has one, the reset; a second tap or Esc
/// closes it. No sheet, no dialog. On a page the reset offers Undo; in a
/// sheet or popover it asks once inline first. Without [explanation] it is
/// plain text.
class LearnedLine extends StatefulWidget {
  const LearnedLine({
    required this.text,
    this.explanation,
    this.style,
    super.key,
  });

  final String text;
  final LearnedExplanation? explanation;

  /// The host's caption style; muted row meta by default.
  final TextStyle? style;

  @override
  State<LearnedLine> createState() => _LearnedLineState();
}

class _LearnedLineState extends State<LearnedLine> {
  bool _open = false;

  /// Asking "Forget what … taught?" (in a sheet or popover).
  bool _confirming = false;

  /// Held by the line so Esc closes it after a tap too, not only after Tab.
  final _focus = FocusNode(debugLabel: 'LearnedLine'); // l10n-ignore: debug

  void _toggle() {
    setState(() {
      _open = !_open;
      _confirming = false;
    });
    if (_open) _focus.requestFocus();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  /// Whether this line sits in a sheet, dialog or popover, over the page
  /// whose scaffold shows snackbars.
  bool get _inPopup => ModalRoute.of(context) is PopupRoute;

  Future<void> _reset(LearnedExplanation e, {bool confirmed = false}) async {
    final reset = e.reset;
    if (reset == null) return;
    if (_inPopup && !confirmed) {
      setState(() => _confirming = true);
      return;
    }
    final messenger = _inPopup ? null : ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    final undo = await reset();
    if (mounted) setState(() => _open = false);
    if (messenger == null || e.resetDone == null) return;
    showUndoSnackbarOn(
      messenger,
      l10n,
      message: e.resetDone!,
      onUndo: () => unawaited(undo()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final style =
        widget.style ?? t.styles.rowMeta.copyWith(color: t.colors.muted);
    final e = widget.explanation;
    if (e == null) return Text(widget.text, style: style);
    final line = Semantics(
      button: true,
      expanded: _open,
      focusable: true,
      label: l10n.learnFromHistory(widget.text),
      hint: l10n.learnExplainHint,
      onTap: _toggle,
      excludeSemantics: true,
      child: InkWell(
        focusNode: _focus,
        onTap: _toggle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(widget.text, style: style),
          ),
        ),
      ),
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_open) _toggle();
        },
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          line,
          if (_open && _confirming)
            _Confirm(
              question: e.resetConfirm ?? '',
              onReset: () => unawaited(_reset(e, confirmed: true)),
              onKeep: () => setState(() => _confirming = false),
            )
          else if (_open)
            _Why(explanation: e, onReset: () => unawaited(_reset(e))),
        ],
      ),
    );
  }
}

/// "based on your last 6 times · median" and the reset.
class _Why extends StatelessWidget {
  const _Why({required this.explanation, required this.onReset});

  final LearnedExplanation explanation;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DotSpace.s,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            explanation.why,
            style: t.styles.rowMeta.copyWith(color: t.colors.muted),
          ),
        ),
        if (explanation.reset != null)
          TextButton(
            onPressed: onReset,
            style: TextButton.styleFrom(
              foregroundColor: t.colors.accentInk,
              minimumSize: const Size(DotTouch.android, DotTouch.android),
            ),
            child: Text(context.l10n.learnReset),
          ),
      ],
    );
  }
}

/// "Forget what Deep work taught, on this device?" Reset · Keep.
class _Confirm extends StatelessWidget {
  const _Confirm({
    required this.question,
    required this.onReset,
    required this.onKeep,
  });

  final String question;
  final VoidCallback onReset;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final style = TextButton.styleFrom(
      foregroundColor: t.colors.accentInk,
      minimumSize: const Size(DotTouch.android, DotTouch.android),
    );
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DotSpace.s,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(question, style: t.styles.rowMeta),
        ),
        TextButton(
          onPressed: onReset,
          style: style,
          child: Text(l10n.learnResetConfirmAction),
        ),
        TextButton(
          onPressed: onKeep,
          style: style,
          child: Text(l10n.learnResetKeep),
        ),
      ],
    );
  }
}
