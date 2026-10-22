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

  void _restart() {
    final old = _container;
    setState(() {
      _container = widget.create();
      _key = UniqueKey();
    });
    // After this frame, when nothing listens to the old one any more.
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UncontrolledProviderScope(
    key: _key,
    container: _container,
    child: widget.child,
  );
}
