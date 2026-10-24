import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_providers.g.dart';

/// Share sheet, save dialog and file picker. Tests override with a fake.
@Riverpod(keepAlive: true)
FileGateway fileGateway(Ref ref) => const PlatformFileGateway();

@Riverpod(keepAlive: true)
ExportService exportService(Ref ref) => DriftExportService(
  db: ref.watch(appDatabaseProvider),
  clock: ref.watch(clockProvider),
  logger: ref.watch(loggerProvider),
);
