import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/observability/sentry_reporting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../support/fake_clock.dart';

// Crash reports carry no task content (docs/04 §9, 06 §6, docs/09 M6.7).

final class _Hub extends Mock implements Hub {}

const _title = 'Dentist with Dr Ana';

void main() {
  setUpAll(() {
    registerFallbackValue(Breadcrumb());
    registerFallbackValue(Object());
  });

  group('scrubEvent', () {
    test('removes the person and anything with content', () {
      final event = SentryEvent(
        user: SentryUser(id: 'u1', email: 'kody@example.com'),
        request: SentryRequest(url: 'https://x/task?title=$_title'),
        serverName: "Kody's MacBook",
        message: SentryMessage(_title),
        exceptions: [
          SentryException(type: 'StateError', value: 'No task "$_title"'),
          SentryException(
            type: '$LoggedError',
            value: 'StateError at sync.failed',
          ),
        ],
        breadcrumbs: [
          Breadcrumb(category: 'ui.click', message: _title),
          Breadcrumb(category: 'dottoday.sync.failed'),
        ],
      );
      event.contexts.device = SentryDevice(
        name: "Kody's iPhone",
        model: 'iPhone17,1',
      );
      final out = scrubEvent(event, Hint())!;
      expect(out.user, isNull);
      expect(out.request, isNull);
      expect(out.serverName, isNull);
      expect(out.message, isNull);
      expect(out.contexts.device!.name, isNull);
      expect(out.contexts.device!.model, 'iPhone17,1');
      expect(out.exceptions![0].type, 'StateError');
      expect(out.exceptions![0].value, isNull);
      expect(out.exceptions![1].value, 'StateError at sync.failed');
      expect(out.breadcrumbs!.map((b) => b.category), ['dottoday.sync.failed']);
    });

    test('drops breadcrumbs that are not ours', () {
      expect(scrubBreadcrumb(Breadcrumb(category: 'http'), Hint()), isNull);
      expect(
        scrubBreadcrumb(Breadcrumb(category: 'dottoday.x'), Hint()),
        isNotNull,
      );
    });
  });

  group('SentryLogSink', () {
    late _Hub hub;
    late Logger logger;

    setUp(() {
      hub = _Hub();
      when(() => hub.addBreadcrumb(any())).thenAnswer((_) async {});
      when(
        () => hub.captureException(
          any<Object>(),
          stackTrace: any<Object?>(named: 'stackTrace'),
        ),
      ).thenAnswer((_) async => const SentryId.empty());
      logger = Logger(
        FanOutLogSink([SentryLogSink(hub)]),
        FakeClock(DateTime.utc(2026, 10, 23)),
      );
    });

    test('a record is a breadcrumb with its (safe) fields', () {
      logger.info('sync.done', fields: {'pulled': 3});
      final crumb =
          verify(() => hub.addBreadcrumb(captureAny())).captured.single
              as Breadcrumb;
      expect(crumb.category, 'dottoday.sync.done');
      expect(crumb.data, {'pulled': 3});
      verifyNever(
        () => hub.captureException(
          any<Object>(),
          stackTrace: any<Object?>(named: 'stackTrace'),
        ),
      );
    });

    // The canary: an error whose message holds a task title.
    test('an error goes as its type and event, never its message', () {
      logger.error(
        'editor.save_failed',
        error: StateError('could not save "$_title"'),
        stackTrace: StackTrace.current,
      );
      final sent = verify(
        () => hub.captureException(
          captureAny<Object>(),
          stackTrace: any<Object?>(named: 'stackTrace'),
        ),
      ).captured.single;
      expect(sent, isA<LoggedError>());
      expect('$sent', 'StateError at editor.save_failed');
      expect('$sent', isNot(contains('Dentist')));
    });
  });
}
