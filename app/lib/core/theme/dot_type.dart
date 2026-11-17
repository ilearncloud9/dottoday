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
    required this.dayTitle,
    required this.dayCaption,
    required this.threadTitle,
    required this.threadMeta,
    required this.promptTitle,
    required this.choiceTitle,
    required this.sheetTitle,
    required this.sheetTitleAndroid,
    required this.sheetSubtitle,
    required this.tag,
    required this.primaryButton,
    required this.chip,
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
    stripDate: _manrope(18, 22, 600, text),
    stripWeekday: _system(13, 16, 500, muted),
    monthDate: _manrope(15, 20, 500, text),
    dayTitle: _system(28, 34, 700, text, tracking: -0.01),
    // E summary line, 700 15/20 secondary.
    dayCaption: _manrope(15, 20, 700, muted),
    threadTitle: _manrope(17, 21, 700, text),
    threadMeta: _manrope(13, 18, 400, muted),
    // Decision screens from CR-160 (main, PR #75), in the Concept E content face.
    promptTitle: _manrope(22, 28, 700, text),
    choiceTitle: _manrope(17, 22, 700, text),
    sheetTitle: _manrope(24, 30, 800, text),
    sheetTitleAndroid: _system(22, 28, 400, text),
    sheetSubtitle: _system(14, 19, 500, muted),
    tag: _system(12, 20, 700, text),
    primaryButton: _manrope(17, 22, 800, text),
    chip: _manrope(14, 18, 700, text),
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

  /// An option's title on a decision screen (B1, G1; 17/700).
  final TextStyle choiceTitle;

  /// The iOS sheet title (E-Phones-2: 800 24/30).
  final TextStyle sheetTitle;

  /// The Android sheet title (E-Phones-2: 400 22/28).
  final TextStyle sheetTitleAndroid;

  /// The line under a sheet title (500 14, secondary).
  final TextStyle sheetSubtitle;

  /// Tags and the origin chip ("new", "simple rules": 700 12); colour by the caller.
  final TextStyle tag;

  /// A sheet's main action, "Add to day" (800 17 on a 54 tall pill).
  final TextStyle primaryButton;

  /// Chip labels ("Today", "Tomorrow": 700 14 Manrope).
  final TextStyle chip;

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
      dayTitle: l(dayTitle, other.dayTitle),
      dayCaption: l(dayCaption, other.dayCaption),
      threadTitle: l(threadTitle, other.threadTitle),
      threadMeta: l(threadMeta, other.threadMeta),
      promptTitle: l(promptTitle, other.promptTitle),
      choiceTitle: l(choiceTitle, other.choiceTitle),
      sheetTitle: l(sheetTitle, other.sheetTitle),
      sheetTitleAndroid: l(sheetTitleAndroid, other.sheetTitleAndroid),
      sheetSubtitle: l(sheetSubtitle, other.sheetSubtitle),
      tag: l(tag, other.tag),
      primaryButton: l(primaryButton, other.primaryButton),
      chip: l(chip, other.chip),
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
