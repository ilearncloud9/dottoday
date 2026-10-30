import 'package:dottoday/domain/notifications/sound_catalogue.gen.dart';

/// A picker section of the bundled sounds (docs/12-sounds.md §2). The
/// first-party tones are [dottoday]; [start] and [done] have their own
/// Settings rows (D2, D4), the rest are the normal reminder tier.
enum SoundCategory {
  dottoday,
  quiet,
  clear,
  play,
  start,
  done;

  /// Whether a task's reminder may use this category's sounds (D2).
  bool get isNormalTier => this != start && this != done;
}

/// One bundled sound: its permanent [id] (stored in `sound_id` and in
/// Settings), its picker [category] and the base [file] name of its
/// platform files (docs/12 §5).
final class CatalogueSound {
  const CatalogueSound(this.id, this.category, this.file);

  final String id;
  final SoundCategory category;
  final String file;

  @override
  bool operator ==(Object other) =>
      other is CatalogueSound &&
      other.id == id &&
      other.category == category &&
      other.file == file;

  @override
  int get hashCode => Object.hash(id, category, file);

  @override
  String toString() => 'CatalogueSound($id)';
}

/// Every bundled sound, in picker order.
final List<CatalogueSound> soundCatalogue = List.unmodifiable([
  for (final e in soundCatalogueEntries)
    CatalogueSound(e.id, SoundCategory.values.byName(e.category), e.file),
]);

final Map<String, CatalogueSound> _byId = {
  for (final s in soundCatalogue) s.id: s,
};

/// The bundled sound with [id], or null for an id this version doesn't
/// ship (a newer device's, or one dropped later).
CatalogueSound? catalogueSound(String? id) => _byId[id];
