import 'package:dottoday/core/editing/add_modes.dart';
import 'package:dottoday/features/routines/widgets/routine_add_tab.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:flutter/widgets.dart';

/// Add's Brain dump and Routine tabs (G2-8, ED-139, ED-152), put above the
/// navigator so Create task can show them without importing either
/// feature (CLAUDE.md §3). The app and the test harness both wrap with it.
Widget withAddModes(Widget child) => AddModesScope(
  // Plan it opens the proposal; Add steps aside first (ED-150).
  brainDump: (context, a) => BrainDumpBody(today: a.today, onPlanned: a.done),
  routine: (context, a) =>
      RoutineAddTab(day: a.day, today: a.today, onPicked: a.done),
  child: child,
);
