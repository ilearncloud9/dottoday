import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_state.g.dart';

/// [userId]'s Trash, newest first (R-11).
@riverpod
Stream<List<Occurrence>> trashItems(Ref ref, String userId) =>
    ref.watch(trashServiceProvider).watchTrash(userId);
