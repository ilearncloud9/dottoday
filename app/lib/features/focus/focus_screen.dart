import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/focus/focus_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Focus full screen (`/focus/:id`, phones and narrow windows; docs/09
/// M10.5). Leaving pops back, or goes to Today when opened from a link.
class FocusScreen extends StatelessWidget {
  const FocusScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    void leave() {
      final router = GoRouter.of(context);
      router.canPop() ? router.pop() : router.go(AppRoutes.today);
    }

    return Scaffold(
      backgroundColor: DotTheme.of(context).colors.surface,
      body: SafeArea(
        child: CallbackShortcuts(
          bindings: {const SingleActivator(LogicalKeyboardKey.escape): leave},
          child: Focus(
            autofocus: true,
            child: FocusView(id: id, onLeave: leave),
          ),
        ),
      ),
    );
  }
}

/// [child] (the tab's content) replaced by Focus while a task is in Focus
/// at the expanded width: centred in the content area, the rail kept, Esc
/// to leave (docs/10 §4, docs/09 M10.5).
class FocusFrame extends ConsumerWidget {
  const FocusFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(focusTaskProvider);
    final expanded =
        WidthClass.of(MediaQuery.sizeOf(context).width) == WidthClass.expanded;
    final open = id != null && expanded;
    void leave() => ref.read(focusTaskProvider.notifier).close();
    // Always this shape, so the tabs underneath keep their state while
    // Focus is up (the shell is never remounted).
    return IndexedStack(
      index: open ? 1 : 0,
      sizing: StackFit.expand,
      children: [
        child,
        if (open)
          Material(
            color: DotTheme.of(context).colors.surface,
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): leave,
              },
              child: FocusScope(
                autofocus: true,
                child: FocusView(key: ValueKey(id), id: id, onLeave: leave),
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
