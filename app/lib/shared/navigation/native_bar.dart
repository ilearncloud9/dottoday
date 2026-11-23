import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// What the native iPhone bar answers (ED-128 N3).
sealed class NativeBarEvent {
  const NativeBarEvent();
}

/// A tab was tapped: its index in the configured items.
final class NativeBarSelect extends NativeBarEvent {
  const NativeBarSelect(this.index);

  final int index;
}

/// The + was tapped.
final class NativeBarAdd extends NativeBarEvent {
  const NativeBarAdd();
}

/// Which native navigation the device has.
enum NativeBarKind {
  /// The iPhone's bottom row (ED-124).
  phone,

  /// The iPad's top tabs and sidebar, drawn by iPadOS (R2-1, iPadOS 18+).
  pad,
}

/// The native navigation behind a seam, so the shell stays testable; the
/// data layer implements it over the `dottoday/native_tab_bar` channel.
abstract interface class NativeBar {
  NativeBarKind get kind;

  /// Shows [items] with [selected] lit and the + named [addLabel].
  Future<void> configure(ShellBar bar);

  /// Fades the row out (false) under a Flutter sheet or dialog, or back.
  Future<void> setVisible({required bool visible});

  /// Takes the row, or the iPad's tabs and sidebar, out of sight while a
  /// whole-window screen (Focus, ED-285) is up (true), or back.
  Future<void> setHidden({required bool hidden});

  /// Takes the row away (the shell left the compact phone layout).
  Future<void> remove();

  Stream<NativeBarEvent> get events;
}

/// Counts the sheets and dialogs open on the root navigator: the native
/// row sits above Flutter, so it hides while any is up (owner, M18.6).
final class NativeBarObserver extends NavigatorObserver {
  /// Open sheets and dialogs.
  static final popups = ValueNotifier<int>(0);

  /// Whole-window screens up (Focus, ED-285): the native navigation hides
  /// while any is. Each raises it while mounted.
  static final wholeWindow = ValueNotifier<int>(0);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_covers(route)) popups.value++;
  }

  /// A sheet or dialog, or iOS's card sheet (a page route, not a popup:
  /// found on the iPhone in M20.3, where the row covered Rebalance's
  /// Discard).
  static bool _covers(Route<dynamic> route) =>
      route is PopupRoute || route is CupertinoSheetRoute;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _gone(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _gone(route);

  void _gone(Route<dynamic> route) {
    if (_covers(route) && popups.value > 0) popups.value--;
  }
}

/// iPhone compact with the native row (ED-124): the content runs under
/// it; a transparent spacer its height keeps snackbars above it.
class NativeBarShell extends StatefulWidget {
  const NativeBarShell({
    required this.native,
    required this.bar,
    required this.body,
    super.key,
  });

  final NativeBar native;
  final ShellBar bar;
  final Widget body;

  /// The iPad's navigation sits outside the Flutter view; the iPhone's
  /// row floats over it and needs the strip.

  /// The row's height and its 21 pt from the bottom (ED-124).
  static const double clearance = DotSize.nativeBar + DotSize.nativeBarEdge;

  @override
  State<NativeBarShell> createState() => _NativeBarShellState();
}

class _NativeBarShellState extends State<NativeBarShell> {
  StreamSubscription<NativeBarEvent>? _events;

  @override
  void initState() {
    super.initState();
    _events = widget.native.events.listen(_onEvent);
    NativeBarObserver.popups.addListener(_onPopups);
    NativeBarObserver.wholeWindow.addListener(_onWholeWindow);
  }

  @override
  void dispose() {
    unawaited(_events?.cancel());
    NativeBarObserver.popups.removeListener(_onPopups);
    NativeBarObserver.wholeWindow.removeListener(_onWholeWindow);
    unawaited(widget.native.remove());
    super.dispose();
  }

  void _onEvent(NativeBarEvent event) => switch (event) {
    NativeBarSelect(:final index) => widget.bar.onSelect(index),
    NativeBarAdd() => widget.bar.onAdd?.call(),
  };

  void _onWholeWindow() => unawaited(
    widget.native.setHidden(hidden: NativeBarObserver.wholeWindow.value > 0),
  );

  // A dialog closing over a whole-window screen keeps the row away.
  void _onPopups() => unawaited(
    widget.native.setVisible(
      visible:
          NativeBarObserver.popups.value == 0 &&
          NativeBarObserver.wholeWindow.value == 0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    // After the frame: the bar shows what this build shows.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(widget.native.configure(widget.bar)),
    );
    return Scaffold(
      extendBody: true,
      // The iPad's docked sidebar arrives as a side inset: content starts
      // beside it, and the page ground carries on underneath.
      body: widget.native.kind == NativeBarKind.pad
          ? SafeArea(top: false, bottom: false, child: widget.body)
          : widget.body,
      // The row sits 21 above the screen's edge, not the safe area; the
      // iPad's navigation is outside the Flutter view.
      bottomNavigationBar: widget.native.kind == NativeBarKind.phone
          ? const SizedBox(height: NativeBarShell.clearance)
          : null,
    );
  }
}
