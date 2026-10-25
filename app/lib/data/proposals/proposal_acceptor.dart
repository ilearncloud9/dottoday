import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'proposal_acceptor.g.dart';

/// Accept on a proposal (11 §0 B3): every remaining edit in one write-path
/// transaction, undoable for 30 s. The only place a proposal is written.
final class ProposalAcceptor {
  const ProposalAcceptor(this._undo);

  final UndoService _undo;

  /// Writes [proposal]; Ok(null) when nothing is left to write.
  Future<Result<UndoToken?, AppFailure>> accept(Proposal proposal) async {
    final batch = proposal.toBatch();
    if (batch.isEmpty) return const Ok(null);
    return switch (await _undo.applyUndoable(batch)) {
      Ok(:final value) => Ok(value),
      Err(:final failure) => Err(failure),
    };
  }
}

@riverpod
ProposalAcceptor proposalAcceptor(Ref ref) =>
    ProposalAcceptor(ref.watch(undoServiceProvider));
