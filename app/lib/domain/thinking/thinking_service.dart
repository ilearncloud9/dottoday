import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/domain/thinking/model_output.dart';
import 'package:dottoday/domain/thinking/rules_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';

/// B4 (11 §0, ADR-0009): the one entry point for Break it down, brain-dump
/// and length suggestions. Returns proposals only — it holds no repository
/// and cannot write; Accept in `ProposalSheet` does that.
///
/// Order per request:
/// - [breakDown]: the saved breakdown (no model), then an on-device model,
///   then the empty template.
/// - [planFromText]: on-device, then Quick Add's parser.
/// - [suggestDuration]: the user's history when it has [trustedSamples],
///   then on-device, then any history at all.
///
/// ```dart
/// final r = await service.breakDown(
///   const BreakdownRequest(title: 'Clean the kitchen', language: 'en'),
/// );
/// ```
final class ThinkingService {
  ThinkingService({
    required RulesThinkingBackend rules,
    List<ThinkingBackend> onDevice = const [],
    List<RemoteThinkingBackend> remote = const [],
  }) : _rules = rules,
       _onDevice = onDevice,
       assert(
         ThinkingFlags.remoteBackends || remote.isEmpty,
         'Remote thinking backends are off (ADR-0009, CLAUDE.md §11).',
       );

  final RulesThinkingBackend _rules;
  final List<ThinkingBackend> _onDevice;

  /// History beats a model once the user has done the task this often:
  /// their own lengths are what "it learns how long things take you"
  /// promises (11, position line).
  static const trustedSamples = 3;

  Future<Result<BreakdownProposal, ValidationFailure>> breakDown(
    BreakdownRequest request,
  ) async {
    final invalid = _checkTitle(request.title);
    if (invalid != null) return Err(invalid);
    final depthOk =
        request.depth >= 0 && request.depth < BreakdownRequest.maxDepth;
    final limitOk =
        request.stepLimit >= 1 &&
        request.stepLimit <= BreakdownRequest.maxSteps;
    if (!depthOk || !limitOk) {
      return const Err(
        ValidationFailure(ValidationField.subtasks, ValidationRule.outOfRange),
      );
    }
    final fallback = await _rules.breakDown(request);
    if (fallback.origin == ThinkingOrigin.saved) return Ok(fallback);
    final model = await _available();
    final proposal = await model?.breakDown(request);
    return Ok(proposal ?? fallback);
  }

  Future<Result<TextPlanProposal?, ValidationFailure>> planFromText(
    TextPlanRequest request,
  ) async {
    if (request.text.trim().isEmpty) {
      return const Err(
        ValidationFailure(
          ValidationField.quickAddText,
          ValidationRule.required,
        ),
      );
    }
    if (request.text.length > QuickAddParser.maxInputLength) {
      return const Err(
        ValidationFailure(ValidationField.quickAddText, ValidationRule.tooLong),
      );
    }
    final model = await _available();
    final proposal = await model?.planFromText(request);
    return Ok(proposal ?? await _rules.planFromText(request));
  }

  Future<Result<DurationProposal?, ValidationFailure>> suggestDuration(
    DurationRequest request,
  ) async {
    final invalid = _checkTitle(request.title);
    if (invalid != null) return Err(invalid);
    final history = await _rules.suggestDuration(request);
    if (history != null && history.samples >= trustedSamples) {
      return Ok(history);
    }
    final model = await _available();
    return Ok(await model?.suggestDuration(request) ?? history);
  }

  Future<ThinkingBackend?> _available() async {
    for (final backend in _onDevice) {
      if (await backend.availability() == ThinkingAvailability.available) {
        return backend;
      }
    }
    return null;
  }

  static ValidationFailure? _checkTitle(String title) {
    if (title.trim().isEmpty) {
      return const ValidationFailure(
        ValidationField.title,
        ValidationRule.required,
      );
    }
    if (title.length > ModelOutput.maxTitle) {
      return const ValidationFailure(
        ValidationField.title,
        ValidationRule.tooLong,
      );
    }
    return null;
  }
}
