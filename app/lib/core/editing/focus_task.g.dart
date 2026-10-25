// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_task.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The task in Focus on Mac/web: a centred view in the content area with
/// the rail kept (docs/09 M10.5, docs/10 §4); null = none. Phones push
/// `/focus/:id` full screen instead. Held in core, like `EditingTask`, so
/// any screen can open Focus without importing it.

@ProviderFor(FocusTask)
final focusTaskProvider = FocusTaskProvider._();

/// The task in Focus on Mac/web: a centred view in the content area with
/// the rail kept (docs/09 M10.5, docs/10 §4); null = none. Phones push
/// `/focus/:id` full screen instead. Held in core, like `EditingTask`, so
/// any screen can open Focus without importing it.
final class FocusTaskProvider extends $NotifierProvider<FocusTask, String?> {
  /// The task in Focus on Mac/web: a centred view in the content area with
  /// the rail kept (docs/09 M10.5, docs/10 §4); null = none. Phones push
  /// `/focus/:id` full screen instead. Held in core, like `EditingTask`, so
  /// any screen can open Focus without importing it.
  FocusTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusTaskHash();

  @$internal
  @override
  FocusTask create() => FocusTask();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$focusTaskHash() => r'c42ad16be89861dfb67416a63860258807d94a47';

/// The task in Focus on Mac/web: a centred view in the content area with
/// the rail kept (docs/09 M10.5, docs/10 §4); null = none. Phones push
/// `/focus/:id` full screen instead. Held in core, like `EditingTask`, so
/// any screen can open Focus without importing it.

abstract class _$FocusTask extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// A surface asked for Focus on a dot (Start focus from a control, a
/// tile or Siri, docs/09 M10.5); the app root opens it. Each request is
/// new, even for the same dot.

@ProviderFor(FocusRequest)
final focusRequestProvider = FocusRequestProvider._();

/// A surface asked for Focus on a dot (Start focus from a control, a
/// tile or Siri, docs/09 M10.5); the app root opens it. Each request is
/// new, even for the same dot.
final class FocusRequestProvider
    extends $NotifierProvider<FocusRequest, ({String id, int seq})?> {
  /// A surface asked for Focus on a dot (Start focus from a control, a
  /// tile or Siri, docs/09 M10.5); the app root opens it. Each request is
  /// new, even for the same dot.
  FocusRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusRequestProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusRequestHash();

  @$internal
  @override
  FocusRequest create() => FocusRequest();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({String id, int seq})? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({String id, int seq})?>(value),
    );
  }
}

String _$focusRequestHash() => r'f61fd45d37cba47eac9820235b3d7e9f1c6432ce';

/// A surface asked for Focus on a dot (Start focus from a control, a
/// tile or Siri, docs/09 M10.5); the app root opens it. Each request is
/// new, even for the same dot.

abstract class _$FocusRequest extends $Notifier<({String id, int seq})?> {
  ({String id, int seq})? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<({String id, int seq})?, ({String id, int seq})?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<({String id, int seq})?, ({String id, int seq})?>,
              ({String id, int seq})?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
