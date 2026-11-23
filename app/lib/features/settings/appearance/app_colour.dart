import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/settings/appearance/edit_palette_sheet.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The App colour in use: the custom `accent_hex` if set, else the named
/// accent's light shade (ED-221).
Color appColourOf(Profile profile) => switch (profile.accentHex) {
  final hex? =>
    parseHex(hex) ?? DotAccent.fromKey(profile.settings.accent).light,
  null => DotAccent.fromKey(profile.settings.accent).light,
};

/// APP COLOUR (E-G3-9b, ED-161): the current colour first, ticked, then
/// Teal and the warm suggestions in a row that scrolls; Edit palette; the
/// note that tasks keep their colours. A tap applies at once.
class AppColourGroup extends ConsumerWidget {
  const AppColourGroup({required this.profile, super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = appColourOf(profile);
    final container = ProviderScope.containerOf(context);
    final teal = DotAccent.teal.light;
    final swatches = <Widget>[
      _Swatch(colour: current, name: _nameOf(l10n, current), selected: true),
      if (current != teal)
        _Swatch(
          colour: teal,
          name: l10n.appColourTeal,
          onTap: () => unawaited(setAppColour(container)),
        ),
      for (final s in AppColourSuggestion.values)
        if (s.colour != current)
          _Swatch(
            colour: s.colour,
            name: _suggestionName(l10n, s),
            onTap: () => unawaited(setAppColour(container, colour: s.colour)),
          ),
    ];
    final edit = Text(l10n.settingsEditPalette);
    void open() => unawaited(showEditPalette(context));
    final cupertino = DotIdiom.of(context) == DotIdiom.cupertino;
    return SettingsGroup(
      caption: l10n.settingsAppColour,
      footer: l10n.settingsAppColourNote,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DotSpace.s),
          // The card's width, so the row starts at its edge on wide windows
          // too; Edit palette centred on iPhone, at the start on Material.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
                child: Row(children: swatches),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
                child: Align(
                  alignment: cupertino
                      ? Alignment.center
                      : AlignmentDirectional.centerStart,
                  child: cupertino
                      ? TextButton(onPressed: open, child: edit)
                      : FilledButton.tonal(onPressed: open, child: edit),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _nameOf(AppLocalizations l10n, Color c) {
    if (c == DotAccent.teal.light) return l10n.appColourTeal;
    for (final s in AppColourSuggestion.values) {
      if (s.colour == c) return _suggestionName(l10n, s);
    }
    for (final a in DotAccent.values) {
      if (a.light == c) {
        return taskColorName(l10n, TaskColor.fromKey(a.key));
      }
    }
    return l10n.appColourCustom(hexOf(c));
  }
}

/// The suggestion's spoken name.
String _suggestionName(AppLocalizations l10n, AppColourSuggestion s) =>
    switch (s) {
      AppColourSuggestion.blush => l10n.appColourBlush,
      AppColourSuggestion.peach => l10n.appColourPeach,
      AppColourSuggestion.honey => l10n.appColourHoney,
      AppColourSuggestion.sage => l10n.appColourSage,
      AppColourSuggestion.duskBlue => l10n.appColourDuskBlue,
      AppColourSuggestion.pine => l10n.appColourPine,
      AppColourSuggestion.plum => l10n.appColourPlum,
      AppColourSuggestion.inkNavy => l10n.appColourInkNavy,
    };

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.colour,
    required this.name,
    this.selected = false,
    this.onTap,
  });

  final Color colour;
  final String name;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => LookSwatch(
    colour: TaskColor.custom(colour),
    selected: selected,
    size: DotLook.swatch,
    label: name,
    onTap: onTap ?? () {},
  );
}
