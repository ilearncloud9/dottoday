import 'dart:async';

import 'package:dottoday/core/editing/pending_brain_dump.dart';
import 'package:dottoday/features/timeline/brain_dump/brain_dump_sheet.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens Brain dump for lines another feature handed over (minimal Add,
/// docs/14 §3 B4): Plan it then proposes them, and nothing is written
/// before Accept (CLAUDE.md §11).
class BrainDumpHost extends ConsumerWidget {
  const BrainDumpHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(pendingBrainDumpProvider, (_, next) async {
      if (next == null) return;
      ref.read(pendingBrainDumpProvider.notifier).clear();
      final today = await ref.read(todayDateProvider.future);
      if (!context.mounted) return;
      unawaited(showBrainDump(context, today, text: next));
    });
    return child;
  }
}
