import 'dart:async';

import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/editing/inspected_task.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/workspace_routes.dart';
import 'package:dottoday/core/theme/dot_idiom.dart';
import 'package:dottoday/core/theme/dot_metrics.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/links/browser_history.dart';
import 'package:dottoday/data/links/task_place.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/features/timeline/widgets/task_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Keeps the open task and the address in step (ED-097, CR-068): a view's
/// `?task=<id>` opens the task where this width edits it, the panel at the
/// expanded width, the sheet elsewhere, and on the Workspace's Day, 3 days
/// and Week the inspector (E-FullA-v2, ED-391); tablets edit in the panel
/// from medium width (ED-273); losing it (Back, a link) closes
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
  /// The task shown now, and where: the panel, the inspector or the sheet.
  String? _shown;
  var _where = _Where.sheet;

  /// Set while the host closes a task itself, so it isn't taken for the
  /// user's own close.
  var _closing = false;

  /// The editor was open over the inspector when the address moved to
  /// another task: it follows to that task (a click on another block
  /// while editing, ED-391).
  var _keepEditor = false;

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
    _where = _whereFor(_uri.path);
    switch (_where) {
      case _Where.inspector:
        ref.read(inspectedTaskProvider.notifier).show(id);
        if (_keepEditor) ref.read(editingTaskProvider.notifier).open(id);
        _keepEditor = false;
        return;
      case _Where.panel:
        ref.read(editingTaskProvider.notifier).open(id);
        return;
      case _Where.sheet:
        break;
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

  /// Where [path] shows a task at this width: the Workspace's grid views
  /// in Full pick it into the inspector (ED-170 C1).
  _Where _whereFor(String path) {
    final width = AppLayout.classOf(context);
    final simple =
        ref.read(layoutPolicyProvider).visibility(FeatureId.taskSheet) ==
        FeatureVisibility.simplified;
    // Tablets: option D's editor in the panel from medium width, never the
    // Mac inspector (ED-273, ED-274).
    if (touchApp(context) && !simple && width != WidthClass.compact) {
      return _Where.panel;
    }
    if (width != WidthClass.expanded) return _Where.sheet;
    final full =
        ref.read(layoutPolicyProvider).visibility(FeatureId.spread) !=
        FeatureVisibility.simplified;
    // Only where an inspector is on screen (the Workspace frame).
    final inspector = full && workspaceInspects(path) && InspectorFrames.any;
    return inspector ? _Where.inspector : _Where.panel;
  }

  /// Closes the shown task because the address no longer has it.
  void _closeShown() {
    final id = _shown!;
    if (_where != _Where.sheet) {
      _keepEditor =
          _where == _Where.inspector && ref.read(editingTaskProvider) == id;
      _closing = true;
      ref.read(inspectedTaskProvider.notifier).close();
      // The editor opened from the inspector goes with its task.
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
    ref
      ..listen(editingTaskProvider, (previous, next) {
        // Closing the editor over the inspector goes back to it (ED-391).
        if (_closing || _where != _Where.panel) return;
        if (previous != null && next == null && previous == _shown) {
          _closedByUser(previous);
        }
      })
      ..listen(inspectedTaskProvider, (previous, next) {
        if (_closing || _where != _Where.inspector) return;
        if (previous != null && next == null && previous == _shown) {
          _closedByUser(previous);
        }
      });
    return widget.child;
  }
}

/// Where the host shows the address's task.
enum _Where { sheet, panel, inspector }
