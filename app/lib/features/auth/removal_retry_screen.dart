import 'dart:async';

import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/shared/account/account_buttons.dart';
import 'package:dottoday/shared/account/account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The web's "Removal from this browser didn't finish" (CR-160 policy §4,
/// board `DeleteWebRetry`, ED-495): a deleted account's copy whose removal a closed
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
    final look = accountDialogLook(context);
    return Material(
      color: t.colors.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DotSpace.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: RemovalRetrySize.width,
              ),
              child: Semantics(
                container: true,
                liveRegion: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AccountDialogColors.fill(t.colors),
                    borderRadius: BorderRadius.circular(
                      RemovalRetrySize.radius,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(RemovalRetrySize.pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: RemovalRetrySize.gap,
                      children: [
                        // Two arrows round a circle, as the board draws.
                        const TonalBadge(DotGlyphs.sync),
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.removalRetryTitle,
                            style: RemovalRetryType.title(t.styles),
                          ),
                        ),
                        Text(
                          l10n.removalRetryBody,
                          style: RemovalRetryType.body(t.styles, t.colors),
                        ),
                        if (_again) StatusLine(l10n.removalRetryAgain),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: RemovalRetrySize.buttonsTop,
                          ),
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: AccountButton.filled(
                              look: look,
                              label: l10n.removalRetryAction,
                              onPressed: _busy
                                  ? null
                                  : () => unawaited(_finish()),
                            ),
                          ),
                        ),
                        Text(
                          l10n.removalRetryHint,
                          style: AccountDialogType.note(t.styles, look),
                        ),
                      ],
                    ),
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
