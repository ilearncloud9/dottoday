import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A raised card with a caption, between the header and the day card.
/// [onTap] makes the card itself a way in (the Wind Down card opens the
/// review, ED-099); its buttons keep their own taps.
///
/// [floating]: the card that floats at the foot of Today (E-R2-26 §1,
/// ED-329: "Need more time?", "Calendar changed"): corners 22, the
/// floating shadow, a bold sentence-case title.
class PromptCard extends StatelessWidget {
  const PromptCard({
    required this.title,
    required this.child,
    this.onTap,
    this.floating = false,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onTap;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final radius = floating ? DotRadii.tile : DotRadii.card;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.page,
        vertical: DotSpace.xs,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.card,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: floating ? t.colors.hairline : t.colors.threadAhead,
          ),
          boxShadow: floating ? DotElevation.floating : null,
        ),
        // The ink over the card's own paint, so the card looks as before.
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Padding(
              padding: floating
                  ? const EdgeInsets.symmetric(
                      horizontal: DotSpace.l,
                      vertical: DotSpace.m,
                    )
                  : const EdgeInsets.all(DotSpace.l),
              child: Semantics(
                container: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: DotSpace.xs,
                  children: [
                    Semantics(
                      header: true,
                      child: floating
                          ? Text(title, style: t.styles.rowTitle)
                          : Text(title.toUpperCase(), style: t.styles.caption),
                    ),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A prompt's body: one line of [detail], the [action] and "Not now" (or
/// [dismissLabel], e.g. "Don't show again" for a one-time tip).
class PromptNudge extends StatelessWidget {
  const PromptNudge({
    required this.detail,
    required this.action,
    required this.onAction,
    required this.onNotNow,
    this.dismissLabel,
    super.key,
  });

  final String detail;
  final String action;
  final VoidCallback onAction;
  final VoidCallback onNotNow;
  final String? dismissLabel;

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
              child: Text(dismissLabel ?? context.l10n.promptNotNow),
            ),
          ],
        ),
      ],
    );
  }
}
