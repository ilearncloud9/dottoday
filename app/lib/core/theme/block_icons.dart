import 'package:flutter/material.dart';

/// The curated block icons offered by the picker (docs/03 §3.4), in picker
/// order. [key] is the persisted `icon_key`; [name] equals it.
///
/// Stored keys outside this set (newer app, icon pack) stay valid data and
/// render as [fallback] (see `domain/entities/icon_keys.dart`).
enum BlockIcon {
  circle(Icons.circle_outlined),
  work(Icons.work_outline),
  meeting(Icons.groups_outlined),
  call(Icons.call_outlined),
  mail(Icons.mail_outline),
  code(Icons.code),
  study(Icons.school_outlined),
  book(Icons.menu_book_outlined),
  gym(Icons.fitness_center),
  run(Icons.directions_run),
  walk(Icons.directions_walk),
  bike(Icons.directions_bike),
  meal(Icons.restaurant),
  coffee(Icons.local_cafe_outlined),
  sleep(Icons.bedtime_outlined),
  medication(Icons.medication_outlined),
  heart(Icons.favorite_border),
  home(Icons.home_outlined),
  clean(Icons.cleaning_services_outlined),
  shopping(Icons.shopping_cart_outlined),
  commute(Icons.directions_car_outlined),
  flight(Icons.flight),
  music(Icons.music_note_outlined),
  pet(Icons.pets),
  star(Icons.star_border);

  const BlockIcon(this.icon);

  /// Glyph drawn in the block's icon circle.
  final IconData icon;

  /// Icon for new tasks and unknown keys (the `icon_key` column default).
  static const fallback = BlockIcon.circle;

  static final _byKey = values.asNameMap();

  /// Persisted `icon_key` value.
  String get key => name;

  /// Parses a stored `icon_key`, falling back to [fallback].
  static BlockIcon fromKey(String? key) => _byKey[key] ?? fallback;
}
