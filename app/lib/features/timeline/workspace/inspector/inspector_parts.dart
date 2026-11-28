import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_write.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A label in the 58 column and its control.
class InspectorRow extends StatelessWidget {
  const InspectorRow({
    required this.label,
    required this.child,
    this.top = false,
    super.key,
  });

  final String label;
  final Widget child;

  /// The label sits at the top of a control that wraps (Alerts).
  final bool top;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      crossAxisAlignment: top
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      spacing: DotSpace.s,
      children: [
        SizedBox(
          width: DotSize.inspectorLabel,
          child: Padding(
            padding: EdgeInsets.only(top: top ? DotSpace.xs : 0),
            child: Text(label, style: t.styles.inspectorLabel),
          ),
        ),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: child,
          ),
        ),
      ],
    );
  }
}

/// A 26-tall field button: "Tue 3 Nov 2026", "Never ▾".
class InspectorField extends ConsumerWidget {
  const InspectorField({
    required this.text,
    required this.onTap,
    this.chevron = false,
    super.key,
  });

  final String text;
  final VoidCallback onTap;
  final bool chevron;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DotRadii.field),
      side: BorderSide(color: c.hairlineStrong),
    );
    return Material(
      color: c.card,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Container(
          constraints: BoxConstraints(
            minHeight: InspectorSizes.of(context, ref).field,
          ),
          padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.xs,
            children: [
              Flexible(child: Text(text, style: t.styles.inspectorValue)),
              if (chevron)
                DotIcon(
                  DotGlyphs.chevronDown,
                  color: c.ink2,
                  size: DotSize.inspectorChevron,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
