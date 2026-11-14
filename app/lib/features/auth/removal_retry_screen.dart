import 'dart:async';

import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/shared/account/account_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The web's "Removal from this browser didn't finish" (CR-160 policy §4,
/// board `DeleteWebRetry`): a deleted account's copy whose removal a closed
/// tab or a reload interrupted. It stays hidden and in front of everything
/// until "Finish removing" succeeds.
class RemovalRetryScreen extends ConsumerStatefulWidget {
  const RemovalRetryScreen({super.key});

  @override
  ConsumerState<RemovalRetryScreen> createState() => _RemovalRetryState();
}

/// A leaf: the request in flight and whether the last one didn't work.
class _RemovalRetryState extends ConsumerState<RemovalRetryScreen> {
  var _busy = false;
  var _again = false;

  Future<void> _finish() async {
    setState(() {
      _busy = true;
      _again = false;
    });
    final result = await ref.read(accountActionsProvider).finishRemovals();
    if (!mounted) return;
    // Done: the gate moves on by itself once nothing is pending.
    setState(() {
      _busy = false;
      _again = result is! Ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Material(
      color: t.colors.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DotSpace.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: DotSize.promptWidth),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: t.colors.raised,
                  borderRadius: BorderRadius.circular(DotRadii.cardLarge),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(DotSpace.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: DotSpace.m,
                    children: [
                      const TonalBadge(DotGlyphs.repeat),
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.removalRetryTitle,
                          style: t.styles.promptTitle,
                        ),
                      ),
                      Text(
                        l10n.removalRetryBody,
                        style: t.styles.body.copyWith(color: t.colors.muted),
                      ),
                      if (_again) StatusLine(l10n.removalRetryAgain),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: FilledButton(
                          onPressed: _busy ? null : () => unawaited(_finish()),
                          child: Text(l10n.removalRetryAction),
                        ),
                      ),
                      Text(l10n.removalRetryHint, style: t.styles.rowMeta),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
