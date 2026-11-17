import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/snapshot/wind_down_snapshot.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'snapshot_providers.g.dart';

/// The Wind Down write of the day snapshot (docs/09 M9.1). One per owner
/// shown: a change of owner disposes it, cancelling the armed timer, which
/// was armed at the old owner's Wind Down (CR-160 I7); the switch arms the
/// new one.
@Riverpod(keepAlive: true)
WindDownSnapshot windDownSnapshot(Ref ref) {
  ref.watch(ownerEpochProvider);
  final windDown = WindDownSnapshot(
    clock: ref.watch(clockProvider),
    writer: ref.watch(daySnapshotWriterProvider),
    logger: ref.watch(loggerProvider),
  );
  ref.onDispose(windDown.cancel);
  return windDown;
}
