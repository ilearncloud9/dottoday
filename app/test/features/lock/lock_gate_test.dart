import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/security/app_lock_store.dart';
import 'package:dottoday/data/security/device_auth.dart';
import 'package:dottoday/data/security/secure_window.dart';
import 'package:dottoday/domain/security/app_lock.dart';
import 'package:dottoday/features/lock/lock_gate.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/fake_clock.dart';
import '../../support/test_app.dart';

final class _Auth implements DeviceAuth {
  var pass = true;
  var asked = 0;

  @override
  bool asking = false;

  @override
  Future<bool> available() async => true;

  @override
  Future<bool> authenticate(String reason) async {
    asked++;
    return pass;
  }
}

final class _Setting extends AppLockSetting {
  _Setting(this.initial);

  final AppLockSettings initial;

  @override
  Future<AppLockSettings> build() async => initial;
}

void main() {
  late _Auth auth;
  late FakeClock clock;

  Future<void> pump(WidgetTester tester, AppLockSettings settings) async {
    auth = _Auth();
    clock = FakeClock(DateTime.utc(2026, 10, 23, 9));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deviceAuthProvider.overrideWithValue(auth),
          clockProvider.overrideWithValue(clock),
          appLockSettingProvider.overrideWith(() => _Setting(settings)),
        ],
        child: testApp(const LockGate(child: Text('My tasks'))),
      ),
    );
  }

  void lifecycle(WidgetTester tester, AppLifecycleState s) =>
      tester.binding.handleAppLifecycleStateChanged(s);

  testWidgets('off: the app as is', (tester) async {
    await pump(tester, const AppLockSettings());
    await tester.pumpAndSettle();
    expect(find.text('My tasks'), findsOneWidget);
    expect(find.byType(LockScreen), findsNothing);
    expect(auth.asked, 0);
  });

  testWidgets('on: locked at start, asks at once, unlocks on pass', (
    tester,
  ) async {
    auth = _Auth();
    await pump(tester, const AppLockSettings(enabled: true));
    auth.pass = false;
    await tester.pumpAndSettle();
    expect(find.text('Dottoday is locked'), findsOneWidget);
    expect(auth.asked, 1);
    await expectA11yGuidelines(tester);
    auth.pass = true;
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsNothing);
    expect(find.text('My tasks'), findsOneWidget);
  });

  testWidgets('relocks only after the delay; covered while away', (
    tester,
  ) async {
    await pump(
      tester,
      const AppLockSettings(enabled: true, after: Duration(minutes: 5)),
    );
    await tester.pumpAndSettle(); // auth passes → unlocked
    expect(find.byType(LockScreen), findsNothing);

    lifecycle(tester, AppLifecycleState.inactive);
    await tester.pump();
    // The app switcher sees the cover, not the tasks.
    expect(find.byType(LockScreen), findsNothing);
    expect(
      tester
          .widget<ExcludeSemantics>(
            find
                .ancestor(
                  of: find.text('My tasks'),
                  matching: find.byType(ExcludeSemantics),
                )
                .first,
          )
          .excluding,
      isTrue,
    );

    lifecycle(tester, AppLifecycleState.hidden);
    lifecycle(tester, AppLifecycleState.paused);
    clock.advance(const Duration(minutes: 2));
    lifecycle(tester, AppLifecycleState.hidden);
    lifecycle(tester, AppLifecycleState.inactive);
    lifecycle(tester, AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsNothing, reason: 'only 2 minutes');

    lifecycle(tester, AppLifecycleState.inactive);
    lifecycle(tester, AppLifecycleState.hidden);
    lifecycle(tester, AppLifecycleState.paused);
    clock.advance(const Duration(minutes: 6));
    auth.pass = false;
    lifecycle(tester, AppLifecycleState.hidden);
    lifecycle(tester, AppLifecycleState.inactive);
    lifecycle(tester, AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Dottoday is locked'), findsOneWidget);
  });

  // Found on the emulator (M5.8): Android's PIN screen pauses the app, so
  // passing it came back to a fresh lock, forever.
  testWidgets('our own prompt pausing the app does not relock', (tester) async {
    await pump(tester, const AppLockSettings(enabled: true));
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsNothing);

    auth.asking = true;
    lifecycle(tester, AppLifecycleState.inactive);
    lifecycle(tester, AppLifecycleState.hidden);
    lifecycle(tester, AppLifecycleState.paused);
    clock.advance(const Duration(minutes: 10));
    auth.asking = false;
    lifecycle(tester, AppLifecycleState.hidden);
    lifecycle(tester, AppLifecycleState.inactive);
    lifecycle(tester, AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsNothing);
  });

  // Found on the emulator (M5.8): saving read appLocked from inside
  // appLockSetting, a circular dependency, so the lock never turned on.
  testWidgets(
    'turning the lock on in Settings saves it and does not lock now',
    (tester) async {
      auth = _Auth();
      final container = ProviderContainer(
        overrides: [
          deviceAuthProvider.overrideWithValue(auth),
          appDatabaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
          secureWindowProvider.overrideWithValue(_NoSecure()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(appLockSettingProvider.future);
      expect(container.read(appLockedProvider), isFalse);
      final saved = await container
          .read(appLockSettingProvider.notifier)
          .save(const AppLockSettings(enabled: true), reason: 'r');
      expect(saved, isTrue);
      expect(auth.asked, 1);
      expect(container.read(appLockSettingProvider).value?.enabled, isTrue);
      expect(container.read(appLockedProvider), isFalse);
    },
  );
}

/// FLAG_SECURE without Android.
final class _NoSecure extends SecureWindow {
  _NoSecure();

  @override
  Future<void> set({required bool secure}) async {}
}
