import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A form sheet's top row (E-PhonesMinimal Add, E-R2-22 Edit routine): on
/// the iPhone the nav bar Cancel · title · [action]; elsewhere Material's
/// full-screen dialog row, × · title · [action].
class SheetNavBar extends StatelessWidget {
  const SheetNavBar({
    required this.title,
    this.onCancel,
    this.actionLabel,
    this.onAction,
    this.filledOnAndroid = false,
    super.key,
  });

  final String title;

  /// Null for a pick list, where a tap on a row is the answer (E-R2-33
  /// Shift later tasks: "Cancel · Shift later tasks").
  final String? actionLabel;

  /// Null where each tap already saves (the sound lists): no Cancel, since
  /// there is nothing to take back; Done closes.
  final VoidCallback? onCancel;

  /// Null while there is nothing to save.
  final VoidCallback? onAction;

  /// Android's action as a filled button (E-Phones Android Edit Weekdays
  /// "Save" pill); a text button otherwise.
  final bool filledOnAndroid;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final ios = DotIdiom.of(context) == DotIdiom.cupertino;
    final label = actionLabel;
    final cancel = TextButton(
      onPressed: onCancel,
      child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
    );
    // A missing side: an unseen copy of Cancel keeps the title centred.
    final spacer = ExcludeSemantics(
      child: Visibility.maintain(visible: false, child: cancel),
    );
    final action = label == null
        ? spacer
        : TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              textStyle: t.styles.button.copyWith(fontWeight: FontWeight.w800),
            ),
            child: Text(label),
          );
    if (!ios) {
      return Row(
        spacing: DotSpace.xs,
        children: [
          if (onCancel != null)
            IconButton(
              tooltip: context.l10n.sheetClose,
              onPressed: onCancel,
              icon: DotIcon(DotGlyphs.close, color: t.colors.text),
            ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: t.styles.sheetTitleAndroid),
            ),
          ),
          if (label != null)
            filledOnAndroid
                ? FilledButton(onPressed: onAction, child: Text(label))
                : action,
        ],
      );
    }
    return Row(
      children: [
        if (onCancel == null) spacer else cancel,
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: t.styles.cardTitle,
            ),
          ),
        ),
        action,
      ],
    );
  }
}
