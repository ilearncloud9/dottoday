import 'package:dottoday/core/theme/dot_colors.dart';
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

  /// Month's day cards in the Workspace (E-R2-30): 12.
  static const double monthCard = 12;

  /// The inspector's fields (6) and its Done / Focus / Shift rest (10).
  static const double field = 6;
  static const double inspectorButton = 10;

  /// A card inside a sheet (E-Phones-2): 22 on iPhone, 16 on Android.
  static const double sheetCard = 22;
  static const double sheetCardAndroid = 16;

  /// The now pill (9, E rules §5.3).
  static const double nowPill = 9;

  /// The Undo toast: 16 on Apple platforms, the M3 snackbar's 8 elsewhere
  /// (E-R2-7).
  static const double toast = 16;
  static const double toastMaterial = 8;

  /// The web bar's current-icon box and its Add button (E-MobileWeb).
  static const double webIndicator = 8;
  static const double webAdd = 12;

  /// The selection card (E-R2-6, 26).
  static const double selectionCard = 26;

  /// The tip pill (20).
  static const double tip = 20;
  static const double pill = 999;

  /// Android FAB: rounded square (a §4 idiom).
  static const double fabAndroid = 16;

  /// Mac/web rail items.
  static const double railItem = 16;

  /// Chips on Android: fully round, as every Concept E chip (§6.3).
  static const double chipAndroid = pill;

  /// The Workspace sidebar's row tint with a pointer (E-FullA-v2): 8.
  static const double sidebarRow = 8;

  /// Android's selected day in the week strip: a tonal pill (E-Phones).
  static const double stripPillAndroid = 22;
}

/// Dot and thread sizes (docs/10 §2.3).
abstract final class DotSize {
  /// Widest a single list column grows on Mac/web before it centres
  /// (Inbox, Search; §4 expanded).
  static const double readableColumn = 640;

  /// The iPhone's glass capsule in Today's top row (ED-034): 48 tall (the
  /// board's 44 plus 4, so Sync keeps the 48 target the device sweep
  /// checks), with the 32 profile circle and a 20 Sync glyph (Android's
  /// bare glyph is 22).
  static const double capsule = 48;
  static const double capsuleAvatar = 32;
  static const double headerGlyph = 20;
  static const double headerGlyphAndroid = 22;

  /// Sync's state dot (rules §4, 8 px with a 2 px ring) and its count
  /// badge (E-Phones, 20).
  static const double syncDot = 8;
  static const double syncDotRing = 2;
  static const double badge = 20;

  /// The week strip's day (E-Phones): iPhone a 34 circle; Android a 52 × 60
  /// tonal pill around the selected day's name and date.
  static const double stripCircle = 34;
  static const double stripPillWidth = 52;
  static const double stripPillHeight = 60;

  /// An empty day's actions (E-Phones): 46 tall, up to 250 wide.
  static const double emptyAction = 46;
  static const double emptyActionWidth = 250;

  /// Android's floating toolbar (ED-125): 72 tall, 36 round, 16 from the
  /// start, 24 above the bottom, the + 56 beside it 8 away.
  static const double androidBar = 72;
  static const double androidBarBottom = 24;
  static const double androidFab = 56;
  static const double androidFabBottom = 32;

  /// The iPhone's native row (ED-124): about 63 tall (iOS sets it), 21
  /// from the bottom.
  static const double nativeBar = 63;
  static const double nativeBarEdge = 21;

  /// The compact web bar (E-MobileWeb): 56 tall, items 48, the current
  /// icon in a 56 × 28 box; the Add button above it 48 tall.
  static const double webBar = 56;
  static const webBarIndicator = Size(56, 28);

  /// The sidebar of places on tablets, Mac and web (rules §6.2: 216).
  static const double sidebar = 216;

  /// The Workspace sidebar's rows (E-FullA-v2): 30 with a pointer (Mac,
  /// a mouse-driven browser; WCAG 2.5.8 holds at 24, ED-260), the touch
  /// height on tablets and touch-first web (ED-261).
  static const double sidebarRowPointer = 30;

