import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// One onboarding step's layout: question, a line of why, the step's own
/// content, then the main button (and an optional second one).
class StepFrame extends StatelessWidget {
  const StepFrame({
    required this.title,
    required this.body,
    required this.primary,
    required this.onPrimary,
    this.children = const [],
    this.secondary,
    this.onSecondary,
    super.key,
  });

  final String title;
  final String body;
  final String primary;
  final VoidCallback? onPrimary;
  final List<Widget> children;
  final String? secondary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DotSpace.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.l,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: t.styles.pageTitle),
          ),
          Text(body, style: t.styles.body.copyWith(color: t.colors.muted)),
          ...children,
          const SizedBox(height: DotSpace.s),
          FilledButton(onPressed: onPrimary, child: Text(primary)),
          if (secondary case final label?)
            TextButton(onPressed: onSecondary, child: Text(label)),
        ],
      ),
    );
  }
}
