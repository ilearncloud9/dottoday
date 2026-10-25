import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/deep_link_guard.dart';
import 'package:flutter_test/flutter_test.dart';

const _v7 = '01929a3e-7c4b-7d2a-9f10-3b5c6d7e8f90';

String? _guard(String s) => allowListedLocation(Uri.parse(s));

void main() {
  group('allowListedLocation accepts', () {
    final cases = {
      '/': '/today',
      '/today': '/today',
      '/today/': '/today',
      '/inbox': '/inbox',
      '/week': '/week',
      '/month': '/month',
      '/search': '/search',
      '/settings': '/settings',
      '/day/2026-10-20': '/day/2026-10-20',
      '/day/2028-02-29': '/day/2028-02-29',
      '/task/$_v7': '/task/$_v7',
      'dottoday://task/$_v7': '/task/$_v7',
      'dottoday:///task/$_v7': '/task/$_v7',
      'dottoday://day/2026-10-20': '/day/2026-10-20',
      'dottoday://inbox': '/inbox',
      '/settings/account': '/settings/account',
      '/settings/privacy/': '/settings/privacy',
      'dottoday://settings/help': '/settings/help',
      'dottoday://add': '/add',
    };
    cases.forEach((input, expected) {
      test(input, () => expect(_guard(input), expected));
    });
  });

  group('allowListedLocation rejects', () {
    const cases = [
      '/admin',
      '/today/extra',
      '/today?q=1',
      '/inbox#frag',
      '/day/2026-02-30',
      '/day/2026-13-01',
      '/day/26-10-20',
      '/day/2026-10-20/x',
      '/day',
      '/task',
      '/task/not-a-uuid',
      '/task/${'01929a3e-7c4b-4d2a-9f10-3b5c6d7e8f90'}', // v4, not v7
      '/task/01929A3E-7C4B-7D2A-9F10-3B5C6D7E8F90', // uppercase
      '/task/$_v7?redirect=https://evil.example',
      '//evil.example/today',
      'https://evil.example/today',
      'javascript:alert(1)',
      'dottoday://user:pw@task/$_v7',
      'dottoday://task:80/$_v7',
      'otherapp://today',
      '/settings/admin',
      '/settings/Account',
      '/settings/help/x',
    ];
    for (final input in cases) {
      test(input, () => expect(_guard(input), isNull));
    }
  });

  test('dot segments are resolved by Uri.parse and cannot escape the list', () {
    // Uri normalises `..` (incl. percent-encoded) before the guard runs, so
    // traversal can only ever produce another allow-listed canonical route.
    expect(_guard('/task/../settings'), '/settings');
    expect(_guard('/task/%2E%2E'), '/today');
    expect(_guard('/task/../../admin'), isNull);
  });

  group('route dates', () {
    test('format pads and round-trips', () {
      final s = formatRouteDate(DateTime(2026, 3, 7));
      expect(s, '2026-03-07');
      expect(parseRouteDate(s), DateTime.utc(2026, 3, 7));
    });

    test('AppRoutes builders', () {
      expect(AppRoutes.day(DateTime(2026, 10, 20)), '/day/2026-10-20');
      expect(AppRoutes.task(_v7), '/task/$_v7');
    });
  });
}
