import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger_provider.g.dart';

/// App-wide PII-safe [Logger].
@Riverpod(keepAlive: true)
Logger logger(Ref ref) =>
    Logger(const DeveloperLogSink(), ref.watch(clockProvider));
