import 'package:dottoday/bootstrap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs a provider that always fails and counts how often it was built.
Future<int> _buildsAfterFailure(ProviderContainer container) async {
  var builds = 0;
  final failing = FutureProvider<int>((ref) async {
    builds++;
    // An Exception, not an Error: Riverpod never retries Errors.
    throw Exception('fail');
  });
  // Don't await `.future`: while retrying it stays pending until retries run
  // out. Count builds over a fixed window instead.
  container.listen(failing, (_, _) {});
  // Riverpod's default first retry is ~200 ms; wait well past it.
  await Future<void>.delayed(const Duration(milliseconds: 800));
  return builds;
}

void main() {
  test('root retry policy disables Riverpod 3 auto-retry', () async {
    final builds = await _buildsAfterFailure(
      ProviderContainer.test(retry: noProviderRetry),
    );
    expect(builds, 1);
  });

  test(
    'sanity: without it Riverpod retries (so the test above is real)',
    () async {
      final builds = await _buildsAfterFailure(ProviderContainer.test());
      expect(builds, greaterThan(1));
    },
  );
}
