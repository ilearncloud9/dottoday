/// Every release with in-app notes, newest first (PRD F11, R-19). Adding a
/// release = a value here (the changelog page's exhaustive switch then asks
/// for its localised notes) and its `CHANGELOG.md` section.
enum Release {
  v0_1_0('0.1.0');

  const Release(this.version);

  /// The marketing version, `major.minor.patch` (pubspec without the build).
  final String version;
}

/// Orders two `major.minor.patch` versions; missing or non-numeric parts
/// count as 0, so `1.2` == `1.2.0`. A pre-release or build suffix
/// (`-beta`, `+3`) is ignored.
///
/// ```dart
/// compareVersions('1.10.0', '1.9.3'); // > 0
/// ```
int compareVersions(String a, String b) {
  final pa = _parts(a);
  final pb = _parts(b);
  for (var i = 0; i < 3; i++) {
    final c = pa[i].compareTo(pb[i]);
    if (c != 0) return c;
  }
  return 0;
}

List<int> _parts(String v) {
  final core = v.split(RegExp('[-+ ]')).first.split('.');
  return [
    for (var i = 0; i < 3; i++)
      i < core.length ? int.tryParse(core[i]) ?? 0 : 0,
  ];
}

/// The releases this build knows of that are newer than [seen] and not
/// newer than [current], newest first: what "What's new" offers after an
/// update. Empty when [seen] is null (a fresh install: onboarding explains
/// the app, nothing is "new") or nothing changed.
///
/// ```dart
/// unseenReleases(seen: '0.1.0', current: '0.2.0'); // [Release.v0_2_0]
/// ```
List<Release> unseenReleases({
  required String? seen,
  required String current,
  List<Release> all = Release.values,
}) {
  if (seen == null) return const [];
  return [
    for (final r in all)
      if (compareVersions(r.version, seen) > 0 &&
          compareVersions(r.version, current) <= 0)
        r,
  ]..sort((a, b) => compareVersions(b.version, a.version));
}

/// The releases shown on the changelog page: up to [current], newest first.
List<Release> releasesUpTo(
  String current, {
  List<Release> all = Release.values,
}) => [
  for (final r in all)
    if (compareVersions(r.version, current) <= 0) r,
]..sort((a, b) => compareVersions(b.version, a.version));
