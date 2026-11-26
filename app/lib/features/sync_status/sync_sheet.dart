import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/pwa/browser_storage.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/sync_status/conflict_review.dart';
import 'package:dottoday/features/sync_status/web_sync_details.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/sheets/side_sheet.dart';
import 'package:dottoday/shared/sync/clock_skew_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Sync sheet (docs/09 M3f.8, R-08; E-G4-7 B4, M20.10 part 4a,
/// ED-481): where sync stands with its icon, when it last ran and what is
/// waiting, a filled Sync now with why resending is safe, and each
/// conflict with "Keep mine / Keep theirs"; Done closes it. With no
/// account, it says so and offers Sign in.
Future<void> showSyncSheet(BuildContext context) => showAppSheet<void>(
  context: context,
  title: _title(context),
  done: !_browser(context),
  foot: _browser(context) ? const _WebAction() : null,
  builder: (_) => const _SyncBody(),
);

/// The same content from the sidebar line at [anchor] (ED-481): a popover
/// pointing at it on the Mac, the web and iPad (E-G4-7 B5, E-R2-8); a side
/// sheet on Android tablets (E-R2-8 draws a standard one; this is the
/// modal side sheet the app has).
Future<void> showSyncPopover(BuildContext context, Rect anchor) {
  // The Android app's container (docs/10 §4: containers may differ by
  // platform, layout never does), as Add decides it.
  if (!webChrome(context) &&
      Theme.of(context).platform == TargetPlatform.android) {
    return showModalSideSheet<void>(
      context: context,
      builder: (_) => AppSheet(
        title: _title(context),
        done: true,
        child: const _SyncBody(),
      ),
    );
  }
  return showAnchoredPopover<void>(
    context: context,
    anchor: anchor,
    width: DotSize.syncPopover,
    builder: (_) => AppSheet(
      title: _title(context),
      done: !_browser(context),
      foot: _browser(context) ? const _WebAction() : null,
      child: const _SyncBody(),
    ),
  );
}

class _SyncBody extends ConsumerWidget {
  const _SyncBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final status = ref.watch(syncStatusProvider).value ?? SyncStatus.localOnly;
    final browser = ref.watch(inBrowserProvider);
    if (status.state == SyncState.localOnly) {
      // The web guest, once something is saved here (Q2e, ED-192).
      if (browser && ref.watch(savedInBrowserProvider)) {
        return const WebGuestDetails();
      }
      return const _LocalOnly();
    }
    // What was just kept, with Undo, on the Mac and web (C5); then the
    // conflicts waiting for a choice (C2, C4); then where sync stands.
    if (ref.watch(lastConflictChoiceProvider) case final undo?) {
      return ConflictResolved(undo: undo);
    }
    if (status.conflicts.isNotEmpty) {
      return ConflictReview(conflicts: status.conflicts);
    }
    // A fast clock pauses this device's changes (E-G4-7 B legend, ED-482).
    final paused =
        status.state == SyncState.synced && (status.clockSkew?.fast ?? false);
    final ended = status.state == SyncState.sessionEnded;
    // The web says what this browser keeps (Q2, ED-484).
    if (browser) {
      return WebSyncDetails(
        status: status,
        last: _lastSynced(context, ref, status.lastSyncedUtc),
        stateGlyph: paused ? DotGlyphs.clock : _stateGlyph(status.state),
        stateLine: paused
            ? l10n.syncStatePaused
            : _stateLine(l10n, status.state),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.s,
          children: [
            DotIcon(
              paused ? DotGlyphs.clock : _stateGlyph(status.state),
              color: t.colors.text,
              size: DotSize.rowIcon,
            ),
            Expanded(
              child: Text(
                paused ? l10n.syncStatePaused : _stateLine(l10n, status.state),
                style: t.styles.rowTitle,
              ),
            ),
          ],
        ),
        Text(
          l10n.syncSummary(
            _lastSynced(context, ref, status.lastSyncedUtc),
            l10n.syncPending(status.pending),
          ),
          style: t.styles.rowMeta,
        ),
        if (status.clockSkew case final skew?) ...[
          Text(clockSkewText(l10n, skew), style: t.styles.body),
          if (skew.fast) Text(l10n.syncClockWaiting, style: t.styles.rowMeta),
        ],
        // Session ended: only signing in again helps (A10).
        if (ended)
          const _SignInButton()
        else ...[
          _syncNowButton(context, ref, status.state),
          Text(l10n.syncNowNote, style: t.styles.rowMeta),
        ],
      ],
    );
  }

  /// The state line's icon (E-G4-7 B legend): icon and words, never colour
  /// alone.
  static DotGlyph _stateGlyph(SyncState state) => switch (state) {
    SyncState.synced || SyncState.localOnly => DotGlyphs.check,
    SyncState.syncing => DotGlyphs.sync,
    SyncState.offline => DotGlyphs.cloudOff,
    SyncState.error => DotGlyphs.warning,
    SyncState.sessionEnded => DotGlyphs.lock,
  };

  static String _stateLine(AppLocalizations l10n, SyncState state) =>
      switch (state) {
        SyncState.synced || SyncState.localOnly => l10n.syncStateSynced,
        SyncState.syncing => l10n.syncStateSyncing,
        SyncState.offline => l10n.syncStateOffline,
        SyncState.error => l10n.syncStateError,
        SyncState.sessionEnded => l10n.failureAuth,
      };

  /// "Last synced just now / 4 min ago / Tue, Oct 20, 9:41 PM".
  static String _lastSynced(BuildContext context, WidgetRef ref, DateTime? at) {
    final l10n = context.l10n;
    if (at == null) return l10n.syncNever;
    final now = ref.watch(clockProvider).nowUtc();
    final minutes = now.difference(at).inMinutes;
    if (minutes < 1) return l10n.syncJustNow;
    if (minutes < 60) return l10n.syncMinutesAgo(minutes);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final tzId = ref.watch(currentProfileProvider).value?.tzId;
    final local = tzId == null
        ? at
        : tz.TZDateTime.from(at, tz.getLocation(tzId));
    return l10n.syncAt(DateFormat.MMMEd(locale).add_jm().format(local));
  }
}

