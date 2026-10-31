import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/features/timeline/wake_up/wake_up_card_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Opens the Wake Up card over Today by itself, once a day, when
/// `wakeUpCardDueNow` says so (docs/15 §5): after "I'm up", or on the first
/// open after Wake Up. Re-asks on every resume, after the alarm events are
/// drained.
class WakeUpCardGate extends ConsumerStatefulWidget {
  const WakeUpCardGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<WakeUpCardGate> createState() => _WakeUpCardGateState();
}

class _WakeUpCardGateState extends ConsumerState<WakeUpCardGate> {
  /// The day it opened for: never twice, even before the card's own
  /// "shown" write lands.
  String? _opened;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    ref.listenManual(wakeUpCardDueNowProvider, (_, due) {
      final day = due.value;
      if (day == null || day == _opened) return;
      _opened = day;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(context.push(AppRoutes.wakeUp));
      });
    }, fireImmediately: true);
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(wakeUpCardProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
