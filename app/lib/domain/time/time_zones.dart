/// "Berlin" for `Europe/Berlin`, "New York" for `America/New_York`.
String zoneCity(String tzId) => tzId.split('/').last.replaceAll('_', ' ');

/// The ids a person picks from: Region/City only, no legacy aliases like
/// `EST5EDT` or `Etc/GMT+5`, sorted.
List<String> pickableZones(Iterable<String> ids) => [
  for (final id in ids)
    if (id.contains('/') && !id.startsWith('Etc/')) id,
]..sort();

/// [zones] whose id contains [query] (case-insensitive; spaces match
/// underscores, so "new york" finds `America/New_York`), at most [limit].
List<String> searchZones(List<String> zones, String query, {int limit = 40}) {
  final q = query.trim().toLowerCase().replaceAll(' ', '_');
  if (q.isEmpty) return const [];
  return zones.where((id) => id.toLowerCase().contains(q)).take(limit).toList();
}
