import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/brand/brand_mark.dart';
import 'package:flutter/material.dart';

/// "● Dottoday" at the top of the web's sidebars (E-R2-30, ED-500): the
/// mark and the app's name. A heading, so a screen reader can land on it.
class BrandRow extends StatelessWidget {
  const BrandRow({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      header: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.s,
        children: [
          const BrandMark(size: BrandMarkSize.sidebar),
          Flexible(
            child: Text(context.l10n.appTitle, style: t.styles.cardTitle),
          ),
        ],
      ),
    );
  }
}
