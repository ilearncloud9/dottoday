import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/painting.dart';

/// Type roles in Manrope (bundled), Concept E's content face (ED-110), at
/// the E phone scale (E_DESIGN_RULES.md §3.2, ED-104; M18.1). Chrome moves
/// to each platform's system face in M18.6.
///
/// Sizes are unscaled logical pixels; the system text scaler (up to 200 %)
/// is applied by Flutter at render time, so never clamp it here. Every role
/// where numbers line up (times, counts) carries tabular figures.
final class DotType {
  const DotType({
    required this.pageTitle,
    required this.pageTitleExpanded,
    required this.topBarTitle,
    required this.caption,
    required this.cardTitle,
    required this.rowTitle,
    required this.liveRowTitle,
    required this.rowMeta,
    required this.body,
    required this.button,
    required this.tabLabel,
    required this.tabLabelActive,
    required this.stripDate,
    required this.monthDate,
    required this.stripWeekday,
    required this.stripLetter,
    required this.dayTitle,
    required this.dayCaption,
    required this.threadTitle,
    required this.threadMeta,
    required this.promptTitle,
    required this.lookTitle,
    required this.hexCode,
    required this.choiceTitle,
    required this.sheetTitle,
    required this.minimalSheetTitle,
    required this.sheetTitleAndroid,
    required this.stripDateAndroid,
    required this.badge,
    required this.emptyTitle,
    required this.sidebarItem,
    required this.sidebarHint,
    required this.sidebarSection,
    required this.viewTab,
    required this.planHeading,
    required this.gridTitle,
    required this.gridMeta,
    required this.gridPill,
    required this.gridTitleTouch,
    required this.gridMetaTouch,
    required this.gridPillTouch,
    required this.gridHourTouch,
    required this.gridDayMetaTouch,
    required this.gridDate,
    required this.gridDayMeta,
    required this.gridHour,
    required this.monthTitle,
    required this.monthStats,
    required this.monthWeekday,
    required this.monthCellDate,
    required this.monthItem,
    required this.monthFooter,
    required this.inspectorTitle,
    required this.inspectorStatus,
    required this.inspectorLabel,
    required this.inspectorValue,
    required this.inspectorButton,
    required this.inspectorChip,
    required this.inspectorHeading,
    required this.nowBead,
    required this.stripWeekdayAndroid,
    required this.sheetSubtitle,
    required this.tag,
    required this.primaryButton,
    required this.chip,
    required this.stateTitle,
    required this.stateBody,
    required this.fieldError,
    required this.toast,
  });

