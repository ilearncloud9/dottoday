/// [item] moved to the front of [list] without repeats, keeping at most
/// [max]: recently used icons (on the device) and Your colours (synced),
/// newest first (ED-086, ED-221).
///
/// ```dart
/// pushRecent(['a', 'b', 'c'], 'c', max: 3); // ['c', 'a', 'b']
/// pushRecent(['a', 'b', 'c'], 'd', max: 3); // ['d', 'a', 'b']
/// ```
List<T> pushRecent<T>(List<T> list, T item, {required int max}) =>
    [item, ...list.where((x) => x != item)].take(max).toList();