  /// The Workspace toolbar (E-FullA-v2): 52 tall, its controls 30 with a
  /// pointer, the search pill at least 176 wide.
  static const double workspaceToolbar = 52;
  static const double workspaceControl = 30;
  static const double workspaceSearch = 176;

  /// The Plan panel (rules §9.16): its section headings 30 tall, an 8 wide
  /// edge to drag, and how far past the minimum a drag hides it.
  static const double planHeading = 30;
  static const double planEdge = 8;
  static const double planHideSlack = 40;

  /// The hour grid (E-FullA-v2 Week, M19.2 part 2): 84 px an hour, the
  /// 44 hour-label gutter, day columns at least 144 wide under a 46 header,
  /// blocks inset 4 from their column, the 32 ring (a short task's pill is
  /// 21 tall with a 17 dot), the 4 px thread 23 in from the column's edge,
  /// and the 24 overlap knot.
  static const double gridHour = 84;

  /// The Day view's thread on hours (E-FullA-v2 web Day): 70 px an hour.
  static const double gridDayHour = 70;
  static const double gridGutter = 44;
  static const double gridColumn = 144;
  static const double gridHeader = 46;
  static const double gridInset = 4;
  static const double gridRing = 32;
  static const double gridPill = 21;
  static const double gridPillDot = 17;
  static const double gridThread = 4;
  static const double gridThreadX = 23;
  static const double gridKnot = 24;

  /// The now dot on today's thread (E-FullA-v2 Week): 14 with a 2 edge.
  static const double gridNowDot = 14;

  /// The narrowest week grid the Plan panel leaves room for: 3 days of 144
  /// and the 44 hour labels (ED-170). Narrower, the panel hides itself.
  static const double weekGridMin = 3 * gridColumn + gridGutter;

  /// The hour grid at touch sizes (E-R2-2, ED-269): 96 px an hour, columns
  /// at least 180 under a 60 header; rings 36, the live task's 45; a short
  /// task (under 35 min) is a pill at least 20 tall, its dot 28 from 44
  /// tall and 24 below, its corners at most 16.
  static const double gridTouchHour = 96;
  static const double gridTouchColumn = 180;
  static const double gridTouchHeader = 60;
  static const double gridTouchRing = 36;
  static const double gridTouchLiveRing = 45;
  static const double gridTouchPill = 20;
  static const double gridTouchPillTall = 44;
  static const double gridTouchPillDot = 24;
  static const double gridTouchPillDotTall = 28;
  static const double gridTouchPillRadius = 16;

  /// The narrowest touch week grid the Plan panel leaves room for: 3 days
  /// of 180 and the hour labels (ED-269).
  static const double weekGridTouchMin = 3 * gridTouchColumn + gridGutter;

  /// Window widths from which the toolbar has room for "Search or run" in
  /// full (rules §12.3): the board's 1280 has it; touch sizes need more.
  static const double workspaceToolbarRoom = 1100;
  static const double workspaceToolbarTouchRoom = 1360;
  static const double sidebarGlyph = 17;

  /// The right-hand panel at the expanded width: the task editor
  /// (`A-mac-editor`: 640 of 2000 px at 1280) and proposals (docs/10 §4).
  static const double sidePanel = 420;

  /// The Workspace inspector (E-FullA-v2, ED-170 C1): 248 wide with 14
  /// inside; its 38 ring, the 36 "Need more time?" pill with 28 chips,
  /// the 32 Done / Focus / Shift rest buttons, the 58 label column, 26
  /// fields, 24 alert chips, 15 subtask boxes and the 22 overlap knot. With
  /// touch they grow to the touch height.
  static const double inspector = 248;
  static const double inspectorPad = 14;
  static const double inspectorRing = 38;
  static const double inspectorExtend = 36;
  static const double inspectorExtendChip = 28;
  static const double inspectorButton = 32;
  static const double inspectorLabel = 58;
  static const double inspectorField = 26;
  static const double inspectorChip = 24;
  static const double inspectorCheck = 15;
  static const double inspectorKnot = 22;

