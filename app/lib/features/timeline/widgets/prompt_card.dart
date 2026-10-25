import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A raised card with a caption, between the header and the day card.
class PromptCard extends StatelessWidget {
  const PromptCard({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.page,
        vertical: DotSpace.xs,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.raised,
          borderRadius: BorderRadius.circular(DotRadii.card),
          border: Border.all(color: t.colors.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.l),
          child: Semantics(
            container: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: DotSpace.xs,
              children: [
                Semantics(
                  header: true,
                  child: Text(title.toUpperCase(), style: t.styles.caption),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A prompt's body: one line of [detail], the [action] and "Not now".
class PromptNudge extends StatelessWidget {
  const PromptNudge({
    required this.detail,
    required this.action,
    required this.onAction,
    required this.onNotNow,
    super.key,
  });

  final String detail;
  final String action;
  final VoidCallback onAction;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s,
      children: [
        Text(detail, style: DotTheme.of(context).styles.body),
        Wrap(
          spacing: DotSpace.s,
          children: [
            FilledButton(onPressed: onAction, child: Text(action)),
            TextButton(
              onPressed: onNotNow,
              child: Text(context.l10n.promptNotNow),
            ),
          ],
        ),
      ],
    );
  }
}
