import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/sync/legacy_switch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'held_tasks.g.dart';

/// Tasks an old build gave the wrong account, held on this device
/// (CR-160 blocker 8): Settings › Account says so when there are any.
@riverpod
Stream<int> heldTasks(Ref ref) =>
    watchHeldTaskCount(ref.watch(appDatabaseProvider));
