import 'package:flutter_test/flutter_test.dart';

import 'log_calls.dart';
import 'source_scan.dart';

void main() {
  group('piiLogViolationLines', () {
    test('flags interpolated, variable or prose events and prints', () {
      const src = r'''
void f(Logger log, String title, WidgetRef ref) {
  log.info('saved $title');
  _logger.warn(title);
  log.error('Task saved');
  ref.read(loggerProvider).info('title: x');
  print('x');
  debugPrint('y');
}
''';
      expect(piiLogViolationLines(src), [2, 3, 4, 5, 6, 7]);
    });

    test('allows literal event keys with typed fields', () {
      const src = '''
void f(Logger log) {
  log.info('sync.push.ok', fields: {'count': 1});
  _log.debug('timeline.drag.start');
  list.error('x'); // not a logger
}
''';
      expect(piiLogViolationLines(src), isEmpty);
    });
  });

  test('lib/** has no PII-capable log calls', () {
    final offenders = [
      for (final MapEntry(key: path, value: src) in readLibSources(
        'lib',
      ).entries)
        for (final line in piiLogViolationLines(src)) 'lib/$path:$line',
    ];
    expect(offenders, isEmpty, reason: 'docs/06 §8 no_pii_in_logs');
  });

  // Dictation (docs/09 M14.4, ADR-0014): what was said is never logged,
  // not even as an event — speech code has no logger at all.
  test('speech code never logs', () {
    final offenders = [
      for (final MapEntry(key: path, value: src) in readLibSources(
        'lib',
      ).entries)
        if (path.contains('speech/') &&
            RegExp(r'logger|Logger|debugPrint|print\(').hasMatch(src))
          'lib/$path',
    ];
    expect(offenders, isEmpty);
  });
}
