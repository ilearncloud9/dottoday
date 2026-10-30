import 'package:flutter/painting.dart';

/// Type roles of Concept A (docs/10-ui-concept-a.md §2.2), Inter (bundled).
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
  });

  /// Roles in [text], with [muted] for captions and meta.
  factory DotType.withColors({required Color text, required Color muted}) =>
      DotType(
        pageTitle: _inter(28, 34, 700, text, tracking: -0.02),
        pageTitleExpanded: _inter(30, 36, 700, text, tracking: -0.02),
        topBarTitle: _inter(22, 28, 600, text),
        caption: _inter(12, 16, 600, muted, tracking: 0.06),
        cardTitle: _inter(15, 20, 700, text),
        rowTitle: _inter(16, 22, 500, text),
        liveRowTitle: _inter(20, 26, 700, text),
        rowMeta: _inter(12, 16, 500, muted),
        body: _inter(16, 22, 400, text),
        button: _inter(14, 18, 600, text),
        tabLabel: _inter(10, 12, 500, muted),
        tabLabelActive: _inter(10, 12, 600, text),
        stripDate: _inter(18, 22, 600, text),
        stripWeekday: _inter(13, 16, 500, muted),
        monthDate: _inter(15, 20, 500, text),
        dayTitle: _inter(28, 34, 800, text, tracking: -0.03),
        dayCaption: _inter(13, 18, 700, muted, tracking: 0.06),
        threadTitle: _inter(20, 26, 700, text),
        threadMeta: _inter(15, 20, 500, muted),
      );

  static const fontFamily = 'Inter';

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

  /// Android top-bar title (22/600), a §2.2 platform idiom.
  final TextStyle topBarTitle;

  /// 12/600, uppercase by the caller (`TIME`, `DAY SHAPE`), +0.06em, muted.
  final TextStyle caption;

  /// "Wednesday · Today" (15/700).
  final TextStyle cardTitle;

  /// Task rows (16/500).
  final TextStyle rowTitle;

  /// The live row (20/700, as [threadTitle]; ADR-0015).
  final TextStyle liveRowTitle;

  /// Time range, "1 h free" (12/500, muted).
  final TextStyle rowMeta;

  /// Sheet and settings text that is not a row title (16/400).
  final TextStyle body;

  /// Button and chip labels (14/600, measured against `Main`).
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

  /// Today's title, "October 21, 2026" (28/800, tight, ADR-0015): one
  /// line with the day dot and ⋯ on a 390 pt phone.
  final TextStyle dayTitle;

  /// Today's "FRI, OCT 30" line over [dayTitle] (13/700, uppercase by the
  /// caller, muted) and the day's numbers under it.
  final TextStyle dayCaption;

  /// A task on the day thread (20/700, ADR-0015); [rowTitle] stays for
  /// lists and the Mac spread's side days.
  final TextStyle threadTitle;

  /// A day-thread row's time range (15/500, muted).
  final TextStyle threadMeta;

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
    );
  }
}

TextStyle _inter(
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
