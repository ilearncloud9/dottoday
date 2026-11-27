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
  /// The in-app reminder strip's card (E-R2-20, ED-467).
  static const double alertStrip = 18;

  /// A Settings notice (E-R2-20 §3): 18 on iPhone, 16 on Android.
  static const double notice = 18;
  static const double noticeMaterial = 16;

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

  /// A choice row's tint in a pick list (E-R2-34: 16).
  static const double choice = 16;

  /// An iPhone Settings row's icon tile (E-Phones Settings: 36 square, 9).
  static const double iconTile = 9;

  /// The open page's row in Settings' list pane on Android tablets
  /// (E-R2-11, M3 list-detail): 14.
  static const double paneRowAndroid = 14;

  /// Month's day cards in the Workspace (E-R2-30): 12.
  static const double monthCard = 12;

  /// The Mac and web popovers (E-R2-36, ED-342): 14, and the Add title
  /// box and summary card inside one: 12.
  static const double popover = 14;
  static const double popoverCard = 12;

  /// The iPad's Create task popover (E-R2-3, ED-271): 26.
  static const double tabletPopover = 26;

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

  /// A day tile in the Routines week strip (E-R2-22: 14).
  static const double dayTile = 14;

  /// Android's day chips in a schedule sheet (E-Phones "✓Mon").
  static const double dayChipAndroid = 8;
}

/// Dot and thread sizes (docs/10 §2.3).
abstract final class DotSize {
  /// Widest a single list column grows on Mac/web before it centres
  /// (Inbox, Search; §4 expanded).
  static const double readableColumn = 640;

  /// Each side of Focus on an expanded window (E-R2-9 B, ED-285): the
  /// ring and title, the step and actions, at most this wide.
  static const double focusSide = 400;

  /// Settings' list pane in two panes (E-R2-11, ED-291; E-FullA-v2 web):
  /// 380 on iPad, 412 on Android tablets (M3 list-detail), 360 on the Mac
  /// and the web.
  static const double settingsListIos = 380;
  static const double settingsListAndroid = 412;
  static const double settingsListWide = 360;

  /// Narrowest the detail pane may be beside the list: the phone width
  /// its pages are drawn at (E-R2-11 "at phone sizes, widened to their
  /// pane"). Narrower, Settings stacks as on phones (M20.7 part 5a).
  static const double settingsDetailMin = 390;

  /// Mac/web Settings pages as forms (E-FullA-v2, ED-450): the
  /// right-aligned "Label:" column, the gap to its control, a control's
  /// height (pop-ups, buttons, fields), the checkbox and a time field.
  static const double formLabel = 150;
  static const double formGap = 14;
  static const double formControl = 26;
  static const double formCheck = 16;

  /// Account's Name field on a Mac/web form (ED-450).
  static const double formNameField = 240;

  /// Wake Up and Wind Down on a Mac/web form (ED-452): the night dial's
  /// width, and the content width from which the dial sits beside the
  /// week table (a 920 pane) instead of above it.
  static const double wwdDial = 280;
  static const double wwdSideBySide = 860;

  /// Widest Wake Up and Wind Down's form grows, so the dial can sit
  /// beside the table (ED-452); other pages keep [readableColumn].
  static const double wwdPageMax = 1120;

  /// Narrower than this beside the label column, a form row stacks its
  /// label over its control (200 % text, a narrow pane).
  static const double formControlMin = 280;

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

  /// An empty day's actions (E-Phones): 46 tall drawn (48 to touch, the
  /// rest is padding; M19.7), up to 250 wide.
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

  /// Minimal's sidebar on Mac and web (ED-207).
  static const double sidebarMinimal = 200;

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

  /// Minimal's horizon (E rules §5.3, ED-241): the waking day laid flat,
  /// a 3 px line, 14 px dots with a 2 px ground cut-out, 16 px caps and
  /// the 14 px now-bead; labels under it.
  static const double horizonLine = 3;
  static const double horizonDot = 14;
  static const double horizonCut = 2;
  static const double horizonRing = 2.5;
  static const double horizonCap = 16;
  // The whole horizon is one tap target (opens Today), 48 as drawn.
  static const double horizonHeight = 48;

