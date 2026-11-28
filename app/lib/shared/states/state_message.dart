import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The state kit's message (E-G4-7-States A5, A6; ED-187): a quiet glyph
/// in a 56 pt circle, a title, one line, and at most one action, centred.
/// Calm words, never a warning colour (11 §D no shame).
///
/// ```dart
/// StateMessage(glyph: DotGlyphs.inbox, title: l10n.inboxEmpty,
///     body: l10n.inboxEmptyBody);
/// ```
class StateMessage extends StatelessWidget {
  const StateMessage({
    required this.glyph,
    required this.title,
    this.body,
    this.action,
    this.onAction,
    super.key,
  });

  final DotGlyph glyph;
  final String title;
  final String? body;

  /// The one action, a tonal 44 pt pill ("Try again"); shown with
  /// [onAction] only.
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final body = this.body;
    final action = this.action;
    final onAction = this.onAction;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.xxl,
        vertical: DotSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.s + DotSpace.xxs,
        children: [
          ExcludeSemantics(
            child: Container(
              width: DotSize.stateIcon,
              height: DotSize.stateIcon,
              decoration: BoxDecoration(color: c.sunk, shape: BoxShape.circle),
              child: Center(
                child: DotIcon(glyph, color: c.ink2, size: DotSize.stateGlyph),
              ),
            ),
          ),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: t.styles.stateTitle,
            ),
          ),
          if (body != null)
            Text(
              body,
              textAlign: TextAlign.center,
              style: t.styles.stateBody.copyWith(color: c.ink2),
            ),
          if (action != null && onAction != null)
            FilledButton.tonal(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: c.tonal,
                foregroundColor: c.accentText,
                minimumSize: const Size(DotTouch.min, DotTouch.min),
                padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
              ),
              child: Text(action),
            ),
        ],
      ),
    );
  }
}
