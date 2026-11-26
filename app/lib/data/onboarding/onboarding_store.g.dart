// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This device's onboarding (docs/09 M4, M20.11): in `local_meta`, never
/// synced; a new device asks again (signing in then brings the data).

@ProviderFor(Onboarding)
final onboardingProvider = OnboardingProvider._();

/// This device's onboarding (docs/09 M4, M20.11): in `local_meta`, never
/// synced; a new device asks again (signing in then brings the data).
final class OnboardingProvider
    extends $AsyncNotifierProvider<Onboarding, OnboardingProgress> {
  /// This device's onboarding (docs/09 M4, M20.11): in `local_meta`, never
  /// synced; a new device asks again (signing in then brings the data).
  OnboardingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingHash();

  @$internal
  @override
  Onboarding create() => Onboarding();
}

String _$onboardingHash() => r'5f3c308126d441dda3ee76e77247a6b71785986e';

/// This device's onboarding (docs/09 M4, M20.11): in `local_meta`, never
/// synced; a new device asks again (signing in then brings the data).

abstract class _$Onboarding extends $AsyncNotifier<OnboardingProgress> {
  FutureOr<OnboardingProgress> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<OnboardingProgress>, OnboardingProgress>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OnboardingProgress>, OnboardingProgress>,
              AsyncValue<OnboardingProgress>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
