import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/look/recent_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Saves [hex] (`#RRGGBB`) first in the account's Your colours, at most
/// [Profile.maxYourColours] (ED-221: synced per field, so every device
/// shows the same row).
Future<Result<void, AppFailure>> saveYourColour(
  ProviderContainer ref,
  String hex,
) => updateProfile(
  ref,
  (p) => p.copyWith(
    yourColours: pushRecent(
      p.yourColours,
      hex.toUpperCase(),
      max: Profile.maxYourColours,
    ),
  ),
);

/// Removes [hex] from Your colours (Edit); tasks in it keep it (ED-220).
Future<Result<void, AppFailure>> removeYourColour(
  ProviderContainer ref,
  String hex,
) => updateProfile(
  ref,
  (p) => p.copyWith(
    yourColours: [
      for (final c in p.yourColours)
        if (c.toUpperCase() != hex.toUpperCase()) c,
    ],
  ),
);