/// Sync now: filled, as B4 draws it.
Widget _syncNowButton(
  BuildContext context,
  WidgetRef ref,
  SyncState state, {
  bool tonal = false,
}) {
  // Filled, as B4 draws it; off while it runs or there is no connection
  // (B5: dimmed, and screen readers hear it is off). Tonal on the web
  // with nothing waiting (Q2a, Q2c).
  final onPressed = state == SyncState.syncing || state == SyncState.offline
      ? null
      : () => unawaited(_syncNow(context, ref));
  final label = Text(context.l10n.syncNow);
  final c = DotTheme.of(context).colors;
  return Align(
    alignment: AlignmentDirectional.centerStart,
    child: tonal
        ? FilledButton.tonal(
            onPressed: onPressed,
            // The E tonal (Q2a): the theme's pill is filled.
            style: FilledButton.styleFrom(
              backgroundColor: c.accentTint,
              foregroundColor: c.accentInk,
            ),
            child: label,
          )
        : FilledButton(onPressed: onPressed, child: label),
  );
}

Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  if (await ref.read(syncServiceProvider).syncNow() case Err(:final failure)) {
    messenger.showSnackBar(
      SnackBar(content: Text(failureMessage(l10n, failure))),
    );
  }
}

/// The web panel's pinned main action (Q2a–Q2f): Sign in… for a guest
/// with something saved or a session that ended, nothing while a conflict
/// or its Undo shows, else Sync now (tonal with nothing waiting).
class _WebAction extends ConsumerWidget {
  const _WebAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value ?? SyncStatus.localOnly;
    if (status.state == SyncState.localOnly) {
      return ref.watch(savedInBrowserProvider)
          ? const _SignInButton()
          : const SizedBox.shrink();
    }
    if (status.conflicts.isNotEmpty ||
        ref.watch(lastConflictChoiceProvider) != null) {
      return const SizedBox.shrink();
    }
    if (status.state == SyncState.sessionEnded) return const _SignInButton();
    return _syncNowButton(
      context,
      ref,
      status.state,
      tonal: status.pending == 0,
    );
  }
}

/// No account: what that means, and Sign in….
class _LocalOnly extends StatelessWidget {
  const _LocalOnly();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        Text(l10n.syncLocalOnlyBody, style: t.styles.body),
        const _SignInButton(),
      ],
    );
  }
}

/// Sign in…, opening Settings › Account (no account here, or the session
/// ended; E-G4-7 A10).
class _SignInButton extends StatelessWidget {
  const _SignInButton();

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: FilledButton(
      onPressed: () {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        unawaited(router.push(AppRoutes.settingsPage(SettingsPage.account)));
      },
      child: Text(context.l10n.syncSignIn),
    ),
  );
}

/// "Changed on two devices" while conflicts wait for a choice (C2, C4),
/// else "Sync details" on the web (Q2) and "Sync" elsewhere; fixed when
/// the sheet opens.
String _title(BuildContext context) {
  final container = ProviderScope.containerOf(context, listen: false);
  final status = container.read(syncStatusProvider).value;
  final l10n = context.l10n;
  if (status?.conflicts.isNotEmpty ?? false) return l10n.syncConflicts;
  return _browser(context) ? l10n.syncDetailsTitle : l10n.syncTitle;
}

/// In a browser: the panel closes with ✕, not Done (C5, Q2).
bool _browser(BuildContext context) =>
    ProviderScope.containerOf(context, listen: false).read(inBrowserProvider);