  /// Minimal Add's "Lands at" marker on its mini horizon (ED-217: 22,
  /// a 4 px ring), and the strip's height with its hour label.
  static const double landingMarker = 22;
  static const double landingRing = 4;
  static const double landingStrip = 44;

  /// Minimal's orb, the large now-dot (E rules §5.3, ED-106): 236 on the
  /// iPhone, 228 on Android; drawn on a 232 viewBox.
  static const double orbIphone = 236;
  static const double orbAndroid = 228;

  /// Next up's ring between tasks (E-R2-26): the task's colour, its icon.
  static const double nextUpRing = 200;
  static const double nextUpStroke = 12;
  static const double nextUpGlyph = 64;

  /// Now's "Also now" / "Next" rows (E rules §5.2): the dot 32 on the
  /// iPhone, 36 on Android, after a 72 label column.
  static const double nowRowDot = 32;
  static const double nowRowDotAndroid = 36;
  static const double nowRowLabel = 72;

  /// Done and Focus in the Mac and web Now pane (E-Minimal: 124).
  static const double nowActionWide = 124;

  /// The Mac's orb (ED-106: 280) and the web's (240).
  static const double orbMac = 280;
  static const double orbWeb = 240;

  /// Minimal's Day column on Mac and web (ED-232: 290).
  static const double dayColumn = 290;

  /// The Now pane's narrowest at 100 % text (ED-170: the action row's
  /// 460 and 2 × 45 padding); with the Day column it sets the fold point
  /// (≈ 1042 with the 200 sidebar), recomputed with the text size.
  static const double nowPaneMin = 550;

  /// The folded Day column's edge button (ED-170: 44).
  static const double dayEdge = 44;

  /// Below this the Mac toolbar narrows (ED-170: ≈ 1000).
  static const double narrowToolbar = 1000;

  /// Under this window height the orb draws at [shortOrb] (ED-170: 720,
  /// 72 %), unless text is above [shortOrbTextLimit] (130 %).
  static const double shortWindow = 720;
  static const double shortOrb = 0.72;
  static const double shortOrbTextLimit = 1.3;

  /// Text scale above which a row stacks what sits beside its text (a
  /// time, a button) under it instead (found at 200 % in M19.7).
  static const double stackAbove = 1.3;

  /// The Now pane's horizon and content width (ED-232: 700).
  static const double nowPaneContent = 700;

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

  /// Create task's and the editor's ring (E-Phones ED-140, option D) and
  /// the palette badge on it that opens Colour and icon.
  static const double formRing = 60;
  static const double formBadge = 24;

  /// The When card's rows and the Repeat · Energy pills (ED-140), and a
  /// step's check box.
  static const double formRow = 60;
  static const double stepBox = 22;

  /// The Mac and web Add popover (E-R2-36, ED-342): 404 wide, its arrow
  /// 7 out, the title's ring 34, a pointer's duration pill 26 tall.
  static const double addPopover = 404;

  /// A conflict card's "This device" / "Other device" column (E-G4-7 C2).
  static const double conflictLabel = 96;

  /// A notes conflict's version box before it scrolls (Q4i).
  static const double conflictNotesMax = 160;

  /// The first sync's progress line (E-G4-7 A2): 6 tall, rounded.
  static const double progressBar = 6;

  /// The Sync popover over the sidebar line (E-G4-7 B5): 360.
  static const double syncPopover = 360;

  /// The web caution note's amber rule on its leading edge (E-G4-7 Q2b).
  static const double cautionRule = 3;

  /// Go to date's popover (E-R2-36, ED-342): the month under the date
  /// button, as wide as its board frame.
  static const double goToDate = 360;
  static const double popoverArrow = 7;

  /// How far a popover's arrow sits from its end (E-R2-36: 349 of 404),
  /// so the popover hangs mostly toward the start of its button.
  static const double popoverArrowInset = 55;
  static const double popoverRing = 34;
  static const double popoverPill = 26;

