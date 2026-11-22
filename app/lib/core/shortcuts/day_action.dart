import 'package:flutter/widgets.dart';

/// What the Day menu does (ED-093): the same actions from the Day ▾
/// button on every platform, the Mac's menu-bar Day menu and ⌘K. The
/// screen that shows a day runs them (`DayActionScope`), so a menu above
/// every route needs no feature import.
enum DayAction {
  extend5,
  extend15,
  extend30,
  thenShiftRest,
  shiftRestFromHere,
  rebalance,
  brainDump,
  dropRoutine,
  oneThing,
  duplicate,
  copyText,
  reviewDay,
  weekReview,
  goToDate,
  lowEnergy,
  planReality,
  showLess,
  showEverything,
  settings,
}

/// Sent to whatever has focus by the Mac menu bar's Day menu (and so ⌘K);
/// the shown day's `DayActionScope` handles it.
final class DayActionIntent extends Intent {
  const DayActionIntent(this.action);

  final DayAction action;
}
