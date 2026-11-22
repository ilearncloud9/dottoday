import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/text_fit.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_actions.dart';
import 'package:dottoday/features/timeline/low_energy/low_energy_parts.dart';
import 'package:dottoday/features/timeline/widgets/day_titles.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:dottoday/features/timeline/widgets/today_top_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Today's header in low energy on phones (E-R2-22): "Thursday 13
/// November · Low-energy" with ⋯ (where no Day ▾ floats), Sync and the
/// profile at its end, then "Take it easy" and the "Low-energy · on" chip,
/// which wraps under the title at large text.
class LowEnergyTodayHeader extends ConsumerWidget {
  const LowEnergyTodayHeader({
    required this.date,
    required this.today,
    required this.menu,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final bool menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final android = DotIdiom.of(context) != DotIdiom.cupertino;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.s,
        DotSpace.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: DotSpace.xs,
            children: [
              Expanded(child: _Caption(date: date)),
              if (menu) TodayMenu(date: date, today: today),
              TodayTopActions(sync: watchOnScreen(ref, FeatureId.headerExtras)),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: DotSpace.s),
            child: Wrap(
              spacing: DotSpace.s,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    lowEnergyTitle(context, ref),
                    style: android ? t.styles.topBarTitle : t.styles.dayTitle,
                  ),
                ),
                LowEnergyChip(
                  onTurnOff: () => toggleLowEnergy(context, on: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The long date as drawn when it fits beside the buttons, else the
/// short one, never wrapped mid-phrase.
class _Caption extends StatelessWidget {
  const _Caption({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final style = DefaultTextStyle.of(
      context,
    ).style.merge(t.styles.dayCaption.copyWith(letterSpacing: 0));
    String caption(DateFormat f) =>
        context.l10n.lowEnergyCaption(f.format(date));
    return LayoutBuilder(
      builder: (context, box) {
        final long = caption(DateFormat.MMMMEEEEd(locale));
        return Text(
          textWidth(context, long, style) <= box.maxWidth
              ? long
              : caption(DateFormat.MMMEd(locale)),
          style: style,
        );
      },
    );
  }
}
