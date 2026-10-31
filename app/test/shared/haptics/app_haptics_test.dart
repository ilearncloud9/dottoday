import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/shared/haptics/app_haptics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/timeline_fakes.dart';

// Settings › Sounds › Haptics in app (docs/12 §6, M15.7): every in-app
// haptic goes through AppHaptics, and the one switch silences them all.
void main() {
  late List<Object?> taps;

  setUp(() => taps = []);

  void listen(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') taps.add(call.arguments);
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
  }

  /// Pumps a widget under [scope] and returns its context.
  Future<BuildContext> pump(WidgetTester tester, {bool? scope}) async {
    late BuildContext context;
    final probe = Builder(
      builder: (c) {
        context = c;
        return const SizedBox.shrink();
      },
    );
    await tester.pumpWidget(
      scope == null ? probe : HapticsScope(enabled: scope, child: probe),
    );
    return context;
  }

  testWidgets('on outside a scope, as before the switch', (tester) async {
    listen(tester);
    final context = await pump(tester);
    AppHaptics.play(context, HapticTick.medium);
    await tester.pump();
    expect(taps, ['HapticFeedbackType.mediumImpact']);
  });

  testWidgets('each tick plays its own kind', (tester) async {
    listen(tester);
    final context = await pump(tester, scope: true);
    for (final tick in HapticTick.values) {
      AppHaptics.play(context, tick);
    }
    await tester.pump();
    expect(taps, [
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.mediumImpact',
    ]);
  });

  testWidgets('off: no tick plays', (tester) async {
    listen(tester);
    final context = await pump(tester, scope: false);
    expect(AppHaptics.enabledOf(context), isFalse);
    for (final tick in HapticTick.values) {
      AppHaptics.play(context, tick);
    }
    await tester.pump();
    expect(taps, isEmpty);
  });

  for (final on in [true, false]) {
    testWidgets('playFor follows the stored switch (${on ? 'on' : 'off'})', (
      tester,
    ) async {
      listen(tester);
      late WidgetRef ref;
      final profile = testProfile(settings: Settings(inAppHapticsEnabled: on));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentProfileProvider.overrideWith((_) => Stream.value(profile)),
          ],
          child: Consumer(
            builder: (_, r, _) {
              ref = r;
              r.watch(currentProfileProvider);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();
      AppHaptics.playFor(ref, HapticTick.light);
      await tester.pump();
      expect(taps, on ? ['HapticFeedbackType.lightImpact'] : isEmpty);
    });
  }
}
