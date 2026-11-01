import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/snapshot/wind_down_snapshot.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'snapshot_providers.g.dart';

/// The Wind Down write of the day snapshot (docs/09 M9.1).
@Riverpod(keepAlive: true)
WindDownSnapshot windDownSnapshot(Ref ref) {
  final windDown = WindDownSnapshot(
    clock: ref.watch(clockProvider),
    writer: ref.watch(daySnapshotWriterProvider),
    logger: ref.watch(loggerProvider),
  );
  ref.onDispose(windDown.cancel);
  return windDown;
}
