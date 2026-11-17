import 'package:flutter/material.dart' show kMinInteractiveDimension;
import 'package:flutter/painting.dart';

/// 4-pt spacing grid. Concept A gives sizes, not a spacing scale
/// (docs/10 §2.3); these are the steps the reference renders use.
abstract final class DotSpace {
  static const double xxs = 2;
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Side margin of phone pages (20 pt in `Main`, `A-ios-inbox`).
  static const double page = 20;

  /// Side margin of Mac/web pages (`A-mac-today-alt1-spread`).
  static const double pageExpanded = 64;

  /// The now pill's side padding (E rules §5.3: 0 7).
  static const double nowPill = 7;

  /// The now card's side margin on the thread (E rules §5.3: 0 10).
  static const double nowCard = 10;

  /// Hairline outline width (`0 0 0 1px outline`, §2.3).
  static const double hairline = 1;

  /// Extra bottom inset for content under a floating add button: 56 dp
  /// button + its 16 dp margin + 16 dp breathing room, so the end of a
  /// scrolled list is never hidden behind it (M0.13).
  static const double fabClearance = 56 + l + l;
}

/// Corner radii (Concept E, E_DESIGN_RULES.md §6.3; M18.1).
abstract final class DotRadii {
  /// Cards and grouped rows (E: 20–28).
  static const double card = 20;

  /// Larger cards: the Now card (24, ED-202).
  static const double cardLarge = 24;

  /// Android sheets and dialogs (28); iOS sheets use [sheetIos].
  static const double sheet = 28;

  /// iOS sheet top corners (38, E §6.3).
  static const double sheetIos = 38;

  /// Action tiles and the Add field (22).
  static const double tile = 22;

  /// The iOS Day pull-down (26); the Android Day menu (22).
  static const double pullDownIos = 26;
  static const double menuAndroid = 22;

  /// Mac menus as drawn (10; native NSMenu in the app, ED-239).
  static const double menuMac = 10;

  /// Workspace blocks (18).
  static const double block = 18;

  /// The now pill (9, E rules §5.3).
  static const double nowPill = 9;

  /// The tip pill (20).
  static const double tip = 20;
  static const double pill = 999;

  /// Android FAB: rounded square (a §4 idiom).
  static const double fabAndroid = 16;

  /// Mac/web rail items.
  static const double railItem = 16;

  /// Chips on Android: fully round, as every Concept E chip (§6.3).
  static const double chipAndroid = pill;
}

/// Dot and thread sizes (docs/10 §2.3).
abstract final class DotSize {
  /// Widest a single list column grows on Mac/web before it centres
  /// (Inbox, Search; §4 expanded).
  static const double readableColumn = 640;

  /// The right-hand panel at the expanded width: the task editor
  /// (`A-mac-editor`: 640 of 2000 px at 1280) and proposals (docs/10 §4).
  static const double sidePanel = 420;

  /// A prompt dialog at medium and expanded widths, and the web's removal
  /// retry card (CR-160 boards DesktopA2, DeleteWeb, DeleteWebRetry).
  static const double promptWidth = 480;

  /// Narrowest a dialog gets (Material's own floor, kept with the cap).
  static const double dialogMin = 280;

  /// A row whose text gets this much width or more puts its time beside
  /// the title, in a column of [wideRowMeta] (the Mac spread's Today card,
  /// `A-mac-today-alt1-spread`: ~310 px of text). The time column is wider
  /// than the render's 107 px so a 12-hour "10:30 AM – 11:15 AM" fits on
  /// one line. The largest iPhone leaves ~266 px: phones keep the stacked
  /// row.
  static const double wideRowFrom = 300;
  static const double wideRowMeta = 144;

  /// The same for the day thread's larger rows (ADR-0015): a full-width
  /// phone sheet (~330 px of text on the largest iPhone) keeps the time
  /// above the title; the Mac card's wider text goes side by side, in a
  /// column that fits "10:30 AM – 11:15 AM" at the 15 px time size.
  static const double wideThreadRowFrom = 440;
  static const double wideThreadRowMeta = 184;

