import 'package:dottoday/core/logging/logger.dart';

/// Collects log records for assertions.
final class MemoryLogSink implements LogSink {
  final records = <LogRecord>[];

  @override
  void write(LogRecord record) => records.add(record);
}
