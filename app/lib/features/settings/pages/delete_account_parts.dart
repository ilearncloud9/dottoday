import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_meta.dart';
import 'package:dottoday/shared/account/account_buttons.dart';
import 'package:dottoday/shared/account/decision_frame.dart';
import 'package:flutter/material.dart';

/// What both D1 layouts show and do (see `DeleteAccountView`).
final class DeleteParts {
  const DeleteParts({
    required this.browser,
    required this.wide,
    required this.summary,
    required this.typed,
    required this.busy,
    required this.exportStatus,
    required this.error,
    this.exportCheck,
    required this.onExport,
    required this.onCancel,
    required this.onDelete,
  });

  /// "This browser" instead of "this device".
  final bool browser;
  final bool wide;
  final Future<OwnerSummary> summary;
  final TextEditingController typed;
  final bool busy;

  /// How "Export my data first" went, said under it.
  final String? exportStatus;

  /// "Check my files…" under it while a set export is uncertain (B7c).
  final Widget? exportCheck;

  /// Why deleting didn't go through.
  final String? error;
  final ValueChanged<Rect?> onExport;
  final VoidCallback onCancel;

  /// Null until the confirm word is typed.
  final VoidCallback? onDelete;
}

/// Board `DeleteNative`: a full page with the buttons at the bottom.
class DeletePageLayout extends StatelessWidget {
  const DeletePageLayout(this.p, {super.key});

  final DeleteParts p;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: DecisionFrame(
        title: l10n.accountDeleteTitle,
        body: p.browser
            ? l10n.accountDeleteBodyBrowser
            : l10n.accountDeleteBody,
        content: [
          _ExportButton(p),
          DecisionNote(l10n.accountDeleteExportHint),
          if (p.exportStatus case final s?) StatusLine(s),
          ?p.exportCheck,
          _Summary(p),
          _TypedWord(p),
          if (p.error case final e?) StatusLine(e),
        ],
        actions: [
          Row(
            spacing: DotSpace.s,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: p.onCancel,
                  child: Text(l10n.editorCancel),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: p.onDelete,
                  child: Text(l10n.accountDelete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Board `DeleteWeb`: a dialog; Esc and Cancel close it.
class DeleteDialogLayout extends StatelessWidget {
  const DeleteDialogLayout(this.p, {super.key});

  final DeleteParts p;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: DotSize.promptWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DotSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.m,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.accountDeleteTitle,
                  style: t.styles.promptTitle,
                ),
              ),
              Text(
                p.browser
                    ? l10n.accountDeleteBodyBrowser
                    : l10n.accountDeleteBody,
                style: t.styles.body.copyWith(color: t.colors.muted),
              ),
              Wrap(
                spacing: DotSpace.m,
                runSpacing: DotSpace.s,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _ExportButton(p),
                  DecisionNote(l10n.accountDeleteExportHintShort),
                ],
              ),
              if (p.exportStatus case final s?) StatusLine(s),
              ?p.exportCheck,
              _Summary(p),
              _TypedWord(p),
              if (p.error case final e?) StatusLine(e),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: DotSpace.s,
                runSpacing: DotSpace.s,
                children: [
                  OutlinedButton(
                    onPressed: p.onCancel,
                    child: Text(l10n.editorCancel),
                  ),
                  FilledButton(
                    onPressed: p.onDelete,
                    child: Text(l10n.accountDelete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Export my data first" (tonal): the checked export of the owner.
class _ExportButton extends StatelessWidget {
  const _ExportButton(this.p);

  final DeleteParts p;

  @override
  Widget build(BuildContext context) => FilledButton(
    style: tonalPillStyle(context),
    onPressed: p.busy ? null : () => p.onExport(_origin(context)),
    child: Text(context.l10n.accountDeleteExportFirst),
  );

  /// Where the iPad and Mac share popovers point.
  static Rect? _origin(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

/// What goes from this device: "42 tasks, your settings and 3 changes
/// that haven't synced. This can't be undone."
class _Summary extends StatelessWidget {
  const _Summary(this.p);

  final DeleteParts p;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return FutureBuilder<OwnerSummary>(
      future: p.summary,
      builder: (context, snap) {
        final s = snap.data;
        final text = s == null ? '' : _text(l10n, s);
        final caption = p.browser
            ? l10n.accountDeleteRemovedBrowser
            : l10n.accountDeleteRemovedDevice;
        final lead = p.browser
            ? l10n.accountDeleteRemovedBrowserLead
            : l10n.accountDeleteRemovedDeviceLead;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: p.wide ? t.colors.surface : t.colors.raised,
            borderRadius: BorderRadius.circular(
              p.wide ? DotRadii.card : DotRadii.cardLarge,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.l),
            child: p.wide
                ? Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: lead, style: t.styles.cardTitle),
                        // The gap after "Removed from this browser:".
                        const WidgetSpan(child: SizedBox(width: DotSpace.xs)),
                        TextSpan(text: text),
                      ],
                    ),
                    style: t.styles.body,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: DotSpace.s,
                    children: [
                      Text(caption.toUpperCase(), style: t.styles.caption),
                      Text(text, style: t.styles.body),
                    ],
                  ),
          ),
        );
      },
    );
  }

  static String _text(AppLocalizations l10n, OwnerSummary s) {
    final tasks = l10n.accountDeleteTasks(s.tasks);
    return s.pending == 0
        ? l10n.accountDeleteSummary(tasks)
        : l10n.accountDeleteSummaryPending(tasks, s.pending);
  }
}

/// "Type DELETE to confirm" and its field.
class _TypedWord extends StatelessWidget {
  const _TypedWord(this.p);

  final DeleteParts p;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final word = l10n.accountDeleteWord;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(DotRadii.card),
      borderSide: BorderSide(color: t.colors.outline),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        ExcludeSemantics(
          child: Text(
            l10n.accountDeleteTypeWord(word),
            style: t.styles.body.copyWith(color: t.colors.muted),
          ),
        ),
        Semantics(
          label: l10n.accountDeleteTypeWord(word),
          child: TextField(
            controller: p.typed,
            enabled: !p.busy,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => p.onDelete?.call(),
            decoration: InputDecoration(
              hintText: word,
              filled: true,
              fillColor: p.wide ? t.colors.raised : t.colors.surface,
              border: border,
              enabledBorder: border,
            ),
          ),
        ),
      ],
    );
  }
}
