import AppIntents
import Foundation

#if canImport(ActivityKit)
  import ActivityKit

  /// Starts, updates and ends the one Live Activity (docs/09 M9.3). The
  /// app decides what it shows (`dottoday/live_activity`, AppDelegate);
  /// Done and +15 on the activity act on it at once, then queue for the
  /// app like every other surface (DotActions).
  @available(iOS 16.2, *)
  enum LiveActivities {
    typealias Dot = Activity<DotActivityAttributes>

    /// Shows [state] — starting, updating or replacing the activity — or
    /// ends it when [state] is nil. Stale after the dot's grace, so the
    /// system greys it out if the app can't end it in time.
    static func sync(_ state: LiveDotState?) async {
      guard let state else {
        for activity in Dot.activities { await activity.end(nil, dismissalPolicy: .immediate) }
        return
      }
      let content = ActivityContent(state: state, staleDate: state.endsAt)
      if let current = Dot.activities.first {
        await current.update(content)
        for extra in Dot.activities.dropFirst() { await extra.end(nil, dismissalPolicy: .immediate) }
        return
      }
      guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
      _ = try? Dot.request(attributes: DotActivityAttributes(), content: content)
    }

    /// Done on the activity: it goes at once.
    static func end(occurrenceId: String) async {
      for activity in Dot.activities where activity.content.state.id == occurrenceId.lowercased() {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }

    /// +15 on the activity: the end moves at once — only while it is still
    /// [plannedEndMs], like the app's rule, so a double tap adds 15 once.
    static func plusFifteen(occurrenceId: String, plannedEndMs: Double) async {
      for activity in Dot.activities
      where activity.content.state.id == occurrenceId.lowercased()
        && activity.content.state.endMs == plannedEndMs
      {
        let next = activity.content.state.plusFifteen()
        await activity.update(ActivityContent(state: next, staleDate: next.endsAt))
      }
    }
  }

  /// Done from the Live Activity or the Dynamic Island (runs in the app's
  /// process, iOS 17+).
  @available(iOS 17.0, *)
  struct LiveMarkDoneIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "intentMarkDoneTitle"
    static var isDiscoverable = false

    @Parameter(title: "intentParamTask")
    var occurrenceId: String

    init() {}
    init(occurrenceId: String) { self.occurrenceId = occurrenceId }

    func perform() async throws -> some IntentResult {
      DotActions.perform(.markDone, occurrenceId: occurrenceId)
      await LiveActivities.end(occurrenceId: occurrenceId)
      return .result()
    }
  }

  /// +15 from the Live Activity or the Dynamic Island.
  @available(iOS 17.0, *)
  struct LiveAddFifteenIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "intentAddFifteenTitle"
    static var isDiscoverable = false

    @Parameter(title: "intentParamTask")
    var occurrenceId: String

    @Parameter(title: "intentParamEnd")
    var plannedEndMs: Int

    init() {}
    init(occurrenceId: String, plannedEndMs: Int) {
      self.occurrenceId = occurrenceId
      self.plannedEndMs = plannedEndMs
    }

    func perform() async throws -> some IntentResult {
      DotActions.perform(
        .addFifteen, occurrenceId: occurrenceId,
        plannedEnd: Date(timeIntervalSince1970: Double(plannedEndMs) / 1000))
      await LiveActivities.plusFifteen(occurrenceId: occurrenceId, plannedEndMs: Double(plannedEndMs))
      return .result()
    }
  }
#endif