  /// Today card's share of the Mac spread against each side day (render:
  /// 700 px card between ~430 px days).
  static const int spreadCardFlex = 8;
  static const int spreadSideFlex = 5;

  static const double rowDot = 36;

  /// A task's dot on the phone day thread: ahead, calendar and concurrent
  /// now (Concept E §5.1); a done dot is [threadDoneDot].
  static const double threadDot = 34;

  /// A done task's solid dot on the phone day thread (Concept E §5.1).
  static const double threadDoneDot = 32;

  /// The Wake Up / Wind Down caps on the phone thread (ED-201).
  static const double threadCap = 34;

  /// The done circle at a thread row's end (ADR-0015), and its open ring
  /// (E rules §4.4: 2.5).
  static const double doneCircle = 28;
  static const double doneRing = 2.5;

  /// Concept E's fixed phone row heights (§5.2): rows no longer stretch
  /// with their task's length.
  static const double threadRowDone = 48;
  static const double threadRowAhead = 54;
  static const double threadRowCap = 44;
  static const double threadRowFree = 28;
  static const double threadRowNow = 26;

  /// A fold row (ED-164: Earlier, Before Wake Up, After Wind Down): 48
  /// high, its 24 px dots overlapping by half with a 2 px ground ring.
  static const double foldRow = 48;
  static const double foldDot = 24;
  static const double foldDotStep = 12;
  static const double foldDotRing = 2;

  /// The now card's least height on Full Today (ED-104; Android draws 82).
  static const double nowCard = 80;

  /// The knot row between two overlapping tasks (§5.4), and the knot's
  /// sway and stroke.
  static const double overlapRow = 26;
  static const double knotSway = 6;
  static const double knotStroke = 3.5;

  /// The knot as a mark beside text (picker caption, proposals), and its
  /// stroke.
  static const double knotMark = 20;
  static const double knotMarkWidth = 14;
  static const double knotMarkStroke = 2.5;

  /// The now card's ring (ED-104): 45 with a 5.5 stroke.
  static const double liveDot = 45;
  static const double liveRing = 5.5;

  /// An ahead dot's inset ring (ED-199): 4 on standard phone dots, 3.5
  /// on dots under 30, 2.5 on dots of 16 and under.
  static const double dotOutline = 4;
  static const double midDotOutline = 3.5;
  static const double tinyDotOutline = 2.5;

  /// A 2 px stroke: focus rings (ED-211) and selected outlines.
  static const double smallDotOutline = 2;

  /// A calendar event's ring (ED-200): 2.5, or 2 on dots of 16 and under.
  static const double calendarOutline = 2.5;

  /// Today's one thing (docs/15 §8): a thin accent ring just outside the
  /// dot, its fill and state unchanged.
  static const double oneThingRing = 2;
  static const double oneThingGap = 3;
  static const double dayDot = 44;

  /// The day dot on the Wake Up card (docs/15 §5 step 2).
  static const double wakeUpDayDot = 96;

  /// The day dot on Today's one-line header, beside the date and ⋯ so
  /// "October 21, 2026 ⌄" fits a 390 pt phone (ADR-0015).
  static const double headerDayDot = 36;

  /// The identity dot on Add step 1 (`A-ios-add-what`); step 2 uses
  /// [dayDot].
  static const double addDot = 64;

  /// Focus's ring (`B-ios-focus`: 160 px; the roadmap's 120 corrected,
  /// docs/09 M10.5), its stroke and the glyph inside.
  static const double focusRing = 160;
  static const double focusRingStroke = 22;

  /// The mission screen's ring (docs/15 §8: 120 px).
  static const double missionRing = 120;
  static const double focusGlyph = 48;
  static const double dayDotWatch = 18;
  static const double macRowDot = 26;
  static const double pickerDot = 22;
  static const double weekDot = 8;
  static const double tabDot = 14;
  static const double tabDotActive = 16;

