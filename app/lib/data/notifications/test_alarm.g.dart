// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_alarm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(testAlarmStore)
final testAlarmStoreProvider = TestAlarmStoreProvider._();

final class TestAlarmStoreProvider
    extends $FunctionalProvider<TestAlarmStore, TestAlarmStore, TestAlarmStore>
    with $Provider<TestAlarmStore> {
  TestAlarmStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'testAlarmStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$testAlarmStoreHash();

  @$internal
  @override
  $ProviderElement<TestAlarmStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TestAlarmStore create(Ref ref) {
    return testAlarmStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TestAlarmStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TestAlarmStore>(value),
    );
  }
}

String _$testAlarmStoreHash() => r'258290c0c0a5507b54dd4fa5f8e4784c6f3e0b72';

/// Sends or cancels the test alarm, then re-plans so the OS holds exactly
/// what the store says.

@ProviderFor(TestAlarm)
final testAlarmProvider = TestAlarmProvider._();

/// Sends or cancels the test alarm, then re-plans so the OS holds exactly
/// what the store says.
final class TestAlarmProvider extends $NotifierProvider<TestAlarm, void> {
  /// Sends or cancels the test alarm, then re-plans so the OS holds exactly
  /// what the store says.
  TestAlarmProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'testAlarmProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$testAlarmHash();

  @$internal
  @override
  TestAlarm create() => TestAlarm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$testAlarmHash() => r'1e6281bc733723f04c0a947a3b42c10f6b35b95f';

/// Sends or cancels the test alarm, then re-plans so the OS holds exactly
/// what the store says.

abstract class _$TestAlarm extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
