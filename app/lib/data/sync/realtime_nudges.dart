import 'dart:async';

/// How a live feed's connection stands, as Realtime reports it.
enum FeedStatus {
  /// Joined. The server's change feed may still be starting.
  subscribed,

  /// The server's change feed is live: changes from here on are
  /// announced. A change made between [subscribed] and this was not.
  live,

  /// Joined but broken (the server refused the change feed, a socket
  /// error); nothing may arrive.
  error,

  /// The join wasn't answered in time.
  timedOut,

  /// Gone for good: this channel never rejoins on its own.
  closed,
}

/// Opens one live feed: [onChange] per server change, [onStatus] per
/// connection state; the returned function closes it.
typedef OpenFeed =
    Future<void> Function() Function({
      required void Function() onChange,
      required void Function(FeedStatus) onStatus,
    });

/// Sync's nudges from a live feed (docs/04 §4 "Triggers"): one per server change,
/// and one every time the feed joins and again when its change feed goes
/// live, since changes made before then were never announced. The pull runs from its cursor, so that one nudge
/// catches up with everything missed (R-08).
///
/// A feed that errors or closes is replaced: after [retryFirst], doubling
/// up to [retryMax], until one joins. Nothing runs on a clock otherwise.
final class RealtimeNudges {
  RealtimeNudges(
    this._open, {
    this.retryFirst = const Duration(seconds: 1),
    this.retryMax = const Duration(seconds: 30),
    Timer Function(Duration, void Function()) timer = Timer.new,
  }) : _timer = timer;

  final OpenFeed _open;
  final Timer Function(Duration, void Function()) _timer;

  /// The wait before reopening a broken feed; doubles per failure.
  final Duration retryFirst;

  /// The longest wait between reopenings.
  final Duration retryMax;

  /// The nudges; listening opens the feed, cancelling closes it.
  Stream<void> stream() {
    // Closed by its own onCancel, when sync stops listening.
    // ignore: close_sinks
    late final StreamController<void> out;
    Future<void> Function()? close;
    Timer? reopen;
    var generation = 0;
    var failures = 0;

    void open() {
      final mine = ++generation;
      close = _open(
        onChange: () {
          if (mine == generation) out.add(null);
        },
        onStatus: (status) {
          // A replaced feed's last words (its own close) are not news.
          if (mine != generation) return;
          if (status == FeedStatus.subscribed || status == FeedStatus.live) {
            failures = 0;
            out.add(null);
            return;
          }
          if (status == FeedStatus.timedOut) return; // it rejoins itself
          final wait = retryFirst * (1 << failures.clamp(0, 16));
          failures++;
          generation++;
          final old = close;
          close = null;
          unawaited(old?.call());
          reopen?.cancel();
          reopen = _timer(wait > retryMax ? retryMax : wait, open);
        },
      );
    }

    out = StreamController<void>(
      onListen: open,
      onCancel: () async {
        generation++;
        reopen?.cancel();
        await close?.call();
        await out.close();
      },
    );
    return out.stream;
  }
}