  /// The listening dot in `MicButton` (M14.5): the accent dot that breathes.
  static const double micDot = 14;

  /// The Reality thread's plan lane, this far towards the start edge from
  /// the thread's centre, and the planned dot's ghost ring on it, shifted
  /// up or down by [ghostRingShift] (`B-ios-reality-thread`, 11 C3).
  static const double ghostLaneOffset = 14;
  static const double ghostRing = 24;
  static const double ghostRingShift = 10;

  /// The thread's width, solid and dotted alike (Concept E §5.2).
  static const double segment = 4;

  /// The dotted thread's dot.
  static const double freeLine = 4;

  /// The now-bead (§5.3): 16 with a 2 px card-coloured border and a 1 px
  /// accent ring at 40 %.
  static const double nowMarker = 16;
  static const double nowBorder = 2;
  static const double nowHalo = 1;

  /// Icon inside a row dot / a 24-unit nav icon. A dot of any size keeps
  /// this share of its diameter for the icon.
  static const double rowIcon = 18;
  static const double navIcon = 24;

  /// The weekly review's day dots (`B-ios-week-review`, 11 D1): the
  /// lightest and busiest day's diameter (each column caps them), the
  /// ring's stroke, the gap between its task segments, and the selected
  /// day's halo.
  static const double weekReviewDotMin = 40;
  static const double weekReviewDotMax = 72;
  static const double weekReviewStroke = 6;
  static const double weekReviewGap = 0.06;
  static const double weekReviewHalo = 4;

  /// The year strip's month label column (11 D3).
  static const double yearStripLabel = 36;

  /// The share image's dots (`B-ios-week-review` bottom card).
  static const double weekShareDotMin = 30;
  static const double weekShareDotMax = 50;
}

/// Minimum tap targets (docs/10 §2.3): 44 pt everywhere, 48 dp on Android.
abstract final class DotTouch {
  static const double min = 44;
  static const double android = kMinInteractiveDimension;

  /// Hold this long to pick a task up (03 §3.2 "long-press 250 ms").
  static const liftDelay = Duration(milliseconds: 250);

  /// Hold a dragged task over a week-strip day this long and the view
  /// pages to that day (Structured's hover, ADR-0015).
  static const hoverSwitch = Duration(milliseconds: 700);

  /// A mouse rests on a control this long before its tooltip shows, so a
  /// control that slides under a resting pointer (a sheet opening) shows
  /// none. A tooltip's overlay re-parents the routes' semantics, and on the
  /// web that drops the focused field's keys (CI a11y-web, 2026-11-01).
  static const tooltipWait = Duration(milliseconds: 500);
}

/// Concept E's glass elevation (ED-210), light values; the dark theme's
/// shadows are black at 18 / 22 / 26 / 50 % (ED-181) and come with the
/// components in M18.3–M18.4.
abstract final class DotElevation {
  /// Tier 2 (Day ▾): `0 6 16`, ink at 10 %. Today's day sheet lifts off
  /// the page with it, upward.
  static const sheet = [
    BoxShadow(color: Color(0x1A241F2B), offset: Offset(0, -6), blurRadius: 16),
  ];

  /// Tier 3 (floating bar, +, menus): `0 10 30`, ink at 12 %.
  static const floating = [
    BoxShadow(color: Color(0x1F241F2B), offset: Offset(0, 10), blurRadius: 30),
  ];
}

/// Width classes that pick the shell (docs/10 §4). Layout adapts by these,
/// never by platform.
enum WidthClass {
  /// < 600: phones.
  compact,

  /// 600–840: tablets, narrow windows.
  medium,

  /// ≥ 840: Mac, web, large tablets.
  expanded;

  static const double mediumFrom = 600;
  static const double expandedFrom = 840;

  /// Class of a layout [width] in logical pixels.
  static WidthClass of(double width) => width >= expandedFrom
      ? expanded
      : width >= mediumFrom
      ? medium
      : compact;
}
