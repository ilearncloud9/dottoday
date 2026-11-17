// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earlier_fold.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The days whose Earlier row is shown (ED-164): remembered for the day
/// while the app is open, folded again after a restart. A view choice, so
/// nothing is stored.

@ProviderFor(EarlierOpen)
final earlierOpenProvider = EarlierOpenProvider._();

/// The days whose Earlier row is shown (ED-164): remembered for the day
/// while the app is open, folded again after a restart. A view choice, so
/// nothing is stored.
final class EarlierOpenProvider
    extends $NotifierProvider<EarlierOpen, Set<DateTime>> {
  /// The days whose Earlier row is shown (ED-164): remembered for the day
  /// while the app is open, folded again after a restart. A view choice, so
  /// nothing is stored.
  EarlierOpenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'earlierOpenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$earlierOpenHash();

  @$internal
  @override
  EarlierOpen create() => EarlierOpen();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<DateTime>>(value),
    );
  }
}

String _$earlierOpenHash() => r'f6f76382ee77187965f70acf6b66cefca4c391f1';

/// The days whose Earlier row is shown (ED-164): remembered for the day
/// while the app is open, folded again after a restart. A view choice, so
/// nothing is stored.

abstract class _$EarlierOpen extends $Notifier<Set<DateTime>> {
  Set<DateTime> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<DateTime>, Set<DateTime>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<DateTime>, Set<DateTime>>,
              Set<DateTime>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
