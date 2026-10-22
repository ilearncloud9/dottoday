import 'dart:ui';

/// One row of the design-review reference sheet (docs/10 §7.1, 08 §7): a
/// component golden next to the matching crop of its reference render.
final class SheetEntry {
  const SheetEntry({
    required this.name,
    required this.golden,
    required this.reference,
    required this.crop,
  });

  final String name;

  /// Golden PNG, relative to `app/`.
  final String golden;

  /// Reference PNG in `docs/design-references/png/`.
  final String reference;

  /// Region of [reference] in its own pixels (renders are 2×).
  final Rect crop;
}

const _shared = 'test/shared';

/// Every component of M3a against its render. Crops are measured on the 2×
/// renders: iPhone 780 × 1688, Android 824 × 1830, Mac 2560 × 1600.
const sheetEntries = <SheetEntry>[
  SheetEntry(
    name: 'DayDot + WeekStrip · light',
    golden: '$_shared/dot/goldens/week_strip_light_compact_2x.png',
    reference: 'Main.png',
    crop: Rect.fromLTRB(0, 100, 780, 420),
  ),
  SheetEntry(
    name: 'DayDot + WeekStrip · dark',
    golden: '$_shared/dot/goldens/week_strip_dark_compact_2x.png',
    reference: 'A-android-today.png',
    crop: Rect.fromLTRB(0, 90, 824, 390),
  ),
  SheetEntry(
    name: 'TaskDot · light',
    golden: '$_shared/dot/goldens/task_dot_light_compact_2x.png',
    reference: 'Main.png',
    crop: Rect.fromLTRB(60, 600, 200, 1460),
  ),
  SheetEntry(
    name: 'Thread + TaskRow + LiveRow · light',
    golden: '$_shared/dot/goldens/thread_main_light_compact_2x.png',
    reference: 'Main.png',
    crop: Rect.fromLTRB(56, 516, 724, 1456),
  ),
  SheetEntry(
    name: 'DayCard + DayPager · light',
    golden: '$_shared/dot/goldens/day_pager_light_compact_2x.png',
    reference: 'Main.png',
    crop: Rect.fromLTRB(0, 500, 780, 1500),
  ),
  SheetEntry(
    name: 'DayCard + DayPager · dark',
    golden: '$_shared/dot/goldens/day_pager_dark_compact_2x.png',
    reference: 'A-android-today.png',
    crop: Rect.fromLTRB(0, 480, 824, 1660),
  ),
  SheetEntry(
    name: 'MonthGrid compact · light',
    golden: '$_shared/dot/goldens/month_compact_oct_sun_light_compact_2x.png',
    reference: 'A-ios-today-month.png',
    crop: Rect.fromLTRB(0, 240, 780, 770),
  ),
  SheetEntry(
    name: 'MonthGrid compact, future month · light',
    golden:
        '$_shared/dot/goldens/month_compact_future_dec_light_compact_2x.png',
    reference: 'A-ios-future-month.png',
    crop: Rect.fromLTRB(0, 240, 780, 830),
  ),
  SheetEntry(
    name: 'MonthGrid expanded · light',
    golden: '$_shared/dot/goldens/month_expanded_oct_sun_light_expanded_1x.png',
    reference: 'A-mac-month.png',
    crop: Rect.fromLTRB(230, 230, 2500, 1560),
  ),
  SheetEntry(
    name: 'Shell, iPhone pill bar · light',
    golden: '$_shared/navigation/goldens/shell_iphone_light_compact_2x.png',
    reference: 'Main.png',
    crop: Rect.fromLTRB(0, 1480, 780, 1688),
  ),
  SheetEntry(
    name: 'Shell, Android bar + FAB · dark',
    golden: '$_shared/navigation/goldens/shell_android_dark_compact_2x.png',
    reference: 'A-android-today.png',
    crop: Rect.fromLTRB(0, 1480, 824, 1830),
  ),
  SheetEntry(
    name: 'Shell, Mac/web rail · light',
    golden: '$_shared/navigation/goldens/shell_rail_light_expanded_1x.png',
    reference: 'A-mac-today-alt1-spread.png',
    crop: Rect.fromLTRB(0, 0, 400, 1600),
  ),
  SheetEntry(
    name: 'Add A1 What · light',
    golden: 'test/features/task_editor/goldens/add_what_light_compact_2x.png',
    reference: 'A-ios-add-what.png',
    crop: Rect.fromLTRB(0, 288, 780, 1688),
  ),
  SheetEntry(
    name: 'Add A1 What · Android dark',
    golden:
        'test/features/task_editor/goldens/add_what_android_dark_compact_2x.png',
    reference: 'A-android-add-what.png',
    crop: Rect.fromLTRB(0, 310, 824, 1830),
  ),
  SheetEntry(
    name: 'Add A2 When + ThreadPicker · light',
    golden: 'test/features/task_editor/goldens/add_when_light_compact_2x.png',
    reference: 'A-ios-add-when.png',
    crop: Rect.fromLTRB(0, 288, 780, 1688),
  ),
  SheetEntry(
    name: 'Add A2 When · Android dark',
    golden:
        'test/features/task_editor/goldens/add_when_android_dark_compact_2x.png',
    reference: 'A-android-add-when.png',
    crop: Rect.fromLTRB(0, 310, 824, 1830),
  ),
  SheetEntry(
    name: 'Add A3 Duration sheet · light',
    golden:
        'test/features/task_editor/goldens/add_duration_light_compact_2x.png',
    reference: 'A-ios-add-duration.png',
    crop: Rect.fromLTRB(0, 760, 780, 1688),
  ),
  SheetEntry(
    name: 'Add A3 Duration sheet · Android dark',
    golden:
        'test/features/task_editor/goldens/add_duration_android_dark_compact_2x.png',
    reference: 'A-android-add-duration.png',
    crop: Rect.fromLTRB(0, 830, 824, 1830),
  ),
];
