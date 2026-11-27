import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/l10n/language_names.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/domain/profile/settings_difference.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/time_zones.dart';
import 'package:dottoday/shared/account/choice_card.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';

/// One side of B1 as its board draws it (ED-494): a card with the radio
/// and [title], then the differing [fields] of [profile]. The chosen card
/// has the accent outline as well as the filled mark, so the choice never
/// rests on colour alone; screen readers hear a radio button in a group.
class SettingsChoiceCard extends StatelessWidget {
  const SettingsChoiceCard({
    required this.look,
    required this.phone,
    required this.title,
    required this.profile,
    required this.fields,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final AccountDialogLook look;

  /// A phone (the label column is wider on iPhone).
  final bool phone;
  final String title;
  final Profile profile;
  final List<SettingsField> fields;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final radio = AccountDecisionSize.radio(look);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AccountDecisionSize.radius(look)),
      side: BorderSide(
        color: selected ? c.accent : c.outline,
        width: AccountDecisionSize.cardOutline,
      ),
    );
    return Semantics(
      container: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: Material(
        color: c.raised,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AccountDecisionSize.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AccountDecisionSize.cardInner,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: AccountDecisionSize.headMin(look),
                  ),
                  child: Row(
                    spacing: AccountDecisionSize.radioGap(look),
                    children: [
                      ExcludeSemantics(
                        child: RadioMark(selected: selected, size: radio),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          style: AccountDecisionType.cardTitle(t.styles, look),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: radio + AccountDecisionSize.radioGap(look),
                  ),
                  child: _Rows(
                    look: look,
                    phone: phone,
                    profile: profile,
                    fields: fields,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The differing [fields] of [profile]: a label column, then the values.
class _Rows extends StatelessWidget {
  const _Rows({
    required this.look,
    required this.phone,
    required this.profile,
    required this.fields,
  });

  final AccountDialogLook look;
  final bool phone;
  final Profile profile;
  final List<SettingsField> fields;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final value = AccountDecisionType.row(t.styles, look);
    final label = value.copyWith(color: t.colors.muted);
    final gap = AccountDecisionSize.rowGap(look);
    return Table(
      columnWidths: {
        0: MaxColumnWidth(
          FixedColumnWidth(AccountDecisionSize.labelMin(look, phone: phone)),
          const IntrinsicColumnWidth(),
        ),
      },
      children: [
        for (final (i, f) in fields.indexed)
          TableRow(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(
                  end: AccountDecisionSize.columnGap,
                  top: i == 0 ? 0 : gap,
                ),
                child: Text(_label(context, f), style: label),
              ),
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : gap),
                child: Text(_value(context, f), style: value),
              ),
            ],
          ),
      ],
    );
  }

  String _label(BuildContext context, SettingsField f) {
    final l10n = context.l10n;
    return switch (f) {
      SettingsField.timeZone => l10n.settingsChoiceTimeZone,
      SettingsField.language => l10n.settingsLanguage,
      SettingsField.yourDay => l10n.settingsChoiceYourDay,
      SettingsField.layout => l10n.layoutRow,
    };
  }

  String _value(BuildContext context, SettingsField f) {
    final l10n = context.l10n;
    final s = profile.settings;
    return switch (f) {
      SettingsField.timeZone => zoneCity(profile.tzId),
      SettingsField.language => languageName(profile.locale),
      SettingsField.yourDay => _window(context, s),
      SettingsField.layout =>
        LayoutPolicy.forSettings(s).isMinimal
            ? l10n.layoutMinimal
            : l10n.layoutFull,
    };
  }

  /// "7:00 AM – 11:00 PM": the everyday Wake Up to Wind Down.
  String _window(BuildContext context, Settings s) {
    final w = commonWindow(s);
    String at(String hhmm) => formatClockTime(
      context,
      ClockTime.fromMinutes(windowMinutes(hhmm)),
      use24h: s.use24h,
    );
    return context.l10n.settingsChoiceRange(at(w.start), at(w.end));
  }
}

/// The two cards: side by side once each has [min] (tablets, Mac/web),
/// otherwise one above the other.
class SettingsChoicePair extends StatelessWidget {
  const SettingsChoicePair({
    required this.min,
    required this.children,
    super.key,
  });

  final double? min;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final stacked = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AccountDecisionSize.cardGap,
      children: children,
    );
    final floor = min;
    // Phones stack without measuring, so the phone frame can size them.
    if (floor == null) return stacked;
    return LayoutBuilder(
      builder: (context, box) {
        final side =
            box.maxWidth >= 2 * floor + AccountDecisionSize.cardGap &&
            MediaQuery.textScalerOf(context).scale(1) <= 1.5;
        if (!side) return stacked;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AccountDecisionSize.cardGap,
            children: [for (final c in children) Expanded(child: c)],
          ),
        );
      },
    );
  }
}
