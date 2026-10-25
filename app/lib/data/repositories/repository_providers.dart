import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:dottoday/data/repositories/drift_routine_repository.dart';
import 'package:dottoday/data/repositories/drift_search_repository.dart';
import 'package:dottoday/data/repositories/drift_series_repository.dart';
import 'package:dottoday/data/repositories/drift_settings_repository.dart';
import 'package:dottoday/data/repositories/drift_subtask_repository.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/repositories/routine_repository.dart';
import 'package:dottoday/domain/repositories/search_repository.dart';
import 'package:dottoday/domain/repositories/series_repository.dart';
import 'package:dottoday/domain/repositories/settings_repository.dart';
import 'package:dottoday/domain/repositories/subtask_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

// Typed as the domain interfaces: features never see Drift (CLAUDE.md §3).

@Riverpod(keepAlive: true)
OccurrenceRepository occurrenceRepository(Ref ref) =>
    DriftOccurrenceRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
SeriesRepository seriesRepository(Ref ref) =>
    DriftSeriesRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
RoutineRepository routineRepository(Ref ref) =>
    DriftRoutineRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
SubtaskRepository subtaskRepository(Ref ref) =>
    DriftSubtaskRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    DriftSettingsRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) =>
    DriftSearchRepository(ref.watch(appDatabaseProvider));
