// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposal_acceptor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(proposalAcceptor)
final proposalAcceptorProvider = ProposalAcceptorProvider._();

final class ProposalAcceptorProvider
    extends
        $FunctionalProvider<
          ProposalAcceptor,
          ProposalAcceptor,
          ProposalAcceptor
        >
    with $Provider<ProposalAcceptor> {
  ProposalAcceptorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proposalAcceptorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proposalAcceptorHash();

  @$internal
  @override
  $ProviderElement<ProposalAcceptor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProposalAcceptor create(Ref ref) {
    return proposalAcceptor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProposalAcceptor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProposalAcceptor>(value),
    );
  }
}

String _$proposalAcceptorHash() => r'52acda2fbff765f3657e44fe81927fa340187eb8';
