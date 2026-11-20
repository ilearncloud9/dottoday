import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/router/deep_link_guard.dart';
import 'package:dottoday/domain/entities/enums.dart';
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
      // Start focus (M10.5).
      '/focus/$_v7': '/focus/$_v7',
      'dottoday://focus/$_v7': '/focus/$_v7',
      'dottoday://day/2026-10-20': '/day/2026-10-20',
      'dottoday://inbox': '/inbox',
      '/settings/account': '/settings/account',
      '/settings/privacy/': '/settings/privacy',
      'dottoday://settings/help': '/settings/help',
      'dottoday://add': '/add',
      // A mission morning's "I'm up" (docs/15 §8).
      'dottoday://wake-up/mission/2026-11-02/walk':
          '/wake-up/mission/2026-11-02/walk',
      '/wake-up/mission/2026-11-02/catchDot':
          '/wake-up/mission/2026-11-02/catchDot',
      // ED-097: a view keeps one ?task=; Week and Month on a date.
      '/today?task=$_v7': '/today?task=$_v7',
      '/day/2026-10-20?task=$_v7': '/day/2026-10-20?task=$_v7',
      '/inbox?task=$_v7': '/inbox?task=$_v7',
      'dottoday://search?task=$_v7': '/search?task=$_v7',
      '/week/2026-10-20': '/week/2026-10-20',
      '/week/2026-10-20?task=$_v7': '/week/2026-10-20?task=$_v7',
      '/month/2026-10': '/month/2026-10',
      // Places not built yet open the nearest one (owner, M18.7 part 3).
      // Minimal's Now (ED-068, M19.6).
      '/now': '/now',
      '/now?task=$_v7': '/now?task=$_v7',
      '/3-days/2026-10-20': '/3-days/2026-10-20',
      // Any other query is dropped and the path kept (D2).
      '/today?q=1': '/today',
      '/inbox?q=1&task=$_v7': '/inbox',
      '/today?task=not-a-uuid': '/today',
      '/today?task=01929A3E-7C4B-7D2A-9F10-3B5C6D7E8F90': '/today',
      '/settings?task=$_v7': '/settings',
      '/task/$_v7?redirect=https://evil.example': '/task/$_v7',
      '/focus/$_v7?task=$_v7': '/focus/$_v7',
    };
    cases.forEach((input, expected) {
      test(input, () => expect(_guard(input), expected));
    });
  });

  group('allowListedLocation rejects', () {
    const cases = [
      '/admin',
      '/today/extra',
      '/inbox#frag',
      '/day/2026-02-30',
      '/day/2026-13-01',
      '/day/26-10-20',
      '/day/2026-10-20/x',
      '/day',
      '/task',
      '/task/not-a-uuid',
      '/focus/not-a-uuid',
      '/task/${'01929a3e-7c4b-4d2a-9f10-3b5c6d7e8f90'}', // v4, not v7
      '/task/01929A3E-7C4B-7D2A-9F10-3B5C6D7E8F90', // uppercase
      '/month/2026-13',
      '/month/2026-1',
      '/week/2026-02-30',
      '/3-days/x',
      '//evil.example/today',
      'https://evil.example/today',
      'javascript:alert(1)',
      'dottoday://user:pw@task/$_v7',
      'dottoday://task:80/$_v7',
      'otherapp://today',
      '/settings/admin',
      '/settings/Account',
      '/settings/help/x',
      '/wake-up/mission/2026-11-02/math',
      '/wake-up/mission/2026-02-30/walk',
      '/wake-up/mission/2026-11-02',
      '/wake-up/mission/2026-11-02/walk/x',
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

  test('mission links carry exactly the MissionKind names', () {
    expect(AppRoutes.missionKinds, {
      for (final k in MissionKind.values) k.name,
    });
  });

  group('route dates', () {
    test('format pads and round-trips', () {
      final s = formatRouteDate(DateTime(2026, 3, 7));
      expect(s, '2026-03-07');
      // A local calendar date, as todayDate and AppRoutes.day use.
      expect(parseRouteDate(s), DateTime(2026, 3, 7));
    });

    test('AppRoutes builders', () {
      expect(AppRoutes.day(DateTime(2026, 10, 20)), '/day/2026-10-20');
      expect(AppRoutes.task(_v7), '/task/$_v7');
      expect(AppRoutes.weekOf(DateTime(2026, 10, 20)), '/week/2026-10-20');
      expect(AppRoutes.monthOf(DateTime(2026, 10, 9)), '/month/2026-10');
      expect(AppRoutes.withTask('/today', _v7), '/today?task=$_v7');
      final open = Uri.parse('/day/2026-10-20?task=$_v7');
      expect(AppRoutes.taskOf(open), _v7);
      expect(AppRoutes.withoutTask(open), '/day/2026-10-20');
    });
  });
}
