// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This device's onboarding (docs/09 M4): in `local_meta`, never synced —
/// a new device asks again (O5's sign-in then brings the data).

@ProviderFor(Onboarding)
final onboardingProvider = OnboardingProvider._();

/// This device's onboarding (docs/09 M4): in `local_meta`, never synced —
/// a new device asks again (O5's sign-in then brings the data).
final class OnboardingProvider
    extends $AsyncNotifierProvider<Onboarding, OnboardingProgress> {
  /// This device's onboarding (docs/09 M4): in `local_meta`, never synced —
  /// a new device asks again (O5's sign-in then brings the data).
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

String _$onboardingHash() => r'99d7f2f620876b150ab4f85a0cfc1b726348da38';

/// This device's onboarding (docs/09 M4): in `local_meta`, never synced —
/// a new device asks again (O5's sign-in then brings the data).

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
