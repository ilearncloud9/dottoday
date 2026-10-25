import 'package:dottoday/domain/release/releases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('versions compare by number, missing parts are 0', () {
    expect(compareVersions('1.10.0', '1.9.3'), greaterThan(0));
    expect(compareVersions('1.2', '1.2.0'), 0);
    expect(compareVersions('0.1.0-beta', '0.1.0'), 0);
    expect(compareVersions('0.1.0+7', '0.2.0'), lessThan(0));
  });

  test('a fresh install has nothing new', () {
    expect(unseenReleases(seen: null, current: '0.1.0'), isEmpty);
  });

  test('releases after the last seen, up to the running one', () {
    expect(unseenReleases(seen: '0.0.9', current: '0.1.0'), [Release.v0_1_0]);
    expect(unseenReleases(seen: '0.1.0', current: '0.1.0'), isEmpty);
    // A build older than its newest notes doesn't announce them.
    expect(unseenReleases(seen: '0.0.1', current: '0.0.5'), isEmpty);
  });

  test('the changelog lists releases up to the running one, newest first', () {
    expect(releasesUpTo('0.1.0'), [Release.v0_1_0]);
    expect(releasesUpTo('0.0.1'), isEmpty);
  });

  test('versions are unique', () {
    final versions = Release.values.map((r) => r.version).toList();
    expect(versions.toSet().length, versions.length);
  });
}
