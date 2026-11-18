import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/shared/dot/pointer_draggable.dart';
import 'package:dottoday/shared/dot/thread_drag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Switches the layout at once (docs/14 §5): no confirmation, no tour, no
/// loss warning, because nothing is lost; the next frame redraws. Only a
/// refused write says why.
void setLayout(BuildContext context, {required bool minimal}) {
  final container = ProviderScope.containerOf(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l10n = context.l10n;
  final layout = minimal ? UiLayout.minimal : UiLayout.full;
  unawaited(
    updateSettings(container, (s) => s.copyWith(uiLayout: layout)).then((r) {
      if (r case Err(:final failure)) {
        messenger?.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
      }
    }),
  );
}

/// Show Less / Show Everything from the keyboard and the Mac View menu
/// (⇧⌘L, web ⇧L; ED-095): the other layout than the stored one.
void toggleLayout(BuildContext context) {
  final layout = ProviderScope.containerOf(context).read(uiLayoutProvider);
  setLayout(context, minimal: layout != UiLayout.minimal);
}

/// Cancels a drag in flight when the layout switches (ED-100): the drop
/// is refused, so nothing is written and no Undo is made, and the drag's
/// Trash and Inbox targets go. Above every route.
class LayoutSwitchGuard extends ConsumerWidget {
  const LayoutSwitchGuard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(layoutPolicyProvider.select((p) => p.isMinimal), (_, _) {
      DragSession.voidAll();
      TaskDragging.current.value = null;
      TaskDragging.hint.value = null;
    });
    return child;
  }
}
