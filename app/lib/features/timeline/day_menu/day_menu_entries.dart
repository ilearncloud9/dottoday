import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/day_action.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/widgets.dart';

/// Which Day menu (ED-093, ED-254): Full's four groups; Minimal's three
/// items on phones and compact windows; E-Minimal's list from medium
/// width.
enum DayMenuKind { full, minimalShort, minimalWide }

/// What the menu shows when it opens.
@immutable
final class DayMenuState {
  const DayMenuState({
    required this.isToday,
    required this.live,
    required this.runsOver,
    required this.lowEnergy,
    required this.reality,
    required this.realityOffered,
    required this.mac,
    required this.web,
  });

  /// Time's actions are today-only (ED-093).
  final bool isToday;

  /// A task is on now: Need more time works.
  final bool live;

  /// It runs into the next task: Then shift the rest and Rebalance.
  final bool runsOver;
  final bool lowEnergy;

  /// Plan / Reality is on, and offered (the day has a real start, B1).
  final bool reality;
  final bool realityOffered;

  /// The Mac's title case (E-FullA-v2); the web's chips (no submenu row).
  final bool mac;
  final bool web;
}

/// The entries of the [kind] of Day menu; [act] is what a choice runs.
List<ContextMenuEntry<VoidCallback>> dayMenuEntries(
  AppLocalizations l10n,
  DayMenuKind kind,
  DayMenuState s,
  VoidCallback Function(DayAction) act,
) {
  final m = s.mac;
  ContextMenuEntry<VoidCallback> e(
    DayAction a,
    String label, {
    bool enabled = true,
    bool? checked,
    String? header,
    bool divided = false,
    bool icon = true,
    List<ContextMenuEntry<VoidCallback>> children = const [],
  }) => ContextMenuEntry(
    value: act(a),
    label: label,
    symbol: icon ? _symbols[a] : null,
    glyph: icon ? _glyphs[a] : null,
    enabled: enabled,
    checked: checked,
    header: header,
    divided: divided,
    children: children,
  );

  final time = s.isToday && s.live;
  final needMore = e(
    DayAction.extend15,
    m ? l10n.menuDayNeedMoreTime : l10n.dayMenuNeedMoreTime,
    enabled: time,
    header: kind == DayMenuKind.full ? l10n.dayMenuTime : null,
    children: [
      for (final (a, min) in const [
        (DayAction.extend5, 5),
        (DayAction.extend15, 15),
        (DayAction.extend30, 30),
      ])
        e(a, l10n.runningLateBy(min), enabled: time, icon: false),
      // The web shows the minutes as chips; Shift the rest from here…
      // is the next row there (E-FullA-v2).
      if (!s.web)
        e(
          DayAction.thenShiftRest,
          m ? l10n.menuDayThenShift : l10n.dayMenuThenShift,
          enabled: time && s.runsOver,
          divided: true,
        ),
    ],
  );
  final shift = e(
    DayAction.shiftRestFromHere,
    m ? l10n.menuDayShiftFromHere : l10n.dayMenuShiftFromHere,
    enabled: s.isToday,
  );
  final lowEnergy = e(
    DayAction.lowEnergy,
    m ? l10n.menuDayLowEnergy : l10n.lowEnergyMode,
    checked: s.lowEnergy,
  );
  final brainDump = e(
    DayAction.brainDump,
    m ? l10n.menuDayBrainDump : l10n.dayMenuBrainDump,
  );
  final routine = e(
    DayAction.dropRoutine,
    m ? l10n.menuDayDropRoutine : l10n.dayMenuDropRoutine,
  );
  final duplicate = e(
    DayAction.duplicate,
    m ? l10n.menuDayDuplicate : l10n.todayMenuDuplicate,
  );
  final copy = e(
    DayAction.copyText,
    m ? l10n.menuCopyDayText : l10n.todayMenuCopyText,
  );
  final review = e(
    DayAction.reviewDay,
    m ? l10n.menuDayReview : l10n.todayMenuReview,
  );
  return switch (kind) {
    // Phones and compact windows in Minimal (docs/14 §4).
    DayMenuKind.minimalShort => [
      e(DayAction.showEverything, l10n.layoutShowEverything),
      lowEnergy,
      e(DayAction.settings, l10n.navSettings),
    ],
    // E-Minimal's menu with Full's names (ED-093, ED-254).
    DayMenuKind.minimalWide => [
      needMore,
      shift,
      _divided(brainDump),
      routine,
      _divided(duplicate),
      copy,
      review,
      _divided(lowEnergy),
      e(
        DayAction.showEverything,
        m ? l10n.menuShowEverything : l10n.layoutShowEverything,
      ),
    ],
    DayMenuKind.full => [
      needMore,
      shift,
      e(
        DayAction.rebalance,
        l10n.dayMenuRebalance,
        enabled: s.isToday && s.runsOver,
      ),
      _headed(brainDump, l10n.dayMenuPlan),
      routine,
      e(
        DayAction.oneThing,
        m ? l10n.menuDayOneThing : l10n.oneThingMenu,
        enabled: s.isToday,
      ),
      _headed(duplicate, l10n.workspaceDay),
      copy,
      review,
      e(
        DayAction.weekReview,
        m ? l10n.menuDayWeekReview : l10n.weekReviewTitle,
      ),
      // Go to date (owner, M19.5 part 5c), kept with the day.
      e(DayAction.goToDate, m ? l10n.menuGoToDate : l10n.todayMenuGoToDate),
      _headed(lowEnergy, l10n.layoutRow),
      e(
        DayAction.planReality,
        l10n.dayMenuPlanReality,
        enabled: s.realityOffered,
        checked: s.reality,
      ),
      e(DayAction.showLess, m ? l10n.menuShowLess : l10n.layoutShowLess),
    ],
  };
}

