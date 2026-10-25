// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(diagnosticsReader)
final diagnosticsReaderProvider = DiagnosticsReaderProvider._();

final class DiagnosticsReaderProvider
    extends
        $FunctionalProvider<
          DiagnosticsReader,
          DiagnosticsReader,
          DiagnosticsReader
        >
    with $Provider<DiagnosticsReader> {
  DiagnosticsReaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diagnosticsReaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diagnosticsReaderHash();

  @$internal
  @override
  $ProviderElement<DiagnosticsReader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiagnosticsReader create(Ref ref) {
    return diagnosticsReader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiagnosticsReader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiagnosticsReader>(value),
    );
  }
}

String _$diagnosticsReaderHash() => r'1748c01e314bf03af4cd79622b85d954049b1f92';

/// The opt-in feedback diagnostics, read fresh each time the sheet opens
/// (PRD F11, R-19): versions, platform, sync state and counts only.

@ProviderFor(feedbackDiagnostics)
final feedbackDiagnosticsProvider = FeedbackDiagnosticsProvider._();

/// The opt-in feedback diagnostics, read fresh each time the sheet opens
/// (PRD F11, R-19): versions, platform, sync state and counts only.

final class FeedbackDiagnosticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<FeedbackDiagnostics>,
          FeedbackDiagnostics,
          FutureOr<FeedbackDiagnostics>
        >
    with
        $FutureModifier<FeedbackDiagnostics>,
        $FutureProvider<FeedbackDiagnostics> {
  /// The opt-in feedback diagnostics, read fresh each time the sheet opens
  /// (PRD F11, R-19): versions, platform, sync state and counts only.
  FeedbackDiagnosticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackDiagnosticsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackDiagnosticsHash();

  @$internal
  @override
  $FutureProviderElement<FeedbackDiagnostics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FeedbackDiagnostics> create(Ref ref) {
    return feedbackDiagnostics(ref);
  }
}

String _$feedbackDiagnosticsHash() =>
    r'be99c4c8c1d4475dfc4de564a8291d0dfbb5d3f4';
