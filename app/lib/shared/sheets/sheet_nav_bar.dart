import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A form sheet's top row (E-PhonesMinimal Add, E-R2-22 Edit routine): on
/// the iPhone the nav bar Cancel · title · [action]; elsewhere Material's
/// full-screen dialog row, × · title · [action].
class SheetNavBar extends StatelessWidget {
  const SheetNavBar({
    required this.title,
    required this.actionLabel,
    required this.onCancel,
    required this.onAction,
    super.key,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onCancel;

  /// Null while there is nothing to save.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final ios = DotIdiom.of(context) == DotIdiom.cupertino;
    final action = TextButton(
      onPressed: onAction,
      style: TextButton.styleFrom(
        textStyle: t.styles.button.copyWith(fontWeight: FontWeight.w800),
      ),
      child: Text(actionLabel),
    );
    if (!ios) {
      return Row(
        spacing: DotSpace.xs,
        children: [
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
          action,
        ],
      );
    }
    return Row(
      children: [
        TextButton(
          onPressed: onCancel,
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
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