  /// Roles in [text], with [muted] for captions and meta.
  factory DotType.withColors({
    required Color text,
    required Color muted,
  }) => DotType(
    // Chrome in the platform's own face (E §3.3, decision C).
    pageTitle: _system(28, 34, 700, text),
    pageTitleExpanded: _system(30, 36, 700, text),
    topBarTitle: _system(24, 32, 400, text),
    // Section headers: E has no uppercase captions (menu headers 13/18).
    caption: _system(13, 18, 600, muted),
    cardTitle: _manrope(15, 20, 700, text),
    rowTitle: _manrope(17, 21, 700, text),
    liveRowTitle: _manrope(19, 24, 700, text),
    rowMeta: _manrope(13, 18, 400, muted),
    body: _manrope(15, 22, 400, text),
    button: _manrope(15, 20, 700, text),
    tabLabel: _system(10, 12, 500, muted),
    tabLabelActive: _system(10, 12, 600, text),
    // E-Phones' week strip: the iPhone date in a 34 circle.
    stripDate: _manrope(17, 22, 500, text),
    stripWeekday: _system(13, 16, 500, muted),
    stripLetter: _system(12, 14, 400, muted),
    monthDate: _manrope(15, 20, 500, text),
    dayTitle: _system(28, 34, 700, text, tracking: -0.01),
    // E summary line, 700 15/20 secondary.
    dayCaption: _manrope(15, 20, 700, muted),
    threadTitle: _manrope(17, 21, 700, text),
    threadMeta: _manrope(13, 18, 400, muted),
    // Decision screens from CR-160 (main, PR #75), in the Concept E content face.
    promptTitle: _manrope(22, 28, 700, text),
    lookTitle: _manrope(20, 25, 700, text),
    hexCode: _system(15, 20, 600, text),
    choiceTitle: _manrope(17, 22, 700, text),
    sheetTitle: _manrope(24, 30, 800, text),
    // Minimal's task sheet header, read-only beside the 44 dot (ED-216).
    minimalSheetTitle: _manrope(21, 26, 800, text),
    sheetTitleAndroid: _system(22, 28, 400, text),
    stripDateAndroid: _manrope(16, 19, 500, text),
    // A count on an icon (Sync's conflicts, E-Phones): 11/700.
    badge: _system(11, 13, 700, text),
    // An empty day's free time, "16 h free" (E-Phones): 28/800.
    emptyTitle: _manrope(28, 34, 800, text),
    // The Workspace sidebar with a pointer (E-FullA-v2): rows 13, key
    // hints and counts 11, the "Calendar views" heading 11/600.
    sidebarItem: _system(13, 16, 400, text),
    sidebarHint: _system(11, 13, 400, muted),
    sidebarSection: _system(11, 14, 600, muted),
    // The Workspace's Day / 3 days / Week / Month tabs: 12/500.
    viewTab: _system(12, 15, 500, muted),
    // The Plan panel's section headings: 13/700 (E-FullA-v2).
    planHeading: _system(13, 18, 700, text),
    // The hour grid (E-FullA-v2 Week, M19.2 part 2): a block's title and
    // time, a short task's pill, a day header's date and count, the hour
    // labels (and weekday), and the now bead in the gutter.
    gridTitle: _manrope(12.5, 15, 700, text),
    gridMeta: _manrope(11, 15, 400, muted),
    gridPill: _manrope(11, 13, 700, text),
    // The same grid at touch sizes (E-R2-2, ED-269): titles 17, times 13,
    // a short task's pill 15, hour labels and day meta 13.
    gridTitleTouch: _manrope(17, 21.25, 700, text),
    gridMetaTouch: _manrope(13, 16.25, 400, muted),
    gridPillTouch: _manrope(15, 20, 700, text),
    gridHourTouch: _manrope(13, 16, 400, muted),
    gridDayMetaTouch: _manrope(13, 18, 700, muted),
    gridDate: _manrope(17, 22, 800, text),
    gridDayMeta: _manrope(12, 16, 700, muted),
    gridHour: _manrope(11, 14, 400, muted),
    // Month in the Workspace (E-R2-30, ED-333): the title 26/800 and its
    // numbers 13/500, weekday heads 11/700, a card's date 13/800, task
    // lines 11.5/16 600, and the "N of M done" / "Light day" lines.
    monthTitle: _manrope(26, 32, 800, text),
    monthStats: _manrope(13, 18, 500, muted),
    monthWeekday: _manrope(11, 14, 700, muted),
    monthCellDate: _manrope(13, 18, 800, text),
    monthItem: _manrope(11.5, 16, 600, text),
    monthFooter: _manrope(11, 15, 500, muted),
    // The Workspace inspector (E-FullA-v2): title 18/23 700, the status
    // line 13/700, row labels 12.5 and values 12.5/500, buttons 12/700,
    // alert chips 11.5/700, section headings 13/700.
    inspectorTitle: _manrope(18, 23, 700, text),
    inspectorStatus: _manrope(13, 18, 700, muted),
    inspectorLabel: _manrope(12.5, 17, 400, muted),
    inspectorValue: _manrope(12.5, 17, 500, text),
    inspectorButton: _manrope(12, 16, 700, text),
    inspectorChip: _manrope(11.5, 15, 700, text),
    inspectorHeading: _manrope(13, 18, 700, text),
    nowBead: _manrope(11.5, 16, 700, text),
    stripWeekdayAndroid: _system(12, 14, 500, muted),
    sheetSubtitle: _system(14, 19, 500, muted),
    tag: _system(12, 20, 700, text),
    primaryButton: _manrope(17, 22, 800, text),
    chip: _manrope(14, 18, 700, text),
    stateTitle: _manrope(20, 26, 800, text),
    stateBody: _manrope(15, 21, 500, text),
    fieldError: _manrope(13, 18, 600, text),
    toast: _manrope(15, 20, 600, text),
  );

  static const fontFamily = 'Manrope';

  /// Web chrome's stand-in for the system font (see `_system`).
  static const webChromeFamily = 'RobotoWeb';

  /// The weight `**bold**` notes take (markdown-lite, docs/02 F2.9).
  static const _strongWeight = 700;

