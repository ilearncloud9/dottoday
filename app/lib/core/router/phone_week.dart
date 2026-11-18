import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Week on a phone (M19.1): phones have no Week view in Concept E (their
/// Calendar comes with M20.1), so `/week` there opens the nearest built
/// screen, Today on the same date (the owner's "Nearest built screen",
/// ED-380). Wider windows show [child], the Week itself.
class PhoneWeek extends StatefulWidget {
  const PhoneWeek({required this.to, required this.child, super.key});

  /// Where a phone goes instead: `/today` or `/day/<date>`.
  final String to;
  final Widget child;

  @override
  State<PhoneWeek> createState() => _PhoneWeekState();
}

class _PhoneWeekState extends State<PhoneWeek> {
  bool _leaving = false;

  @override
  Widget build(BuildContext context) {
    if (AppLayout.classOf(context) != WidthClass.compact) return widget.child;
    if (!_leaving) {
      _leaving = true;
      // After this frame: a route can't change while it builds.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) GoRouter.of(context).go(widget.to);
      });
    }
    return const SizedBox.shrink();
  }
}
