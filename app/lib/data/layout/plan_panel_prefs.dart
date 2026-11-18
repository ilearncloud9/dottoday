import 'dart:convert';

import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plan_panel_prefs.g.dart';

/// The Plan panel as a person left it (ED-184, rules §9.16): hidden by
/// them, its width, and its folded sections. Remembered per device in
/// `local_meta`, never synced (a window's layout is the device's).
@immutable
final class PlanPanelPrefs {
  const PlanPanelPrefs({
    this.hidden = false,
    this.width = defaultWidth,
    this.folded = const {},
  });

  /// The board's 196 (Mac); resizable [minWidth]–[maxWidth].
  static const double defaultWidth = 196;
  static const double minWidth = 176;
  static const double maxWidth = 300;

  /// Hidden by the person (the button, the menu or a drag past the
  /// minimum); not when the window only hides it for room.
  final bool hidden;
  final double width;

  /// Names of the folded sections (`inbox`, `routines`, `dump`).
  final Set<String> folded;

  PlanPanelPrefs copyWith({bool? hidden, double? width, Set<String>? folded}) =>
      PlanPanelPrefs(
        hidden: hidden ?? this.hidden,
        width: width ?? this.width,
        folded: folded ?? this.folded,
      );

  String toJson() => jsonEncode({
    'hidden': hidden,
    'width': width,
    'folded': folded.toList()..sort(),
  });

  /// What [json] held, or the defaults when it is missing or unreadable.
  static PlanPanelPrefs fromJson(String? json) {
    if (json == null) return const PlanPanelPrefs();
    try {
      final m = jsonDecode(json) as Map<String, Object?>;
      final w = (m['width'] as num?)?.toDouble() ?? defaultWidth;
      return PlanPanelPrefs(
        hidden: m['hidden'] as bool? ?? false,
        width: w.clamp(minWidth, maxWidth),
        folded: {
          ...(m['folded'] as List<Object?>? ?? const []).whereType<String>(),
        },
      );
    } on FormatException {
      return const PlanPanelPrefs();
    } on TypeError {
      return const PlanPanelPrefs();
    }
  }
}

/// [PlanPanelPrefs], read once and written on each change.
@Riverpod(keepAlive: true)
class PlanPanel extends _$PlanPanel {
  static const _key = 'plan_panel';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<PlanPanelPrefs> build() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    return PlanPanelPrefs.fromJson(row?.value);
  }

  Future<void> setHidden({required bool hidden}) =>
      _save((p) => p.copyWith(hidden: hidden));

  Future<void> setWidth(double width) => _save(
    (p) => p.copyWith(
      width: width.clamp(PlanPanelPrefs.minWidth, PlanPanelPrefs.maxWidth),
    ),
  );

  Future<void> toggleFold(String section) => _save(
    (p) => p.copyWith(
      folded: p.folded.contains(section)
          ? ({...p.folded}..remove(section))
          : {...p.folded, section},
    ),
  );

  Future<void> _save(PlanPanelPrefs Function(PlanPanelPrefs p) change) async {
    final next = change(state.value ?? const PlanPanelPrefs());
    state = AsyncData(next);
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(key: _key, value: next.toJson()),
        );
  }
}
