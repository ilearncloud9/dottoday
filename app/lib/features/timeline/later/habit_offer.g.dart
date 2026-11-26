// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_offer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The first of this device's onboarding tasks ready for "Make it a
/// habit" on [today], or null: still every day, three of its days done,
/// not every weekday, not offered before. Re-read as today's tasks change
/// (a tick can make one ready).

@ProviderFor(habitOffer)
final habitOfferProvider = HabitOfferFamily._();

/// The first of this device's onboarding tasks ready for "Make it a
/// habit" on [today], or null: still every day, three of its days done,
/// not every weekday, not offered before. Re-read as today's tasks change
/// (a tick can make one ready).

final class HabitOfferProvider
    extends
        $FunctionalProvider<
          AsyncValue<HabitOffer?>,
          HabitOffer?,
          FutureOr<HabitOffer?>
        >
    with $FutureModifier<HabitOffer?>, $FutureProvider<HabitOffer?> {
  /// The first of this device's onboarding tasks ready for "Make it a
  /// habit" on [today], or null: still every day, three of its days done,
  /// not every weekday, not offered before. Re-read as today's tasks change
  /// (a tick can make one ready).
  HabitOfferProvider._({
    required HabitOfferFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'habitOfferProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitOfferHash();

  @override
  String toString() {
    return r'habitOfferProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HabitOffer?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HabitOffer?> create(Ref ref) {
    final argument = this.argument as DateTime;
    return habitOffer(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitOfferProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitOfferHash() => r'e7775bcd5d9820dcee2d4569aa0750a38c12b616';

/// The first of this device's onboarding tasks ready for "Make it a
/// habit" on [today], or null: still every day, three of its days done,
/// not every weekday, not offered before. Re-read as today's tasks change
/// (a tick can make one ready).

final class HabitOfferFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HabitOffer?>, DateTime> {
  HabitOfferFamily._()
    : super(
        retry: null,
        name: r'habitOfferProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The first of this device's onboarding tasks ready for "Make it a
  /// habit" on [today], or null: still every day, three of its days done,
  /// not every weekday, not offered before. Re-read as today's tasks change
  /// (a tick can make one ready).

  HabitOfferProvider call(DateTime today) =>
      HabitOfferProvider._(argument: today, from: this);

  @override
  String toString() => r'habitOfferProvider';
}
