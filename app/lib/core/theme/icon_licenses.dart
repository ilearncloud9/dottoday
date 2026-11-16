import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the notices of the bundled font and of the icon libraries the task
/// icons are drawn from to About › Licenses: Manrope (SIL OFL 1.1, M18.1),
/// Lucide (ISC) and Tabler (MIT) (ADR-0013). Each licence asks that its
/// notice ships with the copies.
void registerIconLicenses() => LicenseRegistry.addLicense(() async* {
  for (final (package, file) in [
    ('Manrope', 'manrope'),
    ('Lucide', 'lucide'),
    ('Tabler Icons', 'tabler'),
  ]) {
    yield LicenseEntryWithLineBreaks([
      package,
    ], await rootBundle.loadString('assets/licenses/$file.txt'));
  }
});
