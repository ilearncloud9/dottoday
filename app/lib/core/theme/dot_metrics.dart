import 'package:dottoday/core/theme/tokens.dart';
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

  /// Hairline outline width (`0 0 0 1px outline`, §2.3).
  static const double hairline = 1;

  /// Extra bottom inset for content under a floating add button: 56 dp
  /// button + its 16 dp margin + 16 dp breathing room, so the end of a
  /// scrolled list is never hidden behind it (M0.13).
  static const double fabClearance = 56 + l + l;
}

/// Corner radii (docs/10 §2.3).
abstract final class DotRadii {
  static const double card = 16;
  static const double cardLarge = 18;
  static const double sheet = 28;
  static const double pill = 999;

  /// Android FAB: rounded square (a §4 idiom).
  static const double fabAndroid = 16;

  /// Mac/web rail items.
  static const double railItem = 16;

  /// M3 chips on Android (a §4 idiom); iOS chips are [pill].
  static const double chipAndroid = 8;
}

/// Dot and thread sizes (docs/10 §2.3).
abstract final class DotSize {
  /// Widest a single list column grows on Mac/web before it centres
  /// (Inbox, Search; §4 expanded).
  static const double readableColumn = 640;

  /// The right-hand panel at the expanded width: the task editor
  /// (`A-mac-editor`: 640 of 2000 px at 1280) and proposals (docs/10 §4).
  static const double sidePanel = 420;

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
  static const double liveDot = 42;
  static const double liveRing = 5;

  /// Outline of an upcoming dot (2.5 at row size, 2 in pickers / Mac rows).
  static const double dotOutline = 2.5;
  static const double smallDotOutline = 2;
  static const double dayDot = 44;

  /// The identity dot on Add step 1 (`A-ios-add-what`); step 2 uses
  /// [dayDot].
  static const double addDot = 64;
  static const double dayDotWatch = 18;
  static const double macRowDot = 26;
  static const double pickerDot = 22;
  static const double weekDot = 8;
  static const double tabDot = 10;
  static const double tabDotActive = 12;

  /// Coloured segment of a task on the thread (Watch 5).
  static const double segment = 6;

  /// Dotted free-time line.
  static const double freeLine = 2;

  /// Now-marker dot and its halo.
  static const double nowMarker = 16;
  static const double nowHalo = 4;

  /// Icon inside a row dot / a 24-unit nav icon.
  static const double rowIcon = 18;
  static const double navIcon = 24;
}

/// Minimum tap targets (docs/10 §2.3): 44 pt everywhere, 48 dp on Android.
abstract final class DotTouch {
  static const double min = 44;
  static const double android = kMinInteractiveDimension;

  /// Hold this long to pick a task up (03 §3.2 "long-press 250 ms").
  static const liftDelay = Duration(milliseconds: 250);

  /// Vertical drag per resize step on a segment's grip.
  static const double resizeStep = 12;
}

/// Shadow of floating elements: tab bar, FAB, menus (docs/10 §2.3).
abstract final class DotElevation {
  static const floating = [
    BoxShadow(
      color: DotPrimitives.shadow,
      offset: Offset(0, 8),
      blurRadius: 24,
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
