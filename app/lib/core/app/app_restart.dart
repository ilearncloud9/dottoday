import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owns the app's provider container and can replace it (docs/09 M3f.9):
/// after the database is replaced, providers that failed to open the old
/// one would otherwise keep their error, so the app restarts with a fresh
/// container and every screen remounts.
class AppRestart extends StatefulWidget {
  const AppRestart({required this.create, required this.child, super.key});

  /// A new container for each (re)start.
  final ProviderContainer Function() create;
  final Widget child;

  /// Restarts the app above [context]; does nothing outside one (tests).
  static void of(BuildContext context) =>
      context.findAncestorStateOfType<_AppRestartState>()?._restart();

  @override
  State<AppRestart> createState() => _AppRestartState();
}

class _AppRestartState extends State<AppRestart> {
  late ProviderContainer _container = widget.create();
  var _key = UniqueKey();
  var _restarting = false;

  // Two frames, not one: the old tree must unmount before the new one
  // mounts. Swapping in a single frame mounts the new tree first, and on
  // the Mac the old `PlatformMenuBar`'s dispose then clears the menus the
  // new one just set (found by the parity run, M8.4).
  void _restart() {
    if (_restarting) return;
    setState(() => _restarting = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final old = _container;
      setState(() {
        _container = widget.create();
        _key = UniqueKey();
        _restarting = false;
      });
      // Nothing listens to the old one any more.
      old.dispose();
    });
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_restarting) return const SizedBox.shrink();
    return UncontrolledProviderScope(
      key: _key,
      container: _container,
      child: widget.child,
    );
  }
}
