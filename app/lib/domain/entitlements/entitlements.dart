/// What this user may use (docs/09 M6.5.11, `11-standout-roadmap.md`
/// "Free / Pro split — DRAFT").
///
/// The split is the owner's to sign off; until then every feature is built
/// ungated and [isPro] is true in every build. This is the only pricing code
/// allowed: no paywall, purchase flow or store product reads or sets it.
/// Features may ask it (e.g. a routine count) so that a later split changes
/// one value, not every screen.
final class Entitlements {
  const Entitlements();

  /// True in every build until the owner signs off a free/Pro split.
  bool get isPro => true;
}