  /// [base] with markdown-lite emphasis: bold sets the variable font's
  /// wght axis too (see `_inter`); italic is the renderer's oblique, as
  /// Inter ships no italic file.
  static TextStyle emphasis(
    TextStyle base, {
    required bool bold,
    required bool italic,
  }) {
    if (!bold && !italic) return base;
    return base.copyWith(
      fontWeight: bold ? FontWeight.w700 : null,
      fontVariations: bold
          ? [FontVariation.weight(_strongWeight.toDouble())]
          : null,
      fontStyle: italic ? FontStyle.italic : null,
    );
  }

  /// Greeting / page title: Today, Inbox, Search, Settings (28/700).
  final TextStyle pageTitle;

  /// The page title at expanded width (Mac/web 30/700).
  final TextStyle pageTitleExpanded;

  /// Android top-bar title (24/400, E §3.3), a platform idiom.
  final TextStyle topBarTitle;

  /// 12/600, uppercase by the caller (`TIME`, `DAY SHAPE`), +0.06em, muted.
  final TextStyle caption;

  /// "Wednesday · Today" (15/700).
  final TextStyle cardTitle;

  /// Task rows (17/700, E §3.2).
  final TextStyle rowTitle;

  /// The live (now) row (19/24/700 on Full Today, ED-104).
  final TextStyle liveRowTitle;

  /// Time range, "1 h free" (13/400, muted, E §3.2).
  final TextStyle rowMeta;

  /// Sheet and settings text that is not a row title (15/22/400).
  final TextStyle body;

  /// Button and chip labels (15/700, E primary button).
  final TextStyle button;

  /// Tab bar (10/500, 10/600 active; Android 12 via [androidTab]).
  final TextStyle tabLabel;
  final TextStyle tabLabelActive;

  /// Week-strip dates. Not in the §2.2 table; measured on the reference
  /// sheet against `Main` (≈ 18/600).
  final TextStyle stripDate;

  /// Month-grid dates (measured against `A-ios-today-month`, ≈ 15/500).
  final TextStyle monthDate;

  /// Week-strip weekday names (≈ 13/500 muted, `Main`).
  final TextStyle stripWeekday;

  /// The iPhone week strip's weekday letter (E-Phones): 12/400.
  final TextStyle stripLetter;

  /// Today's title, "October 21, 2026" (28/34/700, E §3.3 date title):
  /// one line with the day dot and ⋯ on a 390 pt phone.
  final TextStyle dayTitle;

  /// Today's "FRI, OCT 30" line over [dayTitle] (13/700, uppercase by the
  /// caller, muted) and the day's numbers under it.
  final TextStyle dayCaption;

  /// A task on the day thread (17/21/700, E row title); [rowTitle] stays
  /// for lists and the Mac spread's side days.
  final TextStyle threadTitle;

  /// A day-thread row's time range (13/400, muted, E row time).
  final TextStyle threadMeta;

  /// A decision screen's or prompt's title: sign out, delete, the account
  /// choices (CR-160 boards A1–A3, B1, G1, D1; 22/700).
  final TextStyle promptTitle;

  /// The colour and icon sheets' titles: "Colour and icon", "All colours",
  /// "Run · Coral" (E-Phones, E-Phones-3; 20/700).
  final TextStyle lookTitle;

  /// A colour's hex in All colours' title row (E-Phones-3; 15/600, even
  /// figures).
  final TextStyle hexCode;

  /// An option's title on a decision screen (B1, G1; 17/700).
  final TextStyle choiceTitle;

  /// The iOS sheet title (E-Phones-2: 800 24/30).
  final TextStyle sheetTitle;

  /// Minimal's task sheet header (ED-216): Manrope 800 21/26.
  final TextStyle minimalSheetTitle;

  /// The Android sheet title (E-Phones-2: 400 22/28).
  final TextStyle sheetTitleAndroid;

  /// Android's week strip (E-Phones): the date 16/500, "Mon" 12/500.
  final TextStyle stripDateAndroid;

  /// A count badge on an icon (E-Phones' Sync): 11/700.
  final TextStyle badge;

  /// An empty day's "16 h free" in the thread (E-Phones): 28/800.
  final TextStyle emptyTitle;

  /// The Workspace sidebar with a pointer (E-FullA-v2): a row, a key hint
  /// or count, and a section heading.
  final TextStyle sidebarItem;
  final TextStyle sidebarHint;
  final TextStyle sidebarSection;

