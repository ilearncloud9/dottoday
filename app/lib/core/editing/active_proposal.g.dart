// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_proposal.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The proposal on screen, if any: a bottom sheet on phones, the right-hand
/// panel at the expanded width (docs/10 §4 "no sheets at expanded"). Held
/// in core, like `EditingTask`, so any feature can open one without
/// importing the sheet. Nothing here writes; Accept goes through
/// `ProposalAcceptor`.

@ProviderFor(ActiveProposal)
final activeProposalProvider = ActiveProposalProvider._();

/// The proposal on screen, if any: a bottom sheet on phones, the right-hand
/// panel at the expanded width (docs/10 §4 "no sheets at expanded"). Held
/// in core, like `EditingTask`, so any feature can open one without
/// importing the sheet. Nothing here writes; Accept goes through
/// `ProposalAcceptor`.
final class ActiveProposalProvider
    extends $NotifierProvider<ActiveProposal, ProposalRequest?> {
  /// The proposal on screen, if any: a bottom sheet on phones, the right-hand
  /// panel at the expanded width (docs/10 §4 "no sheets at expanded"). Held
  /// in core, like `EditingTask`, so any feature can open one without
  /// importing the sheet. Nothing here writes; Accept goes through
  /// `ProposalAcceptor`.
  ActiveProposalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeProposalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeProposalHash();

  @$internal
  @override
  ActiveProposal create() => ActiveProposal();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProposalRequest? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProposalRequest?>(value),
    );
  }
}

String _$activeProposalHash() => r'89ae81764eafbb40abe61429edd690e453440b20';

/// The proposal on screen, if any: a bottom sheet on phones, the right-hand
/// panel at the expanded width (docs/10 §4 "no sheets at expanded"). Held
/// in core, like `EditingTask`, so any feature can open one without
/// importing the sheet. Nothing here writes; Accept goes through
/// `ProposalAcceptor`.

abstract class _$ActiveProposal extends $Notifier<ProposalRequest?> {
  ProposalRequest? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProposalRequest?, ProposalRequest?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProposalRequest?, ProposalRequest?>,
              ProposalRequest?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
