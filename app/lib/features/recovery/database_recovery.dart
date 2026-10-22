import 'dart:async';

import 'package:dottoday/core/app/app_restart.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/db/database_health.dart';
import 'package:dottoday/data/db/database_unavailable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows [child] (the app) while the database is usable, else the
/// recovery screen (docs/09 M3f.9; 06 §4, M2.4). Above the navigator, so
/// it needs no route and nothing behind it can touch the database.
class DatabaseGate extends ConsumerWidget {
  const DatabaseGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(databaseStatusProvider).value) {
        DatabaseBlocked(reason: DatabaseUnavailableReason.openInAnotherTab) =>
          const _Recovery(kind: _Kind.otherTab),
        DatabaseBlocked() => const _Recovery(kind: _Kind.locked),
        DatabaseHandedOff() => const _Recovery(kind: _Kind.handedOff),
        // Ready, still checking, or an unrelated error the screens show.
        _ => child,
      };
}

enum _Kind { locked, otherTab, handedOff }

class _Recovery extends ConsumerStatefulWidget {
  const _Recovery({required this.kind});

  final _Kind kind;

  @override
  ConsumerState<_Recovery> createState() => _RecoveryState();
}

/// A leaf: the inline confirmation and the waiting/answer state.
class _RecoveryState extends ConsumerState<_Recovery> {
  var _confirming = false;
  var _busy = false;
  String? _note;

  /// After Start fresh: where the old file is kept, shown before Continue.
  String? _kept;

  DatabaseStatus get _status => ref.read(databaseStatusProvider.notifier);

  Future<void> _startFresh() async {
    setState(() => _busy = true);
    final kept = await _status.startFresh();
    if (!mounted) return;
    if (kept == null) return AppRestart.of(context);
    setState(() {
      _kept = kept;
      _busy = false;
    });
  }

  Future<void> _useHere() async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _note = null;
    });
    final ok = await _status.useHere();
    if (!mounted || ok) return;
    setState(() {
      _busy = false;
      _note = l10n.recoveryNoAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final (title, body) = switch (widget.kind) {
      _Kind.locked => (l10n.recoveryLockedTitle, l10n.recoveryLockedBody),
      _Kind.otherTab => (l10n.recoveryTabTitle, l10n.recoveryTabBody),
      _Kind.handedOff => (l10n.recoveryMovedTitle, l10n.recoveryMovedBody),
    };
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DotSize.readableColumn),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(DotSpace.page),
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: t.styles.pageTitle),
                ),
                const SizedBox(height: DotSpace.m),
                Text(body, style: t.styles.body),
                const SizedBox(height: DotSpace.l),
                ..._actions(t, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(DotTheme t, AppLocalizations l10n) {
    if (widget.kind != _Kind.locked) {
      return [
        FilledButton(
          onPressed: _busy ? null : () => unawaited(_useHere()),
          child: Text(l10n.recoveryUseHere),
        ),
        if (_note case final note?) ...[
          const SizedBox(height: DotSpace.s),
          Text(note, style: t.styles.body.copyWith(color: t.colors.muted)),
        ],
      ];
    }
    if (_kept case final kept?) {
      return [
        Text(l10n.recoveryKept(kept), style: t.styles.body),
        const SizedBox(height: DotSpace.m),
        FilledButton(
          // A fresh start for every screen (the old errors go with it).
          onPressed: () => AppRestart.of(context),
          child: Text(l10n.recoveryContinue),
        ),
      ];
    }
    return [
      Text(
        _confirming ? l10n.recoveryConfirm : l10n.recoveryFreshBody,
        style: t.styles.body.copyWith(color: t.colors.muted),
      ),
      const SizedBox(height: DotSpace.m),
      FilledButton(
        onPressed: _busy
            ? null
            : _confirming
            ? () => unawaited(_startFresh())
            : () => setState(() => _confirming = true),
        child: Text(
          _confirming ? l10n.recoveryConfirmYes : l10n.recoveryStartFresh,
        ),
      ),
    ];
  }
}
