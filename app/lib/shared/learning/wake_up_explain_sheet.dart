import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// Wake Up's explain sheet (docs/15 §11): four plain lines — what rings,
/// what the card does, what the check does, where to turn each off — and,
/// from Help, [tierLine]: how Wake Up rings on this device (§2).
Future<void> showWakeUpExplainSheet(BuildContext context, {String? tierLine}) =>
    showAppSheet<void>(
      context: context,
      title: context.l10n.wakeUpHowItWorks,
      builder: (_) => WakeUpExplain(tierLine: tierLine),
    );

/// The sheet's body, also Help › Wake Up's answer.
class WakeUpExplain extends StatelessWidget {
  const WakeUpExplain({this.tierLine, super.key});

  final String? tierLine;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final lines = [
      l10n.wakeUpExplainRings,
      l10n.wakeUpExplainCard,
      l10n.wakeUpExplainCheck,
      l10n.wakeUpExplainOff,
      ?tierLine,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        for (final line in lines)
          Text(line, style: t.styles.body.copyWith(color: t.colors.text)),
      ],
    );
  }
}