  /// The Workspace's view tabs (E-FullA-v2): 12/500.
  final TextStyle viewTab;

  /// The Plan panel's section headings (E-FullA-v2): 13/700.
  final TextStyle planHeading;

  /// The hour grid (E-FullA-v2 Week): block title 12.5/700, time 11, pill
  /// 11/700, header date 17/800 and count 12/700, hour label 11, now bead
  /// 11.5/700.
  final TextStyle gridTitle;
  final TextStyle gridMeta;
  final TextStyle gridPill;
  final TextStyle gridTitleTouch;
  final TextStyle gridMetaTouch;
  final TextStyle gridPillTouch;
  final TextStyle gridHourTouch;
  final TextStyle gridDayMetaTouch;
  final TextStyle gridDate;
  final TextStyle gridDayMeta;
  final TextStyle gridHour;

  /// Month in the Workspace (E-R2-30): title 26/800, numbers 13/500,
  /// weekday heads 11/700, card date 13/800, task lines 11.5/600, and the
  /// count and Light day lines 11/500.
  final TextStyle monthTitle;
  final TextStyle monthStats;
  final TextStyle monthWeekday;
  final TextStyle monthCellDate;
  final TextStyle monthItem;
  final TextStyle monthFooter;

  /// The Workspace inspector (E-FullA-v2): title 18/23, status 13/700,
  /// labels and values 12.5, buttons 12/700, chips 11.5/700, headings 13.
  final TextStyle inspectorTitle;
  final TextStyle inspectorStatus;
  final TextStyle inspectorLabel;
  final TextStyle inspectorValue;
  final TextStyle inspectorButton;
  final TextStyle inspectorChip;
  final TextStyle inspectorHeading;
  final TextStyle nowBead;
  final TextStyle stripWeekdayAndroid;

  /// The line under a sheet title (500 14, secondary).
  final TextStyle sheetSubtitle;

  /// Tags and the origin chip ("new", "simple rules": 700 12); colour by the caller.
  final TextStyle tag;

  /// A sheet's main action, "Add to day" (800 17 on a 54 tall pill).
  final TextStyle primaryButton;

  /// Chip labels ("Today", "Tomorrow": 700 14 Manrope).
  final TextStyle chip;

  /// A state's title, "This didn't load" (E-G4-7-States: 800 20/26).
  final TextStyle stateTitle;

  /// A state's line under the title (500 15/21; ink2 by the caller).
  final TextStyle stateBody;

  /// An error at a field (600 13 ink, E-G4-7-States D).
  final TextStyle fieldError;

  /// The Undo toast's words (600 15/20, E-R2-7); its action is the bold
  /// of it.
  final TextStyle toast;

  /// Android's 12 px tab labels (§2.2).
  TextStyle androidTab(TextStyle tab) => tab.copyWith(fontSize: 12);

