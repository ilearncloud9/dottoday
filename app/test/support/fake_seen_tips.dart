import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [SeenTips] without a database: starts with [initial], remembers
/// [putAway] calls in memory (docs/09 M14).
class FakeSeenTips extends SeenTips {
  FakeSeenTips([this.initial = const {}]);

  final Set<Tip> initial;

  @override
  Future<Set<Tip>> build() async => initial;

  @override
  Future<void> putAway(Tip tip) async =>
      state = AsyncData({...?state.value, tip});
}
