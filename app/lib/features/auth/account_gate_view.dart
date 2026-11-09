import 'dart:async';

import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/owners/removal_runner.dart';
import 'package:dottoday/features/auth/guest_work_screen.dart';
import 'package:dottoday/features/auth/removal_retry_screen.dart';
import 'package:dottoday/features/auth/settings_choice_screen.dart';
import 'package:dottoday/features/auth/signed_out_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The CR-160 screens in front of the app after a change of owner (see
/// [AccountGate]): A3 after a sign-out, G1 / G1b at a sign-in with guest
/// work, B1 once the first sync settled, and on the web an interrupted
/// removal. The app stays mounted underneath, hidden, unfocusable and out
/// of the semantics tree, so its router still takes sign-in links (as
/// under onboarding, M6.1) and its state survives the gate.
class AccountGateView extends ConsumerStatefulWidget {
  const AccountGateView({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AccountGateView> createState() => _AccountGateViewState();
}

/// Listens for sign-ins from the start; builds the gate.
class _AccountGateViewState extends ConsumerState<AccountGateView> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(
      signedInAccountIdProvider,
      _accountChanged,
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Native: an interrupted removal finishes by itself (policy §4).
    ref.watch(pendingRemovalRunnerProvider);
    final screen = _screen(ref.watch(accountGateProvider).value);
    final hidden = screen != null;
    return Stack(
      children: [
        Offstage(
          offstage: hidden,
          child: TickerMode(
            enabled: !hidden,
            child: ExcludeFocus(excluding: hidden, child: widget.child),
          ),
        ),
        if (screen != null)
          // Its own navigator, for the gate's dialogs and focus.
          HeroControllerScope.none(
            child: Navigator(
              pages: [
                MaterialPage<void>(key: ValueKey(screen.key), child: screen),
              ],
              onDidRemovePage: (_) {},
            ),
          ),
      ],
    );
  }

  /// A sign-in that finished ends A3; an account still signed in at launch
  /// with A3 recorded means a sign-out was interrupted: finish it.
  void _accountChanged(AsyncValue<String?>? before, AsyncValue<String?> now) {
    if (!now.hasValue || now.value == null) return;
    final actions = ref.read(accountActionsProvider);
    final wasSignedOut =
        before != null && before.hasValue && before.value == null;
    unawaited(
      wasSignedOut ? actions.signedIn() : actions.finishInterruptedSignOut(),
    );
  }

  static Widget? _screen(AccountGate? gate) => switch (gate) {
    null || NoAccountGate() => null,
    RemovalPendingGate() => const RemovalRetryScreen(
      key: ValueKey(_Screen.removal),
    ),
    SignedOutGate() => const SignedOutScreen(key: ValueKey(_Screen.signedOut)),
    final GuestWorkGate g => GuestWorkScreen(
      key: const ValueKey(_Screen.guestWork),
      gate: g,
    ),
    final GuestNoticeGate g => GuestNoticeScreen(
      key: const ValueKey(_Screen.guestNotice),
      gate: g,
    ),
    final SettingsChoiceGate g => SettingsChoiceScreen(
      key: const ValueKey(_Screen.settings),
      gate: g,
    ),
  };
}

/// The gate's screens, as page keys: a new gate is a new page; the same
/// gate with fresh data keeps its page and state.
enum _Screen { removal, signedOut, guestWork, guestNotice, settings }