  /// Interpolates every role; used by theme animations.
  DotType lerp(DotType other, double t) {
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return DotType(
      pageTitle: l(pageTitle, other.pageTitle),
      pageTitleExpanded: l(pageTitleExpanded, other.pageTitleExpanded),
      topBarTitle: l(topBarTitle, other.topBarTitle),
      caption: l(caption, other.caption),
      cardTitle: l(cardTitle, other.cardTitle),
      rowTitle: l(rowTitle, other.rowTitle),
      liveRowTitle: l(liveRowTitle, other.liveRowTitle),
      rowMeta: l(rowMeta, other.rowMeta),
      body: l(body, other.body),
      button: l(button, other.button),
      tabLabel: l(tabLabel, other.tabLabel),
      tabLabelActive: l(tabLabelActive, other.tabLabelActive),
      stripDate: l(stripDate, other.stripDate),
      monthDate: l(monthDate, other.monthDate),
      stripWeekday: l(stripWeekday, other.stripWeekday),
      stripLetter: l(stripLetter, other.stripLetter),
      dayTitle: l(dayTitle, other.dayTitle),
      dayCaption: l(dayCaption, other.dayCaption),
      threadTitle: l(threadTitle, other.threadTitle),
      threadMeta: l(threadMeta, other.threadMeta),
      promptTitle: l(promptTitle, other.promptTitle),
      lookTitle: l(lookTitle, other.lookTitle),
      hexCode: l(hexCode, other.hexCode),
      choiceTitle: l(choiceTitle, other.choiceTitle),
      sheetTitle: l(sheetTitle, other.sheetTitle),
      minimalSheetTitle: l(minimalSheetTitle, other.minimalSheetTitle),
      sheetTitleAndroid: l(sheetTitleAndroid, other.sheetTitleAndroid),
      stripDateAndroid: l(stripDateAndroid, other.stripDateAndroid),
      badge: l(badge, other.badge),
      emptyTitle: l(emptyTitle, other.emptyTitle),
      sidebarItem: l(sidebarItem, other.sidebarItem),
      sidebarHint: l(sidebarHint, other.sidebarHint),
      sidebarSection: l(sidebarSection, other.sidebarSection),
      viewTab: l(viewTab, other.viewTab),
      planHeading: l(planHeading, other.planHeading),
      gridTitle: l(gridTitle, other.gridTitle),
      gridMeta: l(gridMeta, other.gridMeta),
      gridPill: l(gridPill, other.gridPill),
      gridTitleTouch: l(gridTitleTouch, other.gridTitleTouch),
      gridMetaTouch: l(gridMetaTouch, other.gridMetaTouch),
      gridPillTouch: l(gridPillTouch, other.gridPillTouch),
      gridHourTouch: l(gridHourTouch, other.gridHourTouch),
      gridDayMetaTouch: l(gridDayMetaTouch, other.gridDayMetaTouch),
      gridDate: l(gridDate, other.gridDate),
      gridDayMeta: l(gridDayMeta, other.gridDayMeta),
      gridHour: l(gridHour, other.gridHour),
      monthTitle: l(monthTitle, other.monthTitle),
      monthStats: l(monthStats, other.monthStats),
      monthWeekday: l(monthWeekday, other.monthWeekday),
      monthCellDate: l(monthCellDate, other.monthCellDate),
      monthItem: l(monthItem, other.monthItem),
      monthFooter: l(monthFooter, other.monthFooter),
      inspectorTitle: l(inspectorTitle, other.inspectorTitle),
      inspectorStatus: l(inspectorStatus, other.inspectorStatus),
      inspectorLabel: l(inspectorLabel, other.inspectorLabel),
      inspectorValue: l(inspectorValue, other.inspectorValue),
      inspectorButton: l(inspectorButton, other.inspectorButton),
      inspectorChip: l(inspectorChip, other.inspectorChip),
      inspectorHeading: l(inspectorHeading, other.inspectorHeading),
      nowBead: l(nowBead, other.nowBead),
      stripWeekdayAndroid: l(stripWeekdayAndroid, other.stripWeekdayAndroid),
      sheetSubtitle: l(sheetSubtitle, other.sheetSubtitle),
      tag: l(tag, other.tag),
      primaryButton: l(primaryButton, other.primaryButton),
      chip: l(chip, other.chip),
      stateTitle: l(stateTitle, other.stateTitle),
      stateBody: l(stateBody, other.stateBody),
      fieldError: l(fieldError, other.fieldError),
      toast: l(toast, other.toast),
    );
  }
}

TextStyle _manrope(
  double size,
  double lineHeight,
  int weight,
  Color color, {
  double tracking = 0,
}) {
  return TextStyle(
    fontFamily: DotType.fontFamily,
    fontSize: size,
    height: lineHeight / size,
    letterSpacing: tracking * size,
    // Variable font: set the wght axis explicitly as well as fontWeight so
    // every renderer picks the right instance.
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    fontVariations: [FontVariation.weight(weight.toDouble())],
    fontFeatures: const [FontFeature.tabularFigures()],
    color: color,
  );
}

/// A chrome role in the platform's own face (E §3.1): SF Pro on Apple and
/// Roboto on Android come from the system (no family set). Flutter web
/// cannot reach the visitor's system font, so the web uses the bundled
/// Roboto (owner, 2026-11-16; provisional pending the owner's font review).
TextStyle _system(
  double size,
  double lineHeight,
  int weight,
  Color color, {
  double tracking = 0,
}) => TextStyle(
  fontFamily: kIsWeb ? DotType.webChromeFamily : null,
  fontSize: size,
  height: lineHeight / size,
  letterSpacing: tracking * size,
  fontWeight: FontWeight.values[(weight ~/ 100) - 1],
  fontFeatures: const [FontFeature.tabularFigures()],
  color: color,
);
