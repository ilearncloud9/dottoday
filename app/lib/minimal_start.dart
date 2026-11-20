import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Minimal opens on Now (ED-068, E-PhonesMinimal frame 1): once, when the
/// profile first loads, a launch that is still on plain Today moves to
/// Now. A link to another place, or a later switch to Minimal in
/// Settings, stays where it is.
class MinimalStart extends ConsumerStatefulWidget {
  const MinimalStart({required this.shell, required this.child, super.key});

  final StatefulNavigationShell shell;
  final Widget child;

  @override
  ConsumerState<MinimalStart> createState() => _MinimalStartState();
}

class _MinimalStartState extends ConsumerState<MinimalStart> {
  bool _decided = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      currentProfileProvider,
      (_, next) => _decide(next.hasValue),
      fireImmediately: true,
    );
  }

  void _decide(bool loaded) {
    if (_decided || !loaded) return;
    _decided = true;
    final policy = ref.read(layoutPolicyProvider);
    if (policy.visibility(FeatureId.navigation) !=
        FeatureVisibility.simplified) {
      return;
    }
    final launch = GoRouter.maybeOf(context);
    final at = launch?.state.uri.path;
    if (widget.shell.currentIndex != ShellTab.today.index) return;
    if (at != null && at != AppRoutes.today) return;
    // After this frame: the shell is mid-build when the profile is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.shell.goBranch(ShellTab.now.index);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