  /// The Add title box's accent outline while it has the keys (1.5).
  static const double popoverFieldStroke = 1.5;

  /// Tablets' Add (E-R2-3, ED-271): the iPad's Create task popover, 400 ×
  /// 700 at most, and Android's M3 modal side sheet, 412 wide.
  static const double tabletAddWidth = 400;
  static const double tabletAddHeight = 700;
  static const double sideSheet = 412;

  /// The When picker's day bar (E-Phones-2, ED-099): a 48 pt touch row,
  /// the day's tasks 10 tall on its dashed line, the ring 24.
  static const double dayBar = 48;
  static const double dayBarBlock = 10;
  static const double dayBarRing = 24;
  static const double dayBarRingStroke = 3;

  /// Option D's "Need more time?" pill (E-Phones F3): at least 56 tall,
  /// its 44 pt chips inside with 6 around them.
  static const double extendPill = 56;

  /// A proposed block's empty dashed ring on the hour grid (E-R2-3): 18.
  static const double gridProposedRing = 18;
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

  /// Appearance's Theme thumbnails (E-G3-9b, ED-161): 72 × 48.
  static const double themeThumbWidth = 72;
  static const double themeThumbHeight = 48;

  /// Narrower than this, Layout's Everything · Less goes under its title:
  /// at the 48 pt touch height it doesn't fit beside it in a phone's card
  /// (350 at 390, M20.7).
  static const double layoutSegmentsBeside = 380;

  /// The preview's Now ring (Less).
  static const double previewRing = 56;

  /// An Inbox row's least height (E-R2-13: 64).
  static const double inboxRowMin = 64;

  /// A Search result's least height (E-R2-13: 60).
  static const double searchRowMin = 60;

  /// The Search or run palette's width (E-R2-30: 360 of an 819 frame of
  /// a 1280 window).
  static const double palette = 560;

  /// The web's Day ▾ popover (E-FullA-v2 frame 2: 330 at 1280).
  static const double webDayMenu = 330;

  /// The Routines page's widest on tablets, Mac and web, where its
  /// cards sit two to a row (E-R2-22 iPad).
  static const double routinesWide = 960;

  /// A page's icon tile beside its title (E-R2-22 Routines: 32).
  static const double pageTile = 32;

  /// The small hollow ring of a routine's mini thread and the Later
  /// pile (E-R2-22: 12, stroke 2), and the link between two rings.
  static const double miniRing = 12;
  static const double miniRingStroke = 2;
  static const double miniLink = 8;

  /// Narrowest a routine step keeps its length and arrows beside its
  /// name (E-R2-22 Edit routine); narrower, they take their own line.
  static const double stepRowMin = 330;

  /// A day tile in the Routines week strip (E-R2-22: 50 high).
  static const double dayTile = 50;

  /// Low-energy's ring around the one dot (E-R2-22: 96, stroke 8; the
  /// dot inside 44).
  static const double lowEnergyRing = 96;
  static const double lowEnergyRingStroke = 8;
  static const double lowEnergyDot = 44;

  /// Low energy's column on wide screens (E-R2-22 Web and Mac: 460 in
  /// a 760 frame).
  static const double lowEnergyColumn = 480;

  /// A task's dot on the phone day thread: ahead, calendar and concurrent
  /// now (Concept E §5.1); a done dot is [threadDoneDot].
  static const double threadDot = 34;

  /// A done task's solid dot on the phone day thread (Concept E §5.1).
  static const double threadDoneDot = 32;

  /// The Wake Up / Wind Down caps on the phone thread (ED-201).
  static const double threadCap = 34;

  /// The phones' day thread (owner 2026-11-21, ED-419, Full and Minimal):
  /// 52 dots, caps and now-card dot (50 done) overhanging the 48 column,
  /// rows as long as their task (main's 1.6 px a minute, 88 to 288).
  static const double phoneThreadDot = 52;
  static const double phoneThreadDoneDot = 50;
  static const double threadPerMinute = 1.6;
  static const double threadRowMin = 88;
  static const double threadRowMax = 288;

