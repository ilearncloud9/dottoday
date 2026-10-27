import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the notices of the icon libraries the task icons are drawn from
/// (ADR-0013: Lucide, ISC; Tabler, MIT) to About › Licenses. Both licenses
/// ask that the notice ships with copies of the drawings.
void registerIconLicenses() => LicenseRegistry.addLicense(() async* {
  for (final (package, file) in [
    ('Lucide', 'lucide'),
    ('Tabler Icons', 'tabler'),
  ]) {
    yield LicenseEntryWithLineBreaks([
      package,
    ], await rootBundle.loadString('assets/licenses/$file.txt'));
  }
});
