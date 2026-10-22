import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/trash/drift_trash_service.dart';
import 'package:dottoday/data/undo/in_memory_undo_service.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/trash/trash_service.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'trash_providers.g.dart';

/// App-wide so a token from one screen can be redeemed by the snackbar.
@Riverpod(keepAlive: true)
UndoService undoService(Ref ref) => InMemoryUndoService(
  writes: ref.watch(writeUseCaseProvider),
  occurrences: ref.watch(occurrenceRepositoryProvider),
  subtasks: ref.watch(subtaskRepositoryProvider),
  series: ref.watch(seriesRepositoryProvider),
  clock: ref.watch(clockProvider),
  ids: const UuidV7Generator(),
);

@Riverpod(keepAlive: true)
TrashService trashService(Ref ref) => DriftTrashService(
  db: ref.watch(appDatabaseProvider),
  writes: ref.watch(writeUseCaseProvider),
  undo: ref.watch(undoServiceProvider),
  clock: ref.watch(clockProvider),
  logger: ref.watch(loggerProvider),
);