ContextMenuEntry<VoidCallback> _headed(
  ContextMenuEntry<VoidCallback> e,
  String header,
) => _copy(e, header: header);

ContextMenuEntry<VoidCallback> _divided(ContextMenuEntry<VoidCallback> e) =>
    _copy(e, divided: true);

ContextMenuEntry<VoidCallback> _copy(
  ContextMenuEntry<VoidCallback> e, {
  String? header,
  bool divided = false,
}) => ContextMenuEntry(
  value: e.value,
  label: e.label,
  symbol: e.symbol,
  glyph: e.glyph,
  enabled: e.enabled,
  checked: e.checked,
  header: header ?? e.header,
  divided: divided || e.divided,
  children: e.children,
);

/// SF Symbols for the system menus (ED-260), as E-G2-9's iPhone drawing.
const _symbols = <DayAction, String>{
  DayAction.extend15: 'plus.circle', // l10n-ignore: SF Symbol
  DayAction.shiftRestFromHere: 'arrow.right.to.line', // l10n-ignore: SF Symbol
  DayAction.rebalance: 'slider.horizontal.3', // l10n-ignore: SF Symbol
  DayAction.brainDump: 'list.bullet', // l10n-ignore: SF Symbol
  DayAction.dropRoutine: 'repeat', // l10n-ignore: SF Symbol
  DayAction.oneThing: 'star', // l10n-ignore: SF Symbol
  DayAction.duplicate: 'plus.square.on.square', // l10n-ignore: SF Symbol
  DayAction.copyText: 'doc.on.doc', // l10n-ignore: SF Symbol
  DayAction.reviewDay: 'chart.bar', // l10n-ignore: SF Symbol
  DayAction.weekReview: 'calendar', // l10n-ignore: SF Symbol
  DayAction.goToDate: 'calendar.badge.clock', // l10n-ignore: SF Symbol
  DayAction.lowEnergy: 'leaf', // l10n-ignore: SF Symbol
  DayAction.planReality: 'arrow.left.arrow.right', // l10n-ignore: SF Symbol
  DayAction.showLess: 'rectangle.compress.vertical', // l10n-ignore: SF Symbol
  DayAction.showEverything:
      'rectangle.expand.vertical', // l10n-ignore: SF Symbol
  DayAction.settings: 'gearshape', // l10n-ignore: SF Symbol
};

/// The app's icons in Material's menu (E-G2-9's Android drawing).
const _glyphs = <DayAction, DotGlyph>{
  DayAction.extend15: DotGlyphs.add,
  DayAction.shiftRestFromHere: DotGlyphs.rollForward,
  DayAction.rebalance: DotGlyphs.sort,
  DayAction.brainDump: DotGlyphs.list,
  DayAction.dropRoutine: DotGlyphs.repeat,
  DayAction.oneThing: DotGlyphs.bolt,
  DayAction.duplicate: DotGlyphs.week,
  DayAction.copyText: DotGlyphs.share,
  DayAction.reviewDay: DotGlyphs.review,
  DayAction.weekReview: DotGlyphs.week,
  DayAction.lowEnergy: DotGlyphs.moon,
  DayAction.planReality: DotGlyphs.arrowRight,
  DayAction.showLess: DotGlyphs.menu,
  DayAction.showEverything: DotGlyphs.menu,
};
