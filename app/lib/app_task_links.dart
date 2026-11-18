import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:dottoday/data/links/browser_history.dart';
import 'package:dottoday/data/links/task_place.dart';
import 'package:dottoday/features/timeline/widgets/task_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Keeps the open task and the address in step (ED-097, CR-068): a view's
/// `?task=<id>` opens the task where this width edits it, the panel at the
/// expanded width, the sheet elsewhere; losing it (Back, a link) closes
/// it; closing it by hand removes it, as a Back step when it was opened
/// here and by a replace when the address arrived with it. So Refresh
/// keeps the task, Back closes it and Forward opens it again.
class TaskLinkHost extends ConsumerStatefulWidget {
  const TaskLinkHost({required this.router, required this.child, super.key});

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<TaskLinkHost> createState() => _TaskLinkHostState();
}

class _TaskLinkHostState extends ConsumerState<TaskLinkHost> {
  /// The task shown now, and whether in the panel (else the sheet).
  String? _shown;
  var _inPanel = false;

  /// Set while the host closes a task itself, so it isn't taken for the
  /// user's own close.
  var _closing = false;

  GoRouter get _router => widget.router;

  Uri get _uri => _router.routerDelegate.currentConfiguration.uri;

  @override
  void initState() {
    super.initState();
    _router.routerDelegate.addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    final want = AppRoutes.taskOf(_uri);
    if (want == _shown) return;
    if (_shown != null) _closeShown();
    _shown = want;
    if (want != null) unawaited(_show(want));
  }

  Future<void> _show(String id) async {
    final container = ProviderScope.containerOf(context);
    if (!await taskLinkVisible(container, id)) {
      // Not the user's, gone or in the Trash: Today, saying nothing (D2).
      if (mounted && _shown == id) _replace(AppRoutes.today);
      return;
    }
    // After the frame that shows the address's page: a sheet opened over
    // the outgoing page would leave with it (a link that also changes the
    // page, a redirect).
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || _shown != id) return;
    _inPanel = AppLayout.classOf(context) == WidthClass.expanded;
    if (_inPanel) {
      ref.read(editingTaskProvider.notifier).open(id);
      return;
    }
    final overlay = _router.routerDelegate.navigatorKey.currentContext;
    if (overlay == null || !overlay.mounted) return;
    await showTaskSheet(overlay, id);
    if (_closing) {
      _closing = false;
    } else if (_shown == id) {
      _closedByUser(id);
    }
  }

  /// Closes the shown task because the address no longer has it.
  void _closeShown() {
    final id = _shown!;
    if (_inPanel) {
      _closing = true;
      ref.read(editingTaskProvider.notifier).close();
      _closing = false;
      return;
    }
    final navigator = _router.routerDelegate.navigatorKey.currentState;
    if (navigator == null) return;
    _closing = true;
    navigator.popUntil(
      (route) => route.settings.name != taskSheetRouteName(id),
    );
  }

  /// The user closed task [id] (the panel's ✕, the sheet's swipe, Esc).
  void _closedByUser(String id) {
    _shown = null;
    final uri = _uri;
    if (AppRoutes.taskOf(uri) != id) return;
    if (TaskLinks.openedHere == id) {
      TaskLinks.openedHere = null;
      if (browserBack()) return;
    }
    _replace(AppRoutes.withoutTask(uri));
  }

  /// Goes to [location] in place of the current entry (no Back step).
  /// The host sits above the Router, so it asks from the navigator's
  /// context, below it.
  void _replace(String location) {
    final below = _router.routerDelegate.navigatorKey.currentContext;
    if (below == null) return _router.go(location);
    Router.neglect(below, () => _router.go(location));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(editingTaskProvider, (previous, next) {
      if (_closing || !_inPanel) return;
      if (previous != null && next == null && previous == _shown) {
        _closedByUser(previous);
      }
    });
    return widget.child;
  }
}
