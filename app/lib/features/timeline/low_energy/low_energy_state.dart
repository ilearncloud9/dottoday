import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/scheduling/low_energy.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether low-energy mode is on now (11 D2, docs/09 M12.2), rebuilt each
/// minute so Today comes back by itself at Wake Up.
bool watchLowEnergy(WidgetRef ref) {
  final settings = ref.watch(currentProfileProvider).value?.settings;
  final now =
      ref.watch(minuteTickProvider).value ?? ref.watch(clockProvider).nowUtc();
  return settings != null && lowEnergyOn(settings, now);
}
