// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_column_prefs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the person hid Minimal's Day column beside Now on the Mac and
/// the web (ED-218: ⌥⌘I, its ✕, View › Show Day Column). A view setting,
/// not a place: remembered on this device in `local_meta`, never synced,
/// and it never changes the address (ED-097).

@ProviderFor(DayColumnHidden)
final dayColumnHiddenProvider = DayColumnHiddenProvider._();

/// Whether the person hid Minimal's Day column beside Now on the Mac and
/// the web (ED-218: ⌥⌘I, its ✕, View › Show Day Column). A view setting,
/// not a place: remembered on this device in `local_meta`, never synced,
/// and it never changes the address (ED-097).
final class DayColumnHiddenProvider
    extends $AsyncNotifierProvider<DayColumnHidden, bool> {
  /// Whether the person hid Minimal's Day column beside Now on the Mac and
  /// the web (ED-218: ⌥⌘I, its ✕, View › Show Day Column). A view setting,
  /// not a place: remembered on this device in `local_meta`, never synced,
  /// and it never changes the address (ED-097).
  DayColumnHiddenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dayColumnHiddenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dayColumnHiddenHash();

  @$internal
  @override
  DayColumnHidden create() => DayColumnHidden();
}

String _$dayColumnHiddenHash() => r'137222bd8aa6cecd730fe9d831b6db5c26dee85b';

/// Whether the person hid Minimal's Day column beside Now on the Mac and
/// the web (ED-218: ⌥⌘I, its ✕, View › Show Day Column). A view setting,
/// not a place: remembered on this device in `local_meta`, never synced,
/// and it never changes the address (ED-097).

abstract class _$DayColumnHidden extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