  /// The done circle at a thread row's end (ADR-0015), and its open ring
  /// (E rules §4.4: 2.5).
  static const double doneCircle = 28;
  static const double doneRing = 2.5;

  /// Marking done (the onboarding prototype's `.burst`, ED-490): a 3 ring
  /// in the task's colour grows from the circle to 2.1 and fades.
  static const double doneBurstRing = 3;
  static const double doneBurstScale = 2.1;

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

  /// The selection card at most this wide, centred (E-R2-6: 470 on
  /// tablets, the Mac and the web; a phone's is narrower).
  static const double selectionCardWide = 470;

  /// A grid block picked in multi-select (E-R2-6): a 2.5 accent edge and
  /// a 24 check badge at its top end, 8 in.
  static const double gridPickEdge = 2.5;
  static const double gridPickBadge = 24;

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

  /// Pick today's one thing (E-R2-34, ED-339): each choice a 30 hollow
  /// ring (stroke 3.5); the pick wears a 2.5 ring 5 outside it, in its
  /// own colour. Rows 52 high; the dialog 460 wide from medium width.
  static const double pickRing = 30;
  static const double pickRingStroke = 3.5;
  static const double pickHalo = 5;
  static const double pickHaloStroke = 2.5;
  static const double pickRow = 52;
  static const double pickDialog = 460;

  /// The Review place's half (ED-099, E-FullA-v2): below two of these
  /// side by side, Day review and Week in review stack.
  static const double reviewHalfMin = 360;

  /// Rebalance's faded ring for the day as it is (E-R2-35), beside the
  /// proposed dot.
  static const double proposalNowRing = 22;

  /// The lock after a pinned task's time on the plan (E-R2-35).
  static const double lockGlyph = 12;

  /// Rebalance's centred panel on the Mac and the web (E-R2-35).
  static const double rebalancePanel = 420;

  /// The Plan panel's Brain dump row (E-R2-37): below this width (at
  /// 100 % text) the note goes above the mic and Plan it.
  static const double dumpRowMin = 260;

  /// Break it down's step ring and row (E-R2-23).
  static const double stepRing = 26;
  static const double stepRow = 52;

  /// A small grey chip's own height (a step's length, E-R2-23); its tap
  /// target is padded to the platform's floor.
  static const double smallChipHeight = 30;

  /// The task's dot on Break it down's lead row (E-R2-23).
  static const double breakdownLead = 34;
  static const double dayDot = 44;

  /// The day dot on the Wake Up card (docs/15 §5 step 2).
  static const double wakeUpDayDot = 96;

  /// The Wake Up card as the thread (E-R2-19-B, ED-314): the time column,
  /// the mark column and its marks (Wake Up's sun, the first dot, the rest),
  /// the line between them, the gap between rows, and the widths it docks
  /// at beside Today (ED-456) and centres in on medium widths.
  static const double wakeCardTime = 58;
  static const double wakeCardMark = 48;
  static const double wakeCardSun = 40;
  static const double wakeCardFirst = 48;
  static const double wakeCardDot = 36;
  static const double wakeCardLine = 3;
  static const double wakeCardGap = 16;
  static const double wakeCardDock = 380;
  static const double wakeCardDockAndroid = 400;
  static const double wakeCardColumn = 480;

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

  /// The Focus screen's ring (E-R2-9, ED-286): 200 on phones and narrow
  /// windows, 168 on the whole window; a 15 stroke, a 64 glyph.
  static const double focusScreenRing = 200;
  static const double focusScreenRingWide = 168;
  static const double focusScreenStroke = 15;
  static const double focusScreenGlyph = 64;

  /// The mission screen's ring (docs/15 §8: 120 px).
  static const double missionRing = 120;

  /// A mission on the dawn sky (E-R2-19-B): the ring, its stroke, and the
  /// walker's height on Walk's ground line.
  static const double dawnRing = 236;
  static const double dawnRingStroke = 16;
  static const double dawnWalker = 88;

