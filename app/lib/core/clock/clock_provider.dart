import 'package:dottoday/core/clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

/// App-wide [Clock]; tests override it with a fake.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();
