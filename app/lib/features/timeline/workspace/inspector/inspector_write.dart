import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/touch_content.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Writes [row] from the inspector as it changes (ED-086 autosave): one
/// undoable write, so ⌘Z takes it back; a failure is said with Try again
/// (R-08), never dropped. Each edit starts from the task as it is now,
/// so a Done or a drag in between is never written over.
Future<void> writeInspected(
  BuildContext context,
  WidgetRef ref,
  Occurrence row,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final now = ref.read(clockProvider).nowUtc();
  final undo = ref.read(undoServiceProvider);
  Future<void> write() async {
    final result = await undo.applyUndoable(
      WriteBatch(
        userId: row.userId,
        occurrences: [row.copyWith(updatedAt: now)],
      ),
    );
    if (result case Err(:final failure)) {
      showSaveFailureSnack(
        messenger,
        l10n,
        failure,
        onRetry: () => unawaited(write()),
      );
    }
  }

  await write();
}

/// The inspector's control heights: the board's pointer sizes on a Mac or
/// with a mouse, the touch height when touch drives the Workspace
/// (ED-261).
final class InspectorSizes {
  const InspectorSizes._(this.touch);

  /// Reads whether touch drives the content now.
  factory InspectorSizes.of(BuildContext context, WidgetRef ref) =>
      InspectorSizes._(watchTouchContent(context, ref));

  final bool touch;

  double _h(double pointer) => touch ? DotTouch.android : pointer;

  double get field => _h(DotSize.inspectorField);
  double get chip => _h(DotSize.inspectorChip);
  double get button => _h(DotSize.inspectorButton);
  double get extend => _h(DotSize.inspectorExtend);
  double get extendChip => _h(DotSize.inspectorExtendChip);
}

/// Whether the inspector docks beside a [available]-wide grid: from 1160
/// window width, when the grid keeps 3 days of 144 and its hours (ED-170
/// C1, 476); otherwise it floats over the grid. At [touch] sizes it always
/// floats (E-R2-2, ED-269).
bool inspectorDocks(
  BuildContext context, {
  required double available,
  required bool touch,
}) {
  if (touch) return false;
  if (AppLayout.classOf(context) != WidthClass.expanded) return false;
  if (MediaQuery.sizeOf(context).width < AppLayout.dockFrom) return false;
  return available - DotSize.inspector - DotSpace.hairline >=
      DotSize.weekGridMin;
}
