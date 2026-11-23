import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/settings/settings_places.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// One searchable setting: a row's title and the page that holds it.
typedef SettingsEntry = ({String title, SettingsPage page});

/// Every Settings row a search finds (M20.7 part 1): the rows of each
/// group page, and the pages under them by their titles.
List<SettingsEntry> settingsIndex(AppLocalizations l10n) {
  const p = SettingsPage.values;
  final rows = <SettingsPage, List<String>>{
    SettingsPage.wakeWindDown: [
      l10n.settingsWakeUp,
      l10n.settingsWakeUpAlarm,
      l10n.settingsWindDown,
      l10n.wwdAddSchedule,
      l10n.settingsShowNight,
      l10n.settingsSleepTarget,
      l10n.settingsWindDownReminder,
    ],
    SettingsPage.learning: [
      l10n.settingsLearningDurations,
      l10n.settingsLearningSteps,
      l10n.settingsEnergy,
    ],
    SettingsPage.planning: [
      l10n.settingsDefaultDuration,
      l10n.settingsSnap,
      l10n.settingsShiftLater,
      l10n.settingsRoll,
      l10n.settingsShowFree,
      l10n.settingsStartNudge,
      l10n.settingsLateNudge,
      l10n.settingsInboxNudge,
      l10n.lowEnergyMode,
    ],
    SettingsPage.reminders: [
      l10n.settingsTaskStarts,
      l10n.settingsSound,
      l10n.settingsQuietHours,
      l10n.settingsDaySummary,
    ],
    SettingsPage.appearance: [
      l10n.layoutRow,
      l10n.settingsTheme,
      l10n.settingsAppColour,
      l10n.settingsEditPalette,
      l10n.settingsLanguage,
      l10n.settingsSingleKeys,
      l10n.settingsWeekStarts,
      l10n.settingsTimeFormat,
    ],
    SettingsPage.dataPrivacy: [l10n.settingsSync, l10n.settingsTrash],
    SettingsPage.helpAbout: [l10n.settingsFeedback],
  };
  return [
    for (final MapEntry(key: page, value: titles) in rows.entries)
      for (final title in titles) (title: title, page: page),
    for (final page in p)
      // Everything else is minimal's way in; Wake Up options is part of
      // Wake Up and Wind Down now.
      if (page != SettingsPage.everything && page != SettingsPage.wakeUp)
        (title: settingsPlace(l10n, page).title, page: page),
  ];
}

/// The entries whose title holds [query], ignoring case; none for blank.
List<SettingsEntry> searchSettings(List<SettingsEntry> index, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return [
    for (final e in index)
      if (e.title.toLowerCase().contains(q)) e,
  ];
}

/// "Search settings" over [child] (the root's groups): while a query is
/// typed the matches replace [child]; a match opens its page. A leaf: owns
/// its controller and the query.
class SettingsSearch extends StatefulWidget {
  const SettingsSearch({required this.child, super.key});

  final Widget child;

  @override
  State<SettingsSearch> createState() => _SettingsSearchState();
}

class _SettingsSearchState extends State<SettingsSearch> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final hits = searchSettings(settingsIndex(l10n), _query);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.xl,
      children: [
        _field(context, t, l10n),
        if (_query.trim().isEmpty)
          widget.child
        else if (hits.isEmpty)
          Text(
            l10n.settingsSearchNone(_query.trim()),
            style: t.styles.body.copyWith(color: t.colors.muted),
          )
        else
          SettingsGroup(
            caption: '',
            children: [for (final hit in hits) _HitRow(hit)],
          ),
      ],
    );
  }

  /// The platform's own search field: UIKit's on iPhone, M3's search bar
  /// elsewhere (native first; E-Phones).
  Widget _field(BuildContext context, DotTheme t, AppLocalizations l10n) {
    void changed(String q) => setState(() => _query = q);
    if (DotIdiom.of(context) == DotIdiom.cupertino) {
      return CupertinoSearchTextField(
        controller: _controller,
        placeholder: l10n.settingsSearchHint,
        onChanged: changed,
        style: t.styles.body,
        placeholderStyle: t.styles.body.copyWith(color: t.colors.muted),
        // The app's glyph: the default is CupertinoIcons' font, which the
        // app doesn't bundle (drew a "?" box on the iPhone).
        prefixIcon: DotIcon(DotGlyphs.search, color: t.colors.muted),
        backgroundColor: t.colors.chip,
        autocorrect: false,
        // UIKit's 36 pt bar grown to the 48 pt touch target (03 §1); its
        // 20 pt clear button would be under it, so the keyboard clears.
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DotSpace.xs,
          vertical: DotSpace.m + DotSpace.xxs,
        ),
        suffixMode: OverlayVisibilityMode.never,
      );
    }
    return SearchBar(
      controller: _controller,
      hintText: l10n.settingsSearchHint,
      onChanged: changed,
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(t.colors.chip),
      textStyle: WidgetStatePropertyAll(t.styles.body),
      leading: DotIcon(DotGlyphs.search, color: t.colors.muted),
    );
  }
}

/// A match: the setting, under its page's icon and with the page's name.
class _HitRow extends StatelessWidget {
  const _HitRow(this.hit);

  final SettingsEntry hit;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final place = settingsPlace(context.l10n, hit.page);
    return SettingsRow(
      glyph: place.glyph,
      tint: t.tasks[place.colour].ink,
      title: hit.title,
      subtitle: hit.title == place.title ? null : place.title,
      onTap: () => unawaited(context.push(AppRoutes.settingsPage(hit.page))),
    );
  }
}