  /// The width E-R2-19-B draws a phone's sky at, which Catch the dot's
  /// paths are measured in.
  static const double dawnSkyWidth = 390;
  static const double dawnSkyHeight = 844;

  /// Stand up's phone (46 × 80) and Light's bulb (70 × 90) in the ring.
  static const double missionPhoneWidth = 46;
  static const double missionPhoneHeight = 80;
  static const double missionBulbWidth = 70;
  static const double missionBulbHeight = 90;

  /// Breathe's fingertip (40 × 56) and the press under it (44).
  static const double missionFingerWidth = 40;
  static const double missionFingerHeight = 56;
  static const double missionPress = 44;

  /// Catch the dot's dots: 72 on phones, 96 on tablets (E-R2-19-B-2).
  static const double catchDot = 72;
  static const double catchDotTablet = 96;

  /// The in-app reminder strip (E-R2-20, ED-467): the bell's circle and
  /// the pill actions' height.
  static const double alertBell = 32;
  static const double alertAction = 36;

  /// A Settings notice's pill (E-R2-20 §3): 36 on iPhone, 40 on Android.
  static const double noticeAction = 36;
  static const double noticeActionMaterial = 40;
  static const double focusGlyph = 48;
  static const double dayDotWatch = 18;
  static const double macRowDot = 26;
  static const double pickerDot = 22;

  /// A task's dot on the Calendar tab's day card (E-Phones Calendar).
  static const double calendarCardDot = 24;
  static const double weekDot = 8;

  /// A task's dot in a compact month cell (E-Phones Calendar: 6–7 px).
  static const double monthDot = 7;
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

  /// The year strip's month dots, option B (E-R2-34, ED-348): 50 across
  /// with a 5 ring, each a touch target.
  static const double yearMonthDot = 50;
  static const double yearMonthStroke = 5;

  /// A day of the year strip's open month (E-R2-34 option B).
  static const double yearDayDot = 10;
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

  /// Reading this device's tasks shows the loading dots only once it has
  /// taken longer than this (E-G4-7 A1, ED-482): a quick open shows none.
  static const loadingWait = Duration(milliseconds: 300);

  /// A dial drag pauses this long before its times are written: one
  /// write per move, not one per frame (Wake Up and Wind Down, ED-452).
  static const dragSettle = Duration(milliseconds: 400);
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

/// A control that can't be used right now (a Mac/web form's checkbox,
/// button or radio, ED-450): drawn at this opacity, its reason beside it.
abstract final class DotOpacity {
  static const double disabled = 0.45;

  /// The web caution note's amber wash over the panel (E-G4-7 Q2b).
  static const double cautionWash = 0.1;
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

/// The night dial in a schedule sheet (ED-083's layout rule, ED-084): 240
/// to 360 across, never stretched; the band is 12 % of it; labels sit
/// outside the band and only four of them.
abstract final class DotDial {
  static const double min = 240;
  static const double max = 360;
  static const double bandShare = 0.12;

  /// Room outside the band for the 12 AM / 6 AM / 12 PM / 6 PM labels.
  static const double labelRoom = 30;

  /// The moon and sun handles (a 44 pt touch target).
  static const double handle = 44;

  /// The night line along the inside of the night band.
  static const double nightLine = 3;

  /// The hour ticks: 6 pt, 12 pt at 12 and 6; inset from the band.
  static const double tick = 6;
  static const double tickMajor = 12;
  static const double tickInset = 10;

  /// The dotted day ring inside the band.
  static const double dot = 1.6;
  static const double dotInset = 4;

  /// One dot every 15 minutes of the day.
  static const int dotEvery = 15;

  /// The night's length in the centre, tried at each size in turn; when
  /// none fits it goes below the dial (ED-083 fit test).
  static const List<double> durationSizes = [34, 30, 28, 26];

  /// From this text scale the duration always sits below.
  static const double belowFromScale = 1.35;

  /// A handle moves 5 min a step, 30 with Shift (E-FullA-v2 Mac panel).
  static const int step = 5;
  static const int bigStep = 30;
}
