import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// One quiet line under a sheet's subtitle (docs/10 §3, docs/09 M14.2):
/// muted [lead] ("Made with simple rules") and an accent [action] ("Turn on
/// Apple Intelligence for smarter plans") that runs [onOpen], with a ×
/// ([dismissLabel], "Don't show again") running [onDismiss]. Never red,
/// never a modal (D4). Values in, callbacks out.
class StatusHint extends StatelessWidget {
  const StatusHint({
    required this.lead,
    required this.action,
    required this.dismissLabel,
    required this.onOpen,
    required this.onDismiss,
    super.key,
  });

  final String lead;
  final String action;
  final String dismissLabel;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final style = t.styles.rowMeta;
    // The lead with the language's own separator: the join with no action.
    final leadPart = l10n.statusHintJoin(lead, '');
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: l10n.statusHintJoin(lead, action),
            onTap: onOpen,
            child: InkWell(
              onTap: onOpen,
              borderRadius: const BorderRadius.all(
                Radius.circular(DotRadii.chipAndroid),
              ),
              child: ConstrainedBox(
                // 48 covers both floors (44 pt, 48 dp).
                constraints: const BoxConstraints(minHeight: DotTouch.android),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: leadPart,
                          style: style.copyWith(color: t.colors.muted),
                        ),
                        TextSpan(
                          text: action,
                          style: style.copyWith(color: t.colors.accentInk),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onDismiss,
          tooltip: dismissLabel,
          constraints: const BoxConstraints.tightFor(
            width: DotTouch.android,
            height: DotTouch.android,
          ),
          icon: DotIcon(
            DotGlyphs.close,
            color: t.colors.muted,
            size: DotSize.rowIcon,
          ),
        ),
      ],
    );
  }
}
