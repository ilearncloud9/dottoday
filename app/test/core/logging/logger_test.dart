import 'package:dottoday/core/logging/logger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

final class _MemorySink implements LogSink {
  final records = <LogRecord>[];

  @override
  void write(LogRecord record) => records.add(record);
}

enum _Phase { push }

const _id = '01929a3e-7c4b-7d2a-9f10-3b5c6d7e8f90';

void main() {
  late _MemorySink sink;
  late FakeClock clock;

  Logger logger({bool strict = true}) => Logger(sink, clock, strict: strict);

  setUp(() {
    sink = _MemorySink();
    clock = FakeClock(DateTime.utc(2026, 10, 20, 8));
  });

  group('strict (debug/test)', () {
    test('rejects free-text events like "title: x"', () {
      expect(() => logger().info('title: x'), throwsArgumentError);
      expect(() => logger().info('Saved task'), throwsArgumentError);
      expect(() => logger().info('nodots'), throwsArgumentError);
      expect(sink.records, isEmpty);
    });

    test('rejects raw strings and content-named keys', () {
      expect(
        () => logger().info('task.saved', fields: {'id': 'Buy milk'}),
        throwsArgumentError,
      );
      for (final key in ['title', 'taskTitle', 'notes', 'calendarName']) {
        expect(
          () => logger().info('task.saved', fields: {key: 1}),
          throwsArgumentError,
          reason: key,
        );
      }
      expect(
        () => logger().info('task.saved', fields: {'id': const LogId('x')}),
        throwsArgumentError,
        reason: 'LogId must be a UUID',
      );
    });

    test('writes typed, structured records', () {
      final err = StateError('contains Buy milk');
      logger().error(
        'sync.push.failed',
        fields: {
          'occurrenceId': const LogId(_id),
          'count': 3,
          'retry': true,
          'phase': _Phase.push,
          'elapsed': const Duration(seconds: 2),
          'at': DateTime.utc(2026),
          'query': Logger.redact('secret words'),
        },
        error: err,
        stackTrace: StackTrace.current,
      );
      final r = sink.records.single;
      expect(r.event, 'sync.push.failed');
      expect(r.level, LogLevel.error);
      expect(r.timeUtc, clock.nowUtc());
      expect(r.fields, {
        'occurrenceId': _id,
        'count': 3,
        'retry': true,
        'phase': 'push',
        'elapsed': 2000,
        'at': '2026-01-01T00:00:00.000Z',
        'query': '<redacted len=12>',
      });
      expect(r.errorType, 'StateError');
      expect(r.toJson().toString(), isNot(contains('Buy milk')));
    });
  });

  test('release mode sanitises instead of throwing', () {
    logger(
      strict: false,
    ).info('title: Buy milk', fields: {'title': 1, 'id': 'Buy milk'});
    final r = sink.records.single;
    expect(r.event, 'log.invalid_event');
    expect(r.fields, {'id': '<redacted len=8>'});
    expect(r.toJson().toString(), isNot(contains('milk')));
  });

  test('defaults to strict when asserts are enabled', () {
    expect(() => Logger(sink, clock).info('bad event'), throwsArgumentError);
  });
}
