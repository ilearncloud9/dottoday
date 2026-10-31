import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/routine.dart';

import '../domain/fixtures.dart';

// The three routines of `B-ios-routines` (docs/09 M11.4).

RoutineItem _step(
  String id,
  String title,
  String color,
  String icon,
  int at,
  int len,
) => RoutineItem(
  id: id,
  title: title,
  colorKey: color,
  iconKey: icon,
  offsetMin: at,
  durationMin: len,
);

/// Morning (from Wake Up), Shutdown (ending at Wind Down), Gym day (5:30 PM).
List<Routine> sampleRoutines() => [
  Routine(
    id: '01928c3e-0000-7000-8000-0000000001a1',
    userId: userId,
    title: 'Morning',
    items: [
      _step('m1', 'Wake up stretch', 'mint', 'heart', 0, 10),
      _step('m2', 'Run', 'coral', 'run', 10, 30),
      _step('m3', 'Shower', 'sky', 'water', 40, 15),
      _step('m4', 'Breakfast', 'amber', 'meal', 55, 20),
    ],
    createdAt: t0,
    updatedAt: t1,
  ),
  Routine(
    id: '01928c3e-0000-7000-8000-0000000001a2',
    userId: userId,
    title: 'Shutdown',
    anchor: RoutineAnchor.bed,
    sortOrder: 1,
    items: [
      _step('s1', 'Review today', 'slate', 'list', 0, 10),
      _step('s2', 'Plan tomorrow', 'indigo', 'document', 10, 15),
      _step('s3', 'Read', 'violet', 'book', 25, 15),
    ],
    createdAt: t0,
    updatedAt: t1,
  ),
  Routine(
    id: '01928c3e-0000-7000-8000-0000000001a3',
    userId: userId,
    title: 'Gym day',
    anchor: RoutineAnchor.time,
    anchorMinute: 17 * 60 + 30,
    sortOrder: 2,
    items: [
      _step('g1', 'Pack bag', 'amber', 'bag', 0, 10),
      _step('g2', 'Gym', 'mint', 'gym', 10, 60),
      _step('g3', 'Protein', 'rose', 'meal', 70, 5),
    ],
    createdAt: t0,
    updatedAt: t1,
  ),
];
