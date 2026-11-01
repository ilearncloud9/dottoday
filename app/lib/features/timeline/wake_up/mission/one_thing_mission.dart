import 'dart:async';

import 'package:dottoday/domain/wake_up/one_thing.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_picker.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pick today's one thing as a morning mission (docs/15 §8): one tap on
/// the first dots (or the Inbox) and it is done; every answer is right.
/// A day that has lost its second dot since the alarm was armed can't
/// run it, so the morning just ends (rule 3).
class OneThingMission extends ConsumerStatefulWidget {
  const OneThingMission({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  ConsumerState<OneThingMission> createState() => _OneThingMissionState();
}

class _OneThingMissionState extends ConsumerState<OneThingMission> {
  var _ended = false;

  @override
  Widget build(BuildContext context) {
    final offer = ref.watch(oneThingOfferProvider(mission: true)).value;
    if (offer == null) return const SizedBox.shrink();
    if (offer.dots.length < oneThingMinDots) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _end());
      return const SizedBox.shrink();
    }
    return OneThingPicker(
      offer: offer,
      header: false,
      onPick: (o) => unawaited(_pick(offer.dateKey, o.id)),
    );
  }

  /// The pick is stored, then the mission is done; a failed write still
  /// ends the morning (the mission never holds the alarm hostage).
  Future<void> _pick(String dateKey, String id) async {
    if (_ended) return;
    await pickOneThing(
      ProviderScope.containerOf(context, listen: false),
      dateKey: dateKey,
      occurrenceId: id,
    );
    _end();
  }

  void _end() {
    if (_ended) return;
    _ended = true;
    widget.onDone();
  }
}
