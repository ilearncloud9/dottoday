import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_meta.dart';
import 'package:dottoday/shared/account/account_buttons.dart';
import 'package:dottoday/shared/account/account_dialog.dart';
import 'package:dottoday/shared/account/account_page_frame.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
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

/// Board `DeleteNative` (iPhone and Android, one frame; ED-495): a full
/// page, Cancel and Delete account side by side at the bottom.
class DeletePageLayout extends StatelessWidget {
  const DeletePageLayout(this.p, {super.key});

  final DeleteParts p;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    const look = AccountDialogLook.iphone;
    final note = AccountDialogType.note(t.styles, look);
    return Scaffold(
      body: SafeArea(
        child: AccountPhoneFrame(
          padding: DeleteSize.padPhone,
          gap: DeleteSize.gap,
          head: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AccountDecisionSize.headGap,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.accountDeleteTitle,
                    style: AccountDecisionType.title(t.styles, look),
                  ),
                ),
                Text(
                  p.browser
                      ? l10n.accountDeleteBodyBrowser
                      : l10n.accountDeleteBody,
                  style: AccountDecisionType.body(t.styles, t.colors, look),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DeleteSize.exportGap,
              children: [
                _ExportButton(p, look: look),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DeleteSize.exportHintInset,
                  ),
                  child: Text(l10n.accountDeleteExportHint, style: note),
                ),
                if (p.exportStatus case final s?) StatusLine(s),
                ?p.exportCheck,
              ],
            ),
            _Summary(p, dialog: false),
            _TypedWord(p, dialog: false),
            if (p.error case final e?) StatusLine(e),
          ],
          foot: Row(
            spacing: AccountDialogSize.buttonGap,
            children: [
              Expanded(
                child: AccountButton.outlined(
                  look: look,
                  label: l10n.editorCancel,
                  onPressed: p.onCancel,
                ),
              ),
              Expanded(
                child: AccountButton.filled(
                  look: look,
                  label: l10n.accountDelete,
                  onPressed: p.onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Board `DeleteWeb`: a 480 dialog; Esc and Cancel close it. Tablets
/// centre the phone's sizes at the same width (ED-365, ED-495).
class DeleteDialogLayout extends StatelessWidget {
  const DeleteDialogLayout(this.p, {super.key});

  final DeleteParts p;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final look = accountDialogLook(context);
    final desktop = look == AccountDialogLook.desktop;
    return AccountDialog(
      look: look,
      width: DeleteSize.dialogWidth,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.accountDeleteTitle,
            style: AccountDialogType.title(t.styles, look),
          ),
        ),
        Text(
          p.browser ? l10n.accountDeleteBodyBrowser : l10n.accountDeleteBody,
          style: AccountDialogType.body(t.styles, t.colors, look),
        ),
        _ExportRow(p, look: look),
        if (p.exportStatus case final s?) StatusLine(s),
        ?p.exportCheck,
        _Summary(p, dialog: desktop),
        _TypedWord(p, dialog: desktop),
        if (p.error case final e?) StatusLine(e),
        Padding(
          padding: const EdgeInsets.only(top: DeleteSize.buttonsTop),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: AccountDialogSize.buttonGap,
            runSpacing: AccountDialogSize.buttonGap,
            children: [
              AccountButton.outlined(
                look: look,
                label: l10n.editorCancel,
                onPressed: p.onCancel,
              ),
              AccountButton.filled(
                look: look,
                label: l10n.accountDelete,
                onPressed: p.onDelete,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The dialog's "Export my data first" with its hint beside it, as drawn
/// (it wraps; the pill doesn't); at large text the hint goes under it.
class _ExportRow extends StatelessWidget {
  const _ExportRow(this.p, {required this.look});

  final DeleteParts p;
  final AccountDialogLook look;

  @override
  Widget build(BuildContext context) {
    final hint = Text(
      context.l10n.accountDeleteExportHintShort,
      style: AccountDialogType.note(DotTheme.of(context).styles, look),
    );
    final button = _ExportButton(p, look: look);
    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.s,
        children: [button, hint],
      );
    }
    return Row(
      spacing: DeleteSize.exportRowGap,
      children: [
        button,
        Flexible(child: hint),
      ],
    );
  }
}

/// "Export my data first" (the accent's tint): the checked export of the
/// owner; 48 full width on phones, the board's pill in the dialog.
class _ExportButton extends StatelessWidget {
  const _ExportButton(this.p, {required this.look});

  final DeleteParts p;
  final AccountDialogLook look;

  @override
  Widget build(BuildContext context) {
    final button = AccountButton.tint(
      look: look,
      label: context.l10n.accountDeleteExportFirst,
      onPressed: p.busy ? null : () => p.onExport(_origin(context)),
    );
    if (p.wide) return button;
    return SizedBox(height: DeleteSize.exportPhone, child: button);
  }

  /// Where the iPad and Mac share popovers point.
  static Rect? _origin(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

/// What goes from this device: "42 tasks, your settings and 3 changes
/// that haven't synced. This can't be undone." Phones: a card with its
/// caption; the dialog: a sunk box led by "Removed from this browser:".
class _Summary extends StatelessWidget {
  const _Summary(this.p, {required this.dialog});

  final DeleteParts p;

  /// The Mac/web board's sizes.
  final bool dialog;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final line = DeleteType.line(t.styles, dialog: dialog);
    return FutureBuilder<OwnerSummary>(
      future: p.summary,
      builder: (context, snap) {
        final s = snap.data;
        final text = s == null ? '' : _text(l10n, s);
        if (p.wide) {
          final lead = p.browser
              ? l10n.accountDeleteRemovedBrowserLead
              : l10n.accountDeleteRemovedDeviceLead;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: DeleteColors.box(t.colors),
              borderRadius: BorderRadius.circular(
                DeleteSize.summaryRadiusDialog,
              ),
            ),
            child: Padding(
              padding: DeleteSize.summaryPadDialog,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: lead,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontVariations: [FontVariation.weight(700)],
                      ),
                    ),
                    // The gap after "Removed from this browser:".
                    const WidgetSpan(child: SizedBox(width: DotSpace.xs)),
                    TextSpan(text: text),
                  ],
                ),
                style: line,
              ),
            ),
          );
        }
        return DecoratedBox(
          decoration: BoxDecoration(
            color: DeleteColors.card(t.colors),
            borderRadius: BorderRadius.circular(DeleteSize.summaryRadius),
          ),
          child: Padding(
            padding: DeleteSize.summaryPad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DeleteSize.summaryGap,
              children: [
                Text(
                  p.browser
                      ? l10n.accountDeleteRemovedBrowser
                      : l10n.accountDeleteRemovedDevice,
                  style: DeleteType.caption(t.styles, t.colors),
                ),
                Text(text, style: line),
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

/// "Type DELETE to confirm" and its field: 48 tall with 16 corners on
/// phones, 40 and 12 in the Mac/web dialog; a 1.5 ring.
class _TypedWord extends StatelessWidget {
  const _TypedWord(this.p, {required this.dialog});

  final DeleteParts p;
  final bool dialog;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final word = l10n.accountDeleteWord;
    final height = dialog ? DeleteSize.fieldDialog : DeleteSize.field;
    final pad = dialog ? DeleteSize.fieldPadDialog : DeleteSize.fieldPad;
    final type = DeleteType.field(t.styles, dialog: dialog);
    OutlineInputBorder ring(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        dialog ? DeleteSize.fieldRadiusDialog : DeleteSize.fieldRadius,
      ),
      borderSide: BorderSide(color: color, width: DeleteSize.fieldOutline),
    );
    final rest = ring(AccountDialogColors.outline(t.colors));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DeleteSize.fieldGap,
      children: [
        ExcludeSemantics(
          child: Text(
            l10n.accountDeleteTypeWord(word),
            style: DeleteType.line(
              t.styles,
              dialog: dialog,
            ).copyWith(color: t.colors.ink2),
          ),
        ),
        Semantics(
          label: l10n.accountDeleteTypeWord(word),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: TextField(
              contextMenuBuilder: systemTextMenu,
              controller: p.typed,
              enabled: !p.busy,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => p.onDelete?.call(),
              style: type,
              decoration: InputDecoration(
                hintText: word,
                hintStyle: type.copyWith(color: t.colors.placeholder),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: pad,
                  vertical:
                      (height - (type.fontSize ?? 0) * (type.height ?? 1.2)) /
                      2,
                ),
                filled: true,
                fillColor: DeleteColors.field(t.colors, dialog: dialog),
                border: rest,
                enabledBorder: rest,
                disabledBorder: rest,
                focusedBorder: ring(t.colors.focus),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