  /// The inspector's start and end boxes (46 and 50 drawn; one width), and
  /// the Repeat field's 11 chevron.
  static const double inspectorTime = 50;
  static const double inspectorChevron = 11;

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

  /// Sheet chrome (E-Phones-2): the iOS grabber 36 × 5, the Android
  /// handle 32 × 4, and the iOS close button's 32 pt circle with a 14 pt
  /// cross (its hit area stays 44).
  static const grabber = Size(36, 5);
  static const handleAndroid = Size(32, 4);
  static const sheetClose = 32.0;
  static const sheetCloseGlyph = 14.0;

  /// A tag ("new", "no room · to the Inbox", "simple rules"): 20 or 24
  /// tall, fully round.
  static const double tag = 20;
  static const double tagLarge = 24;

  /// The state kit (E-G4-7-States A1, A5, A6): the icon's 56 pt circle
  /// and 26 pt glyph; the skeleton's two bars (74 × 9 and up to 150 × 12).
  static const double stateIcon = 56;
  static const double stateGlyph = 26;

  /// The warning beside an error at a field (15, E-G4-7-States D).
  static const double fieldErrorGlyph = 15;
  static const skeletonMeta = Size(74, 9);
  static const skeletonTitle = Size(150, 12);

  /// The Undo toast (E-R2-7): at least 52 tall; on wide screens 400 wide
  /// on Apple platforms and 440 (the M3 snackbar) elsewhere.
  static const double toast = 52;
  static const double toastWide = 400;
  static const double toastWideMaterial = 440;

  /// A selection card action, icon over label (E-R2-6: 52 tall).
  static const double selectionAction = 52;

  /// A sheet's main action (E-Phones-2 "Add to day": 54 tall).
  static const double primaryButton = 54;

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

  /// A pointer's floor (WCAG 2.2 · 2.5.8): the Mac and a mouse-driven
  /// browser (ED-260); touch keeps [min].
  static const double pointer = 24;
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

  /// The view tab raised in the Workspace's segmented control
  /// (E-FullA-v2): `0 1 3` at 16 %.
  static List<BoxShadow> segment(DotColors c) => [
    BoxShadow(
      color: c.shadow.withValues(alpha: 0.16),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  /// A Workspace block while dragged (ED-116, G3-5 option C): `0 8 18`
  /// at 10 % under its edge, in the theme's shadow colour.
  static List<BoxShadow> blockLift(DotColors c) => [
    BoxShadow(
      color: c.shadow.withValues(alpha: 0.1),
      offset: const Offset(0, 8),
      blurRadius: 18,
    ),
  ];

  /// A later overlap stacked over a block at touch sizes (E-R2-2's Call
  /// with Sam): a 1 px ring at 10 % and `0 4 12` at 12 %.
  static List<BoxShadow> blockOver(DotColors c) => [
    BoxShadow(color: c.shadow.withValues(alpha: 0.1), spreadRadius: 1),
    BoxShadow(
      color: c.shadow.withValues(alpha: 0.12),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  /// The iPhone glass capsule (ED-034): `0 4 12` at 8 % and a 0.5 px edge
  /// at 10 %, in the theme's shadow colour (ink light, black dark).
  static List<BoxShadow> capsule(DotColors c) => [
    BoxShadow(color: c.shadow.withValues(alpha: 0.1), spreadRadius: 0.5),
    BoxShadow(
      color: c.shadow.withValues(alpha: 0.08),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
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

/// How much of the frosted Android chrome is its fill (ED-125): the
/// toolbar and the Day button 72 %, the + 78 %; the rest is the blurred
/// content behind (24 blur, 140 % saturation).
abstract final class ChromeAlpha {
  static const double bar = 0.72;
  static const double fab = 0.78;

  /// The frost's blur radius (24 on the board; sigma is half of it).
  static const double blur = 24;

  /// The iPhone glass capsule's blur (16 on E-Phones, ED-034).
  static const double glassBlur = 16;
}
