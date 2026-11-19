import 'package:flutter/widgets.dart';

/// What a Brain dump or Routine tab of Add needs: the day Add opened on,
/// today, [done] to close Add once that tab's proposal opens, and whether
/// it sits [embedded] in a scrolling popover (E-R2-36) rather than filling
/// a sheet.
typedef AddModeArgs = ({
  DateTime day,
  DateTime today,
  VoidCallback done,
  bool embedded,
});

/// Builds one of Add's other modes.
typedef AddModeBuilder =
    Widget Function(BuildContext context, AddModeArgs args);

/// Add's Brain dump and Routine tabs (G2-8, ED-139, ED-152). They belong
/// to other features, so the app puts them here, above the navigator, and
/// Create task reads them: features never import each other's widgets
/// (CLAUDE.md §3). Without a scope, Create task shows the Task tab alone.
class AddModesScope extends InheritedWidget {
  const AddModesScope({
    required this.brainDump,
    required this.routine,
    required super.child,
    super.key,
  });

  final AddModeBuilder brainDump;
  final AddModeBuilder routine;

  static AddModesScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AddModesScope>();

  @override
  bool updateShouldNotify(AddModesScope old) =>
      old.brainDump != brainDump || old.routine != routine;
}
