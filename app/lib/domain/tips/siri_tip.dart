/// Tasks the person adds (after onboarding) before Today suggests Siri
/// once (docs/09 M14.3): by then they know what a task is, and asking
/// Siri "What's next" means something.
const siriTipAfterTasks = 3;

/// Whether Today shows the one-time "Ask Siri …" card (docs/09 M14.3,
/// D3): only where Siri runs, never during onboarding, never once put
/// away, and only after [siriTipAfterTasks] tasks the person added since
/// onboarding finished on this device.
///
/// ```dart
/// showsSiriTip(siri: true, onboarded: true, putAway: false, added: 3);
/// // true
/// ```
bool showsSiriTip({
  required bool siri,
  required bool onboarded,
  required bool putAway,
  required int added,
}) => siri && onboarded && !putAway && added >= siriTipAfterTasks;
