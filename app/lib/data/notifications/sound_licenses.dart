import 'package:dottoday/data/notifications/sound_credits.gen.dart';
import 'package:flutter/foundation.dart';

/// Adds each credited sound source's notice to About › Licences (docs/12
/// §1): CC BY asks for the licence and that the files were changed; the
/// text comes from the manifest, so a new source brings its own.
void registerSoundLicenses() => LicenseRegistry.addLicense(() async* {
  for (final source in soundCreditSources) {
    yield LicenseEntryWithLineBreaks([source.name], source.notice);
  }
});
