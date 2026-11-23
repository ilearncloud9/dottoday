import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/focus/focus_view.dart';
import 'package:dottoday/shared/navigation/native_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Focus (`/focus/:id`, docs/09 M10.5; E-R2-9, ED-285): the whole window
/// at every width, over the shell, whose tabs keep their state. Phones,
/// compact and medium windows show one column; expanded windows two
/// ([FocusView]). The native navigation hides while it is up. Esc or
/// ‹ Today leaves: back where you came from, or Today from a link.
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    NativeBarObserver.wholeWindow.value++;
    // After the frame: providers don't change while the tree builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(focusTaskProvider.notifier).open(widget.id);
    });
  }

  @override
  void dispose() {
    NativeBarObserver.wholeWindow.value--;
    super.dispose();
  }

  void _leave() {
    if (_leaving) return;
    _leaving = true;
    ref.read(focusTaskProvider.notifier).close();
    final router = GoRouter.of(context);
    router.canPop() ? router.pop() : router.go(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context) {
    // An owner switch clears the task in Focus (CR-160 I5): leave.
    ref.listen(focusTaskProvider, (before, now) {
      if (before == widget.id && now == null) _leave();
    });
    // System Back too: Focus is no longer up.
    return PopScope(
      onPopInvokedWithResult: (popped, _) {
        if (popped && !_leaving) {
          _leaving = true;
          ref.read(focusTaskProvider.notifier).close();
        }
      },
      child: Scaffold(
        backgroundColor: DotTheme.of(context).colors.surface,
        body: SafeArea(
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): _leave,
            },
            child: Focus(
              autofocus: true,
              child: FocusView(id: widget.id, onLeave: _leave),
            ),
          ),
        ),
      ),
    );
  }
}
