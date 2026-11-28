import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_actions.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_parts.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_view.dart';
import 'package:dottoday/features/timeline/widgets/day_titles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Low energy on the Mac, the web and tablets (E-R2-22 "Web and Mac"): a
/// centred column in place of the day, its own heading on top; the rest
/// of the window (sidebar, toolbar, the spread's ⋯) is unchanged.
class LowEnergyWide extends StatelessWidget {
  const LowEnergyWide({required this.today, super.key});

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: DotSize.lowEnergyColumn),
        child: LowEnergyView(
          today: today,
          heading: LowEnergyHeading(date: today),
        ),
      ),
    );
  }
}

/// "Thursday 13 November · Low-energy" over "Take it easy" and the
/// "Low-energy · on" chip, which wraps under the title at large text.
/// Counts are hidden (11 D2).
class LowEnergyHeading extends ConsumerWidget {
  const LowEnergyHeading({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.lowEnergyCaption(
            DateFormat.MMMMEEEEd(locale).format(date),
          ),
          style: t.styles.rowMeta.copyWith(
            color: t.colors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Wrap(
          spacing: DotSpace.m,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Semantics(
              header: true,
              child: Text(
                lowEnergyTitle(context, ref),
                style: t.styles.pageTitle,
              ),
            ),
            LowEnergyChip(onTurnOff: () => toggleLowEnergy(context, on: false)),
          ],
        ),
      ],
    );
  }
}
