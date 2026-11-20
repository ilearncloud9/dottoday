import 'dart:async';

import 'package:dottoday/core/editing/add_anchor.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/timeline/widgets/go_to_date.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Now's date, registered as the screen's date button: Go to date (⇧⌘T,
/// the web's g, Go › Go to Date…; ED-342) opens from it, as it does from
/// the Workspace's date pill. Found in M19.7: on Now the command did
/// nothing. A picked day opens on Today.
class NowDateAnchor extends StatelessWidget {
  const NowDateAnchor({required this.today, required this.child, super.key});

  final DateTime today;
  final Widget child;

  /// Opens Go to date on [today]; a picked day opens on Today.
  static void open(BuildContext context, DateTime today) => unawaited(
    showGoToDate(
      context,
      shown: today,
      today: today,
      onSelect: (d) => context.go(AppRoutes.day(d)),
    ),
  );

  @override
  Widget build(BuildContext context) =>
      DateAnchor(onOpen: () => open(context, today), child: child);
}
