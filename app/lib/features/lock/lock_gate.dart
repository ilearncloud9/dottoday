import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/security/app_lock_store.dart';
import 'package:dottoday/domain/time/day_dot_geometry.dart';
import 'package:dottoday/shared/dot/day_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The optional app lock at the root (docs/06 §2, docs/09 M5.8): the lock
/// screen while locked, and a plain cover whenever the app is not in front
/// so the app switcher never shows tasks. Nothing when the lock is off.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

/// A leaf: only whether the app is in front.
class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  var _away = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = ref.read(appLockedProvider.notifier);
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        setState(() => _away = true);
      case AppLifecycleState.paused:
        lock.left();
        setState(() => _away = true);
      case AppLifecycleState.resumed:
        lock.returned();
        setState(() => _away = false);
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!appLockSupported) return widget.child;
    final setting = ref.watch(appLockSettingProvider);
    final locked = ref.watch(appLockedProvider);
    final on = setting.value?.enabled ?? false;
    // Unknown yet: cover, so a locked app never shows a frame of tasks.
    final cover = setting.isLoading || (on && _away);
    return Stack(
      children: [
        ExcludeSemantics(
          excluding: locked || cover,
          child: TickerMode(enabled: !locked, child: widget.child),
        ),
        if (locked)
          const Positioned.fill(child: LockScreen())
        else if (cover)
          const Positioned.fill(child: _Cover()),
      ],
    );
  }
}

/// "Dottoday is locked" with Unlock; asks the device once on show.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  void _unlock() {
    if (!mounted) return;
    unawaited(
      ref.read(appLockedProvider.notifier).unlock(context.l10n.lockReason),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return ColoredBox(
      color: t.colors.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.page),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: DotSpace.l,
              children: [
                const _Dot(),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.lockTitle,
                    style: t.styles.pageTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
                FilledButton(onPressed: _unlock, child: Text(l10n.lockUnlock)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The app switcher's view of a locked-capable app: the surface and dot.
class _Cover extends StatelessWidget {
  const _Cover();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: DotTheme.of(context).colors.surface,
    child: const Center(child: _Dot()),
  );
}

/// The brand dot, full (the welcome screen's DayDot).
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: DayDot(geometry: DayDotGeometry.filled(1), size: DotSize.dayDot * 3),
  );
}
